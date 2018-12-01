import Vue from 'vue'
import App from './app.vue'

function run() {
  const app = new Vue(
    Object.assign({}, App)
  )
  app.$mount('article.content')
}

run()
