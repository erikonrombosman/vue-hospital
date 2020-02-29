<template>
  <div>
    <navigation></navigation>
    <v-toolbar color="rgb(21,42,119)">
      <v-toolbar-title class="white--text">Hospital de Coquimbo</v-toolbar-title>
    </v-toolbar>
    <router-view></router-view>
    <!--<vue-dropzone ref="myVueDropzone" id="dropzone" :options="dropzoneOptions"></vue-dropzone>-->
  </div>
</template>

<script>
import router from "../index.js";
import Navigation from "./Navigation.vue";
//import Chao from "./Chao.vue";
export default {
  components: {
    navigation: Navigation
  },
  data() {
    return {};
  },
  computed: {
    user() {
      return this.$store.state.user;
    },
    menu() {
      console.log(this.$store.state.menu, "hasta acá funciona");
      return this.$store.state.menu;
    }
  },
  methods: {
    logout() {
      this.$http
        .get("/logout")
        .then(res => {
          //localStorage.setItem("jwt", null);
          localStorage.removeItem("user");
          this.$store.commit("changeUser", {});
          this.$store.commit("addMenu", []);
          //console.log(localStorage.getItem("user"), "saliendo");
          router.push("/login");
        })
        .catch(err => {
          //console.log("mala");
        });
    },
    checkPermision(){
      this.$http.get("/auth/authData")
      .then(res=>{
        console.log(res.body.user)
        if (res.body.user){
          console.log("entra");
        }else{
          this.logout()
        }
      })
      .catch(err=>{
        console.log(err)
      })
    }
  },
  mounted() {
    this.checkPermision();
    //this.$store.commit("changeUser", JSON.parse(localStorage.getItem("user")));
  },
  watch: {
    user() {
      this.userL = this.user;
    }
  }
};
</script>

