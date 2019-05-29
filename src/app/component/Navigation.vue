<template>
  <v-navigation-drawer
    id="app-drawer"
    app
    dark
    floating
    persistent
    :mini-variant="mini"
    mobile-break-point="991"
    width="220"
    permanent
  >
    <v-list class="pa-1">
      <v-list-tile v-if="mini" @click.stop="mini = !mini">
        <v-list-tile-action>
          <v-icon>chevron_right</v-icon>
        </v-list-tile-action>
      </v-list-tile>

      <v-list-tile avatar tag="div">
        <v-list-tile-avatar>
          <img src="https://randomuser.me/api/portraits/men/85.jpg">
        </v-list-tile-avatar>

        <v-list-tile-content>
          <v-list-tile-title>{{user.nombre}}</v-list-tile-title>
        </v-list-tile-content>

        <v-list-tile-action>
          <v-btn icon @click.stop="mini = !mini">
            <v-icon>chevron_left</v-icon>
          </v-btn>
        </v-list-tile-action>
      </v-list-tile>
    </v-list>

    <v-divider></v-divider>


    <v-list dense class="pt-0">
      <v-list-tile v-for="item in menu" :key="item.text" @click="hola(item)">
          <v-list-tile-action>
            <v-icon>{{ item.icon }}</v-icon>
          </v-list-tile-action>
          <v-list-tile-content>
            <v-list-tile-title>{{ item.text }}</v-list-tile-title>
          </v-list-tile-content>
      </v-list-tile>

      <v-list-tile @click="logout()">
        <v-list-tile-action>
          <v-icon>exit_to_app</v-icon>
        </v-list-tile-action>
        <v-list-tile-title>Salir</v-list-tile-title>
      </v-list-tile>


    </v-list>
  </v-navigation-drawer>
</template>

<script>
export default {
  data() {
    return {
      mini: true,
      right: null
    };
  },
  computed: {
    user() {
      console.log(this.$store.state.user)
      return this.$store.state.user;
    },
    menu() {
      console.log(this.$store.state.menu, "en el navigation 2");
      return this.$store.state.menu;
    }
  },
  methods: {
    logout() {
      this.$http
        .get("/auth/logout")
        .then(res => {
          //localStorage.setItem("jwt", null);
          localStorage.removeItem("user");
          this.$store.commit("changeUser", {});
          this.$store.commit("addMenu", []);
          //console.log(localStorage.getItem("user"), "saliendo");
          this.$router.push("/login");
        })
        .catch(err => {
          //console.log("mala");
        });
    },
    hola(item){
      console.log(item.link)
      this.$router.push(item.link)
    }
  }
};
</script>
