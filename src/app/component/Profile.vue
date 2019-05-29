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
import Hola from "./Hola.vue";
//import Chao from "./Chao.vue";
export default {
  components: {
    navigation: Navigation
  },
  data() {
    return {
      message: "",
      error: false,
      userL: {
        id: "",
        name: "",
        fullname: ""
      }
    };
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
    selectFile() {
      this.file = this.$refs.file.files[0];
      (this.message = ""), (this.error = false);
    },
    sendFile() {
      const formData = new FormData();
      formData.append("file", this.file);
      this.$http
        .post("/links/upload", formData)
        .then(res => {
          //console.log(res);
          this.message = "file has been upload";
          this.file = "";
          this.error = false;
        })
        .catch(err => {
          //console.log(err, "aca");
          this.message = err.body.error;
          this.error = true;
          //console.log(err);
        });
    }
  },
  mounted() {
    //this.$store.commit("changeUser", JSON.parse(localStorage.getItem("user")));
  },
  watch: {
    user() {
      this.userL = this.user;
    }
  }
};
</script>

