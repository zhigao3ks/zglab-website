import type { APIRoute } from 'astro';
import { getCollection } from 'astro:content';
import { getNoteSlug, getPublishedNotes } from '../lib/notes';

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
  const fixedPaths = ['/', '/projects/', '/research/', '/ideas/', '/about/', '/notes/'];
  const projects = await getCollection('projects', ({ data }) => data.visible);
  const notes = await getPublishedNotes();

  const entries: Array<{ path: string; lastmod?: Date }> = [
    ...fixedPaths.map((path) => ({ path })),
    ...projects.map((project) => ({
      path: `/projects/${project.data.slug}/`,
      lastmod: project.data.updatedAt,
    })),
    ...notes.map((note) => ({
      path: `/notes/${getNoteSlug(note)}/`,
      lastmod: note.data.updated ?? note.data.date,
    })),
  ];

  const urls = entries
    .map(
      ({ path, lastmod }) => `<url>
    <loc>${escapeXml(new URL(path, baseUrl).toString())}</loc>${
      lastmod ? `\n    <lastmod>${lastmod.toISOString()}</lastmod>` : ''
    }
  </url>`,
    )
    .join('\n');

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls}
</urlset>`;

  return new Response(xml, {
    headers: {
      'Content-Type': 'application/xml; charset=utf-8',
      'Cache-Control': 'public, max-age=3600',
    },
  });
};
