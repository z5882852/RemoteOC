import { createRouter, createWebHistory } from 'vue-router';
import Index from '../pages/Index.vue';
import Items from '../pages/Items.vue';
import Cpus from '../pages/Cpus.vue';
import Settings from '../pages/Settings.vue';

const routes = [
  {
    path: '/',
    name: 'index',
    component: Index,
  },
  {
    path: '/items',
    name: 'items',
    component: Items,
  },
  {
    path: '/cpus',
    name: 'cpus',
    component: Cpus,
  },
  {
    path: '/settings',
    name: 'settings',
    component: Settings,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
