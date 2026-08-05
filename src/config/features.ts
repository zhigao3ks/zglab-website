export type FeatureKey = 'notes' | 'tools' | 'runtimeStatus' | 'githubActivity' | 'downloadResume';

export const features: Record<FeatureKey, boolean> = {
  notes: true,
  tools: true,
  runtimeStatus: false,
  githubActivity: false,
  downloadResume: false,
};
