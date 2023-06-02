import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    toggleMenu() {
        console.log('toggle menu')
        const menu = document.querySelector("#modal-menu")
        menu.classList.toggle("is-active")
    }

    connect() {
        console.log("Hello, Stimulus!", this.element)
    }
}
