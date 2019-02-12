<template>
  <div>
    <nav class="navbar navbar-expand-lg navbar-light fixed-top" id="mainNav">
      <div class="container">
        <a class="navbar-brand js-scroll-trigger" href="#page-top">Start Bootstrap</a>
        <button
          class="navbar-toggler navbar-toggler-right"
          type="button"
          data-toggle="collapse"
          data-target="#navbarResponsive"
          aria-controls="navbarResponsive"
          aria-expanded="false"
          aria-label="Toggle navigation"
        >
          <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarResponsive">
          <ul class="navbar-nav ml-auto">
            <li class="nav-item">
              <a class="nav-link js-scroll-trigger" href="#about">About</a>
            </li>
            <li class="nav-item">
              <a class="nav-link js-scroll-trigger" href="#services">Services</a>
            </li>
            <li class="nav-item">
              <a class="nav-link js-scroll-trigger" href="#portfolio">Portfolio</a>
            </li>
            <li class="nav-item">
              <a class="nav-link js-scroll-trigger" href="#contact">Contact</a>
            </li>
          </ul>
        </div>
      </div>
    </nav>

    <header class="masthead text-center text-white d-flex">
      <div class="container my-auto">
        <div class="row">
          <div class="col-lg-10 mx-auto">
            <h1 class="text-uppercase">
              <strong>Your Favorite Source of Free Bootstrap Themes</strong>
            </h1>
            <hr>
          </div>
          <div class="col-lg-8 mx-auto">
            <p class="text-faded mb-5">
              Start Bootstrap can help you build better websites using the Bootstrap CSS
              framework! Just download your template and start going, no strings attached!
            </p>
            <a class="btn btn-primary btn-xl js-scroll-trigger" href="#portfolio">Find Out More</a>
          </div>
        </div>
      </div>
    </header>

    <section class="p-0" id="portfolio">
      <div class="container-fluid p-0">
        <div class="row no-gutters popup-gallery">
          <div class="col-lg-4 col-sm-6" v-for="item in cabanias" :item="item">
            <a class="portfolio-box" :href="item.hrefc">
              <img class="img-fluid" :src="item.srcc" alt>
              <div class="portfolio-box-caption">
                <div class="portfolio-box-caption-content">
                  <div class="project-category text-faded">{{item.category}}</div>
                  <div class="project-name">{{item.name}}</div>
                </div>
              </div>
            </a>
          </div>
        </div>
      </div>
    </section>

    <section id="contact">
      <div class="container">
        <div class="row">
          <div class="col-lg-8 mx-auto text-center">
            <h2 class="section-heading">Let's Get In Touch!</h2>
            <hr class="my-4">
            <p class="mb-5">
              Ready to start your next project with us? That's great! Give us a call or send us an email
              and we will get back to you as soon as possible!
            </p>
          </div>
        </div>
        <div class="row">
          <div class="col-lg-4 ml-auto text-center">
            <i class="fas fa-phone fa-3x mb-3 sr-contact-1"></i>
            <p>123-456-6789</p>
          </div>
          <div class="col-lg-4 mr-auto text-center">
            <i class="fas fa-envelope fa-3x mb-3 sr-contact-2"></i>
            <p>
              <a href="mailto:your-email@your-domain.com">feedback@startbootstrap.com</a>
            </p>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script>
export default {
  data() {
    return {
      cabanias: [
        {
          hrefc: "img/portfolio/fullsize/1.jpg",
          srcc: "img/portfolio/thumbnails/1.jpg",
          category: "category1",
          name: "name1"
        },
        {
          hrefc: "img/portfolio/fullsize/2.jpg",
          srcc: "img/portfolio/thumbnails/2.jpg",
          category: "category2",
          name: "name2"
        },
        {
          hrefc: "img/portfolio/fullsize/3.jpg",
          srcc: "img/portfolio/thumbnails/3.jpg",
          category: "category3",
          name: "name3"
        },
        {
          hrefc: "img/portfolio/fullsize/4.jpg",
          srcc: "img/portfolio/thumbnails/4.jpg",
          category: "category4",
          name: "name4"
        },
        {
          hrefc: "img/portfolio/fullsize/5.jpg",
          srcc: "img/portfolio/thumbnails/5.jpg",
          category: "category5",
          name: "name5"
        }
      ]
    };
  }
};
</script>

