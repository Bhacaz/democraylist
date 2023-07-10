import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    toggleMenu() {
        const menu = document.querySelector("#modal-menu")
        menu.classList.toggle("is-active")
    }
}
