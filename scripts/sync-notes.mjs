import { cp, mkdir, readdir, rm, stat, writeFile } from 'node:fs/promises';
import { dirname, isAbsolute, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadEnvFile } from 'node:process';

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');

try {
  loadEnvFile(resolve(projectRoot, '.env'));
} catch (error) {
  if (error?.code !== 'ENOENT') throw error;
}

const sourceRoot = process.env.NOTES_SOURCE_DIR
  ? isAbsolute(process.env.NOTES_SOURCE_DIR)
    ? process.env.NOTES_SOURCE_DIR
    : resolve(projectRoot, process.env.NOTES_SOURCE_DIR)
  : resolve(projectRoot, '..', 'notes');
const targetRoot = resolve(projectRoot, 'src/content/notes');
const collections = ['knowledge', 'problems', 'projects', 'conversations', 'daily'];

const exists = async (path) => {
  try {
    await stat(path);
    return true;
  } catch {
    return false;
  }
};

const countMarkdown = async (directory) => {
  if (!(await exists(directory))) return 0;

  let total = 0;
  const entries = await readdir(directory, { withFileTypes: true });
  for (const entry of entries) {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) total += await countMarkdown(path);
    if (entry.isFile() && entry.name.endsWith('.md')) total += 1;
  }
  return total;
};

await rm(targetRoot, { recursive: true, force: true });
await mkdir(targetRoot, { recursive: true });
await writeFile(join(targetRoot, '.gitkeep'), '');

if (!(await exists(sourceRoot))) {
  console.warn(`[sync:notes] 内容源不存在：${sourceRoot}`);
  console.warn('[sync:notes] 保留空的 notes collection，站点仍可正常构建。');
  process.exit(0);
}

let copied = 0;
for (const collection of collections) {
  const source = join(sourceRoot, collection);
  if (!(await exists(source))) continue;

  const target = join(targetRoot, collection);
  await cp(source, target, {
    recursive: true,
    filter: (path) => !path.endsWith('.DS_Store'),
  });
  copied += await countMarkdown(target);
}

const figuresSource = join(sourceRoot, 'figures');
if (await exists(figuresSource)) {
  await cp(figuresSource, join(targetRoot, 'figures'), {
    recursive: true,
    filter: (path) => !path.endsWith('.DS_Store'),
  });
}

console.log(`[sync:notes] 已从 ${sourceRoot} 同步 ${copied} 篇 Markdown。`);
