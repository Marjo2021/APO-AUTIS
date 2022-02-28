/*========================================
Mostrar contraseña
==========================================*/
const mostrarClave=document.querySelectorAll('.mostrarClave');
const inputPass=document.querySelectorAll('.clave');

for (let i = 0; i < mostrarClave.length; i++) {

mostrarClave[i].addEventListener('click',()=>{

    if(inputPass[i].type==="password"){

        //cambiamos el tipo password a text
        inputPass[i].setAttribute('type','text');

        //removemos la clase del icono
        mostrarClave[i].classList.remove('fa-eye');

        //agregamos el nuevo icono
        mostrarClave[i].classList.add('fa-eye-slash');

        //le agregamos la clase active
        mostrarClave[i].classList.add('active');

    }else{
        //si el tipo de input es text

        //cambiamos el tipo text a password
        inputPass[i].setAttribute('type','password');

         //removemos la clase del icono
         mostrarClave[i].classList.remove('fa-eye-slash');

         //agregamos el nuevo icono
         mostrarClave[i].classList.add('fa-eye');

         //le agregamos la clase active
         mostrarClave[i].classList.remove('active');

    }

});
}