import { getCollection, type CollectionEntry } from 'astro:content';

export type Note = CollectionEntry<'notes'>;

export const noteCategoryLabels: Record<string, string> = {
  knowledge: '知识与方案',
  problems: '问题复盘',
  projects: '项目实践',
  conversations: '交流记录',
  daily: '日常记录',
};

export const getNoteSlug = (note: Note): string => note.id.replace(/\.(md|mdx)$/i, '');

export const getNoteSourcePath = (note: Note): string => {
  const relativePath = note.filePath
    ?.replace(/\\/g, '/')
    .replace(/^src\/content\/notes\//, '');
  if (relativePath) return relativePath;
  return note.id.match(/\.(md|mdx)$/i) ? note.id : `${note.id}.md`;
};

export const getPublishedNotes = async (): Promise<Note[]> => {
  const now = Date.now();
  const notes = await getCollection(
    'notes',
    ({ data }) => data.visible && data.status === 'published' && data.date.getTime() <= now,
  );

  return notes.sort((a, b) => {
    const dateDifference = b.data.date.getTime() - a.data.date.getTime();
    return dateDifference || a.data.title.localeCompare(b.data.title, 'zh-CN');
  });
};

export const estimateReadingMinutes = (body = ''): number => {
  const content = body
    .replace(/^---[\s\S]*?---/m, '')
    .replace(/```[\s\S]*?```/g, '')
    .replace(/<[^>]+>/g, '')
    .trim();
  const chineseCharacters = (content.match(/[\u3400-\u9fff]/g) ?? []).length;
  const latinWords = (content.match(/[A-Za-z0-9]+(?:[-_'][A-Za-z0-9]+)*/g) ?? []).length;
  const minutes = chineseCharacters / 420 + latinWords / 220;
  return Math.max(1, Math.ceil(minutes));
};

export const getRelatedNotes = (current: Note, notes: Note[], limit = 3): Note[] => {
  const currentTags = new Set(current.data.tags.map((tag) => tag.toLowerCase()));

  return notes
    .filter((note) => note.id !== current.id)
    .map((note) => {
      const sharedTags = note.data.tags.filter((tag) => currentTags.has(tag.toLowerCase())).length;
      const sameCategory = note.data.category === current.data.category ? 2 : 0;
      return { note, score: sharedTags * 3 + sameCategory };
    })
    .filter(({ score }) => score > 0)
    .sort(
      (a, b) =>
        b.score - a.score || b.note.data.date.getTime() - a.note.data.date.getTime(),
    )
    .slice(0, limit)
    .map(({ note }) => note);
};
