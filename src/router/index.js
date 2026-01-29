import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from '@/supabaseClient' // adjust path if needed

import MainLayout from '@/layouts/MainLayout.vue'
import JobsView from '@/views/JobsView.vue'
import CalendarView from '@/views/CalendarView.vue'
import WorkOrdersView from '@/views/WorkOrdersView.vue'
import WorkOrderDetailView from '@/views/WorkOrderDetailView.vue' // NEW import

const AdminView = () => import('@/views/AdminView.vue')
const AdminSettingsView = () => import('@/views/AdminSettingsView.vue')
const InvoiceEditorView = () => import('@/views/InvoiceEditorView.vue')
const CustomersView = () => import('@/views/CustomersView.vue')
const VehiclesView = () => import('@/views/VehiclesView.vue')
const SuppliersView = () => import('@/views/SuppliersView.vue')
const ReportsView = () => import('@/views/ReportsView.vue')
const InvoicesListView = () => import('@/views/InvoicesListView.vue')
const JobArchiveView = () => import('@/views/JobArchiveView.vue')
const LoginView = () => import('@/views/LoginView.vue')
const InventoryView = () => import('@/views/InventoryView.vue')
const CustomerDetailView = () => import('@/views/CustomerDetailView.vue')
const WorkOrderCreateView = () => import('@/views/WorkOrderCreate.vue')

const routes = [
  {
    path: '/login',
    name: 'login',
    component: LoginView,
    meta: { requiresGuest: true }
  },
  {
    path: '/',
    component: MainLayout,
    meta: { requiresAuth: true },
    children: [
      { path: '', name: 'jobs', component: JobsView },
      { path: 'work-orders', name: 'work-orders', component: WorkOrdersView },
      { path: 'work-orders/create', name: 'work-order-create', component: WorkOrderCreateView },
      { path: 'work-orders/:id', name: 'work-order-detail', component: WorkOrderDetailView, props: true },
      { path: 'calendar', name: 'calendar', component: CalendarView },
      { path: 'customers', name: 'customers', component: CustomersView },
      { path: 'customers/:id', name: 'customer-detail', component: CustomerDetailView, props: true },
      { path: 'vehicles', name: 'vehicles', component: VehiclesView },
      { path: 'suppliers', name: 'suppliers', component: SuppliersView },
      { path: 'inventory', name: 'inventory', component: InventoryView },
      { path: 'reports', name: 'reports', component: ReportsView },
      { path: 'invoices', name: 'invoices', component: InvoicesListView },
      { path: 'invoice/:id', name: 'invoice', component: InvoiceEditorView, props: true },
      { path: 'archive', name: 'archive', component: JobArchiveView },
      {
        path: 'admin',
        name: 'admin',
        component: AdminView
      },
      {
        path: 'admin/settings',
        name: 'admin-settings',
        component: AdminSettingsView
      }
    ]
  },
  // catch-all route redirects unknown paths to home
  { path: '/:pathMatch(.*)*', redirect: '/' }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Global navigation guard for auth/guest routes
router.beforeEach(async (to, from, next) => {
  try {
    const {
      data: { user }
    } = await supabase.auth.getUser()

    if (to.meta.requiresAuth) {
      if (!user) {
        return next('/login')
      }
      return next()
    } else if (to.meta.requiresGuest) {
      if (user) {
        return next('/')
      }
      return next()
    }
    return next()
  } catch (error) {
    console.error('Navigation guard error:', error)
    next('/login')
  }
})

export default router
