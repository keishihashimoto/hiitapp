const showPreview = () => {
  const menuIcon = document.getElementById("menu_icon")
  menuIcon.addEventListener("change", (e) => {
    resetPreview()
    const file = e.target.files[0]
    const url = window.URL.createObjectURL(file)
    insertPreview(url)
  })
}

const insertPreview = (url) => {
  const html = `<div>
  <img src=${url}>
  </div>`
  document.getElementById("preview-container").insertAdjacentHTML("afterbegin", html)
}

const resetPreview = () => {
  const imgs = document.querySelectorAll("img")
  imgs.forEach ((img) => {
    img.removeAttribute("src")
  })
}

window.addEventListener("load", showPreview)