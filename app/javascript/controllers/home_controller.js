import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    toggleMenu() {
        const menu = document.querySelector("#modal-menu")
        menu.classList.toggle("is-active")
    }

    connect() {
        fetch("/auth/user")
            .then(response => response.json())
            .then(data => localStorage.setItem("user", JSON.stringify(data.user)))
    }
}
