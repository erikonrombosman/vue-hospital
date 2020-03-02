import Vue from 'vue'
import Vuex from 'vuex'
import Vuetify from 'vuetify'
import VueRouter from 'vue-router'
import Bootstrap from 'bootstrap-vue'
import VueResource from 'vue-resource';

import App from './component/App.vue'
import Login from './component/Login.vue'
import Profile from './component/Profile.vue'
import VerFichas from "./component/VerFicha.vue"
import VerUsuarios from "./component/VerUsuarios.vue"
import AgregarFicha from "./component/AgregarFicha.vue"
import VerPacientes from "./component/VerPacientes.vue"
import AgregarUsuario from "./component/AgregarUsuario.vue"
import VerMedicamentos from "./component/VerMedicamentos.vue"



//import ToggleButton from 'vue-js-toggle-button'


Vue.use(Vuetify)
Vue.use(Bootstrap)
//Vue.use(ToggleButton)

Vue.use(VueResource)
Vue.use(Vuex)

Vue.config.productionTip = false
const routes = [
  {
    path: '/',
    name: 'login',
    component: Login,
    meta: {
      guest: true
    }
  },
  {
    path: '/profile',
    name: 'profile',
    component: Profile,
    meta: {
      requiresAuth: true
    },
    children: [
      { path: '', component: VerPacientes, meta: { requiresAuth: true } },
      { path: 'agregar-ficha', component: AgregarFicha, meta: { requiresAuth: true } },
      { path: 'agregar-usuario', component: AgregarUsuario, meta: { requiresAuth: true, requiresAdmin: true} },
      { path: 'ver-medicamentos', component: VerMedicamentos, meta: { requiresAuth: true } },
      { path: 'ver-usuarios', component: VerUsuarios, meta: { requiresAuth: true, requiresAdmin: true } },
      { path: 'ver-fichas', component: VerFichas, meta: { requiresAuth: true} }
    ]
  }
]
function isAdmin(tipo){
  //console.log(tipo)
  if(tipo==="ADMIN" || tipo ==="ADMIN-ENF" || tipo==="ADMIN-MED"){
    return true
  }else{
    return false
  }
}

//intento dekldkl
const router = new VueRouter({
  //base: __dirname,
  routes: routes
})
Vue.use(VueRouter)
router.beforeEach((to, from, next) => {
  if (to.meta.requiresAuth) {
    let user = JSON.parse(localStorage.getItem('user'))
    let tipo = user.user_type_id
    if (user != null) {
      if(isAdmin(tipo) && to.meta.requiresAdmin){
        next()
      }else if(!isAdmin(tipo) && to.meta.requiresAdmin){
        next({
          path: '/profile',
          params: { nextUrl: to.fullPath }
        })
      }else{
        next()
      }
    } else {
      next({
        path: '/login',
        params: { nextUrl: to.fullPath }
      })
    }
  } else if (to.matched.some(record => record.meta.guest)) {
    let user = localStorage.getItem('user')
    if (user != null) {
      next({
        path: '/profile',
        params: { nextUrl: to.fullPath }
      })
    }else{
      next()
    }
  }
})

const store = new Vuex.Store({
  state: {
    user: { name: 'lalo landa' },
    menu: []
  },
  mutations: {
    changeUser(state, userP) {
      state.user = userP
    },
    addMenu(state, newMenu) {
      //console.log(newMenu, "mutation menu")
      state.menu = newMenu
    }
  }
})
new Vue({
  router,
  store,
  template: '<App/>',
  render: h => h(App)
}).$mount('#app')

export default router