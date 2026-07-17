import { z } from 'astro/zod';
import { parse } from 'yaml';
import profileSource from '../data/profile.yaml?raw';
import skillsSource from '../data/skills.yaml?raw';
import publicationsSource from '../data/publications.yaml?raw';
import awardsSource from '../data/awards.yaml?raw';
import ideasSource from '../data/ideas.yaml?raw';
import nowSource from '../data/now.yaml?raw';
import timelineSource from '../data/timeline.yaml?raw';

const profileSchema = z.object({
  name: z.string(),
  nameEn: z.string().optional(),
  role: z.string(),
  school: z.string().optional(),
  status: z.string(),
  statusEn: z.string(),
  headline: z.string(),
  intro: z.string(),
  bio: z.array(z.string()),
  directions: z.array(z.string()),
  researchThreads: z.array(
    z.object({
      id: z.string(),
      title: z.string(),
      summary: z.string(),
    }),
  ),
  github: z.url().optional(),
  email: z.email().optional(),
  website: z.url().optional(),
  avatar: z.string().optional(),
  avatarAlt: z.string().optional(),
});

const skillsSchema = z.array(
  z.object({
    id: z.string(),
    title: z.string(),
    description: z.string(),
    keywords: z.array(z.string()),
  }),
);

const publicationsSchema = z.array(
  z.object({
    id: z.string(),
    title: z.string(),
    journal: z.string(),
    level: z.string(),
    note: z.string().optional(),
    role: z.string(),
    status: z.enum(['Published', 'Under Review / 在投']),
    summary: z.string(),
  }),
);

const awardsSchema = z.array(
  z.object({
    id: z.string(),
    name: z.string(),
    task: z.string(),
    result: z.string(),
    level: z.string(),
    summary: z.string(),
  }),
);

export const ideaStatuses = [
  'exploring',
  'planned',
  'building',
  'online',
  'paused',
  'archived',
] as const;

const ideasSchema = z.array(
  z.object({
    id: z.string(),
    title: z.string(),
    summary: z.string(),
    status: z.enum(ideaStatuses),
    createdAt: z.coerce.date(),
    tags: z.array(z.string()).default([]),
    relatedProject: z.string().optional(),
    visible: z.boolean().default(true),
  }),
);

const nowSchema = z.object({
  currentProject: z.string().optional(),
  eyebrow: z.string(),
  title: z.string(),
  problem: z.string(),
  recentUpdate: z.string(),
  principles: z.array(z.string()),
});

const timelineSchema = z.array(
  z.object({
    id: z.string(),
    marker: z.string(),
    title: z.string(),
    summary: z.string(),
    type: z.enum(['lab', 'project', 'research']),
    visible: z.boolean().default(true),
  }),
);

const load = <T>(source: string, schema: z.ZodType<T>): T => schema.parse(parse(source));

export const profile = load(profileSource, profileSchema);
export const skills = load(skillsSource, skillsSchema);
export const publications = load(publicationsSource, publicationsSchema);
export const awards = load(awardsSource, awardsSchema);
export const ideas = load(ideasSource, ideasSchema);
export const now = load(nowSource, nowSchema);
export const timeline = load(timelineSource, timelineSchema);

export type Profile = z.infer<typeof profileSchema>;
export type SkillGroup = z.infer<typeof skillsSchema>[number];
export type Publication = z.infer<typeof publicationsSchema>[number];
export type Award = z.infer<typeof awardsSchema>[number];
export type Idea = z.infer<typeof ideasSchema>[number];
