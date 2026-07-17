import { features, type FeatureKey } from './features';

export interface NavigationItem {
  label: string;
  href: string;
  feature?: FeatureKey;
}

const navigation: NavigationItem[] = [
  { label: '首页', href: '/' },
  { label: '项目', href: '/projects' },
  { label: '研究', href: '/research' },
  { label: '想法', href: '/ideas' },
  { label: '关于', href: '/about' },
  { label: '笔记', href: '/notes', feature: 'notes' },
  { label: '工具', href: '/tools', feature: 'tools' },
];

export const visibleNavigation = navigation.filter(
  (item) => !item.feature || features[item.feature],
);
