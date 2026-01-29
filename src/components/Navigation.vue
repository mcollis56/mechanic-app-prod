<template>
  <nav class="sidebar">
    <div class="logo">
      <h2>Euro Motor Works</h2>
    </div>
    <ul class="nav-menu">
      <li>
        <router-link to="/" class="nav-link">
          <i class="fas fa-tasks"></i>
          Jobs
        </router-link>
      </li>
      <li>
        <router-link to="/customers" class="nav-link">
          <i class="fas fa-users"></i>
          Customers
        </router-link>
      </li>
      <li>
        <router-link to="/reports" class="nav-link">
          <i class="fas fa-chart-bar"></i>
          Reports
        </router-link>
      </li>
    </ul>
  </nav>
</template>

<script>
export default {
  name: 'Navigation'
}
</script>

<style scoped>
.sidebar {
  position: fixed;
  left: 0;
  top: 0;
  width: 250px;
  height: 100vh;
  background: #2c3e50;
  color: white;
  z-index: 1000;
}

.logo {
  padding: 20px;
  border-bottom: 1px solid #34495e;
}

.logo h2 {
  color: #3498db;
}

.nav-menu {
  list-style: none;
  padding: 20px 0;
}

.nav-link {
  display: flex;
  align-items: center;
  padding: 15px 20px;
  color: #bdc3c7;
  text-decoration: none;
  transition: all 0.3s;
}

.nav-link:hover,
.nav-link.router-link-active {
  background: #34495e;
  color: #3498db;
}

.nav-link i {
  margin-right: 10px;
  width: 20px;
}
</style>