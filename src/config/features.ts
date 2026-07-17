export type FeatureKey = 'notes' | 'tools' | 'runtimeStatus' | 'githubActivity' | 'downloadResume';

export const features: Record<FeatureKey, boolean> = {
  notes: false,
  tools: false,
  runtimeStatus: false,
  githubActivity: false,
  downloadResume: false,
};
