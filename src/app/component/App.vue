<template>
  <div id="app">
    <v-app>
      <v-content>
        <router-view></router-view>
      </v-content>
    </v-app>
  </div>
</template>

<script>
import Landing from "./Landing.vue";
import Login from "./Login.vue";
import Profile from "./Profile.vue";
export default {
  name: "app",
  components: {
    landing: Landing,
    login: Login,
    profile: Profile
  },
  mounted() {
    this.$store.commit("changeUser", JSON.parse(localStorage.getItem("user")));
    this.$store.commit("addMenu", JSON.parse(localStorage.getItem("menu")));
  }
};
</script>

