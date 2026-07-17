export type RuntimeState = 'operational' | 'degraded' | 'offline' | 'unknown';

export interface ProjectRuntimeStatus {
  project: string;
  state: RuntimeState;
  version?: string;
  lastDeployedAt?: string;
  checkedAt?: string;
}

export interface GitHubRepositorySnapshot {
  repository: string;
  lastCommitAt?: string;
  defaultBranch?: string;
}
