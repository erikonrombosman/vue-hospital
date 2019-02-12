<template>
  <div>
    <router-view></router-view>
  </div>
</template>

<script>
import Landing from "./Landing.vue";
import Login from "./Login.vue";
export default {
  name: "app",
  components: {
    landing: Landing,
    login: Login
  }
};
</script>

