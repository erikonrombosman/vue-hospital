import Vue from 'vue'
import App from './component/App.vue'

import VueRouter from 'vue-router'
import Landing from './component/Landing.vue'
import Login from './component/Login.vue'
import VueResource from 'vue-resource';
//import ToggleButton from 'vue-js-toggle-button'
import Bootstrap from 'bootstrap-vue'

Vue.use(Bootstrap)
//Vue.use(ToggleButton)
Vue.use(VueRouter)
Vue.use(VueResource)


Vue.config.productionTip = false
const routes = [
  {
    path: '/',
    component: Landing
  },
  {
    path: '/login',
    component: Login
  }
]
const router = new VueRouter({
  base: __dirname,
  routes: routes
})
new Vue({
  router,
  template: '<App/>',
  render: h => h(App)
}).$mount('#app')