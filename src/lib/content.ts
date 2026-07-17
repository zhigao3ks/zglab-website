import type { CollectionEntry } from 'astro:content';
import { getCollection } from 'astro:content';

export type Project = CollectionEntry<'projects'>;

export const getVisibleProjects = async (): Promise<Project[]> => {
  const projects = await getCollection('projects', ({ data }) => data.visible);
  return projects.sort((a, b) => a.data.order - b.data.order);
};
