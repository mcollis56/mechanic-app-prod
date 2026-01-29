## Euro Motor Works Trial v1.0

# Mechanic Shop Management App

A comprehensive mechanic shop management application built with Vue 3, Vite, and Supabase. This application helps automotive repair shops manage customers, vehicles, work orders, service history, and invoicing with AI-powered features.

## 🚀 Features

### Core Modules

- **Customer Management** - Track customer information, contact details, and service history
- **Vehicle Management** - Comprehensive vehicle records with VIN, registration, and service history
- **Work Order System** - Kanban-style workflow board for managing jobs
- **Service History** - Complete maintenance records for each vehicle
- **Parts Tracking** - Track parts usage and costs for each job
- **Invoice Generation** - Create and manage invoices with PDF export
- **AI-Powered Notes** - Convert technician shorthand to customer-friendly notes

### Advanced Features

- **Role-Based Access Control** - Admin, Service Advisor, and Technician roles
- **Audit Logging** - Track all data modifications for compliance
- **Mobile-Friendly** - Responsive design optimized for tablets and phones
- **Offline Support** - Work offline and sync when connected
- **Photo Upload** - Attach photos to jobs and vehicles
- **Multi-Field Search** - Search by VIN, registration, customer name, etc.

## 📋 Tech Stack

- **Frontend**: Vue 3 + Vite + Tailwind CSS
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **AI Integration**: Claude API / OpenAI GPT (optional)
- **Calendar**: FullCalendar
- **PDF Generation**: jsPDF

## 🛠️ Setup Instructions

### Prerequisites

- Node.js 20.19.0 or higher
- npm or yarn
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd -mechanics-app-final
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add your Supabase credentials:
   ```
   VITE_SUPABASE_URL=your_supabase_url
   VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Set up the database**
   
   Run the migrations in order in your Supabase SQL editor:
   ```bash
   database/migrations/001_add_vehicles.sql
   database/migrations/002_enhance_jobs.sql
   database/migrations/003_service_history.sql
   database/migrations/004_parts_usage.sql
   database/migrations/005_audit_logs.sql
   database/migrations/006_rbac.sql
   database/migrations/007_enhance_customers.sql
   ```

5. **Start the development server**
   ```bash
   npm run dev
   ```

6. **Access the application**
   
   Open your browser to `http://localhost:5173`

## 📁 Project Structure

```
/MechanicApp/
  /database/
    /migrations/          # Database migration scripts
    schema.sql           # Complete database schema
  /src/
    /components/         # Reusable Vue components
      JobEditor.vue
      CustomerEditor.vue
      VehicleEditor.vue
      JobsBoard.vue
      ...
    /views/             # Page components
      JobsView.vue
      CustomersView.vue
      VehiclesView.vue
      InvoicesListView.vue
      ...
    /composables/       # Reusable composition functions
      useVehicles.js
      useJobs.js
      ...
    /services/          # Business logic and API calls
      aiService.js
      offlineService.js
      ...
    /layouts/           # Layout components
      MainLayout.vue
    /router/            # Vue Router configuration
      index.js
    /assets/            # Static assets
    supabaseClient.js   # Supabase client setup
    main.js             # Application entry point
    App.vue             # Root component
  /public/              # Public static files
  package.json
  vite.config.js
  tailwind.config.js
```

## 🗄️ Database Schema

### Main Tables

- **customers** - Customer information and contact details
- **vehicles** - Vehicle records linked to customers
- **jobs** - Work orders and service requests
- **service_history** - Historical service records
- **parts_usage** - Parts used in each job
- **invoices** - Invoice records
- **suppliers** - Parts suppliers
- **profiles** - User profiles with roles
- **audit_logs** - Audit trail for compliance

See `database/schema.sql` for complete schema details.

## 👥 User Roles

- **Admin** - Full system access, user management, settings
- **Service Advisor** - Manage jobs, customers, invoices
- **Technician** - View and update jobs, add notes

## 🤖 AI Integration (Optional)

The app supports AI-powered note enhancement to convert technician shorthand into customer-friendly descriptions.

1. **Choose your AI provider** (Claude or OpenAI)
2. **Add API key to `.env`**
   ```
   VITE_AI_ENABLED=true
   VITE_AI_PROVIDER=claude
   VITE_ANTHROPIC_API_KEY=your_api_key
   ```

3. **Use in the app**
   - Technicians write notes in shorthand
   - Click "Enhance with AI" button
   - Review and edit AI-generated customer notes

## 📱 Mobile Support

The app is fully responsive and optimized for:
- Desktop (1920x1080+)
- Tablets (768px+)
- Mobile phones (375px+)

Features on mobile:
- Large tap targets
- Camera integration for photos
- Offline mode with sync
- Bottom navigation

## 🧪 Development

### Run development server
```bash
npm run dev
```

### Build for production
```bash
npm run build
```

### Preview production build
```bash
npm run preview
```

## 📚 Documentation

- [User Guide](docs/USER_GUIDE.md) - End-user documentation
- [API Documentation](docs/API.md) - API reference
- [Database Schema](database/schema.sql) - Complete database schema

## 🔒 Security

- Row Level Security (RLS) enabled on all tables
- Role-based access control
- Audit logging for compliance
- Secure authentication via Supabase Auth

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## 📄 License

[Add your license here]

## 🆘 Support

For issues and questions:
- Check the [User Guide](docs/USER_GUIDE.md)
- Review database migrations in `/database/migrations`
- Contact your system administrator

## 🎯 Roadmap

- [ ] Inventory management
- [ ] SMS notifications
- [ ] Advanced reporting and analytics
- [ ] Integration with accounting software
- [ ] Mobile apps (iOS/Android)
- [ ] Multi-shop support

---

**Built with ❤️ for automotive repair professionals**
