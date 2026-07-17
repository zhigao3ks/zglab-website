import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';

const optionalUrl = z.url().optional();

const projects = defineCollection({
  loader: glob({ base: './src/content/projects', pattern: '**/*.md' }),
  schema: z.object({
    title: z.string(),
    slug: z.string().regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/),
    summary: z.string(),
    status: z
      .enum(['exploring', 'planned', 'building', 'completed', 'online', 'paused'])
      .optional(),
    progress: z.number().min(0).max(100).optional(),
    featured: z.boolean().default(false),
    visible: z.boolean().default(true),
    order: z.number().int().default(0),
    startedAt: z.coerce.date().optional(),
    updatedAt: z.coerce.date().optional(),
    categories: z.array(z.string()).default([]),
    tags: z.array(z.string()).default([]),
    stack: z.array(z.string()).default([]),
    cover: z.string().optional(),
    gallery: z.array(z.string()).default([]),
    highlights: z.array(z.string()).default([]),
    links: z
      .object({
        demo: optionalUrl,
        repository: optionalUrl,
        documentation: optionalUrl,
      })
      .default({}),
    runtime: z
      .object({
        enabled: z.boolean().default(false),
        statusEndpoint: z.string().optional(),
      })
      .default({ enabled: false }),
  }),
});

const logs = defineCollection({
  loader: glob({ base: './src/content/logs', pattern: '**/*.md' }),
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    summary: z.string(),
    visible: z.boolean().default(true),
    tags: z.array(z.string()).default([]),
  }),
});

export const collections = { projects, logs };
