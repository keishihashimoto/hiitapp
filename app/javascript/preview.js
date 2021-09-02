const showPreview = () => {
  const menuIcon = document.getElementById("menu_icon")
  menuIcon.addEventListener("change", (e) => {
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

window.addEventListener("load", showPreview)