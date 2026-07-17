import type { GitHubRepositorySnapshot, ProjectRuntimeStatus } from '../types/runtime';

const statusApiBaseUrl = import.meta.env.PUBLIC_STATUS_API_BASE_URL?.trim();
const githubProxyUrl = import.meta.env.PUBLIC_GITHUB_PROXY_URL?.trim();

const fetchJson = async <T>(url: string): Promise<T | null> => {
  try {
    const response = await fetch(url, { headers: { Accept: 'application/json' } });
    if (!response.ok) return null;
    return (await response.json()) as T;
  } catch {
    return null;
  }
};

export const getProjectRuntimeStatus = async (
  endpoint: string | undefined,
): Promise<ProjectRuntimeStatus | null> => {
  if (!statusApiBaseUrl || !endpoint) return null;
  const url = new URL(endpoint.replace(/^\//, ''), `${statusApiBaseUrl.replace(/\/$/, '')}/`);
  return fetchJson<ProjectRuntimeStatus>(url.toString());
};

export const getGitHubRepositorySnapshot = async (
  repository: string | undefined,
): Promise<GitHubRepositorySnapshot | null> => {
  if (!githubProxyUrl || !repository) return null;
  const url = new URL(githubProxyUrl);
  url.searchParams.set('repository', repository);
  return fetchJson<GitHubRepositorySnapshot>(url.toString());
};
