import type { APIRoute } from 'astro';
import { getNoteSlug, getPublishedNotes } from '../../lib/notes';

const escapeXml = (value: string): string =>
  value.replace(/[<>&'\"]/g, (character) => {
    const entities: Record<string, string> = {
      '<': '&lt;',
      '>': '&gt;',
      '&': '&amp;',
      "'": '&apos;',
      '"': '&quot;',
    };
    return entities[character];
  });

export const GET: APIRoute = async ({ site }) => {
  const baseUrl = site ?? new URL('https://zglab.fun');
  const notes = await getPublishedNotes();
  const items = notes
    .map((note) => {
      const url = new URL(`/notes/${getNoteSlug(note)}/`, baseUrl).toString();
      return `<item>
        <title>${escapeXml(note.data.title)}</title>
        <link>${escapeXml(url)}</link>
        <guid isPermaLink="true">${escapeXml(url)}</guid>
        <description>${escapeXml(note.data.summary)}</description>
        <pubDate>${note.data.date.toUTCString()}</pubDate>
      </item>`;
    })
    .join('\n');

  const xml = `<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
  <channel>
    <title>ZGLab Notes</title>
    <link>${escapeXml(new URL('/notes/', baseUrl).toString())}</link>
    <description>关于 AI 工程、Agent、软件开发、系统设计和项目复盘的长期技术笔记。</description>
    <language>zh-CN</language>
    ${items}
  </channel>
</rss>`;

  return new Response(xml, {
    headers: {
      'Content-Type': 'application/rss+xml; charset=utf-8',
      'Cache-Control': 'public, max-age=3600',
    },
  });
};
