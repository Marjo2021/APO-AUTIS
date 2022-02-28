
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="initial-scale=1.0, width=device-width"/>
    <meta http-equiv="X-UA-Compatible" content="ie-edge">
    <title>Inicio de Sesión</title>

    <!--Fuentes de tipo de letras Iconografia-->

    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.1/css/all.css">
    <link href="https://fonts.googleapis.com/css2?family=Lato:wght@300;400;700&display=swap" rel="stylesheet">

    <!--Mis estilos-->

    <link rel="stylesheet" href="css/estilos.css">

</head>
<body>
    
    <div class="contenedor-login">

        <!--Slider-->
        <div class="contenedor-slider">
            <div class="slider">

                <!--Slide 1-->
                <div class="slide fade">
                    <img src="img/nuevo.jpeg" alt="">

                    <div class="contenido-slider">

                        

                    </div>

                </div>

                <!--Slide 2-->
                <div class="slide fade">
                    <img src="img/vision.jpeg" alt="">

                </div>
                <!--Slide 2-->
                <div class="slide fade">
                    <img src="img/mision.jpeg" alt="">

                </div>

            </div>
            <!--dots-->
            <div class="dots">

                <!--<span class="dot active"></span>-->

            </div>

        </div>

        <!--Formulario-->

        <div class="contenedor-texto">

            <div class="contenedor-form">

                <h1 class="titutlo">INICIO DE SESIÓN</h1>
                
                

                <!--Formulario de login-->

                <form action="validaradmin.php" method="POST"  class="formulario active">

                    <div class="error-text">
                        <p>aqui los errores del formulario</p>
                    </div>

                    <input type="text" placeholder="Ingresa tu nombre de usuario" name="Nombre_usuario" autocomplete="off" onkeypress=" solo_letras(cadena);" required onblur="quitarespacios(this);"  oncopy="return false" onpaste="return false" minlength="5" maxlength="10"  onkeyup="mayus(this);" onKeyDown="sinespacio(this);" class="input-text"  required />
                    <div class="grupo-input">

                        <input type="Password" placeholder="Ingresa tu Contraseña" name="Contrasena" required onblur="quitarespacios(this);" onkeyup="sinespacio(this);"  minlength="8" maxlength="30" class="input-text clave" required />
                        <button type="button" class="icono fas fa-eye mostrarClave"></button>

                    </div>

                    <a href="recuperar_contraseña_opc.php" class="link">¿Olvidaste la Contraseña?</a>
                    <!--BOTONES PARA INICIAR SESIÓN Y REGISTRARSE-->
                    <input type="submit" value="Iniciar Sesión" name="signin" class="btn solid" >
                    <input type="submit" value="Registrarse" name="signin" class="btn solid" onclick= "location.href='agregarusuario.php'" />
                </form>
                    
            </div>

        </div>

    </div>

    <!--Scripts-->

    <script >
          /*========================================
Slider
==========================================*/
if(document.querySelector('.contenedor-slider')){

let index=1;
let selectedIndex=1;

const slides=document.querySelector('.slider');
const slide=slides.children;
const slidesTotal=slides.childElementCount;

const dots=document.querySelector('.dots');
const prev=document.querySelector('.prev');
const next=document.querySelector('.next');


//agregamos los punto de acuerdo a la cantidad de slides
for (let i = 0; i < slidesTotal; i++) {
    dots.innerHTML +='<span class="dot"></span>';
}

//ejecutamos la funcion
mostrarSlider(index);

//hacemos que nuestro slide sea automatico
setInterval(()=>{
    mostrarSlider(index=selectedIndex);
},5000); //rempresentados en milesegundos

//funcion para mostrar el slider
function mostrarSlider(num){
    if(selectedIndex > slidesTotal){
        selectedIndex=1;
    }else{
        selectedIndex++;
    }

    if(num > slidesTotal){
        index=1;
    }

    if(num<1){
        index=slidesTotal;
    }

    //removemos la clase active de todos los slide
    for(let i=0; i<slidesTotal;i++){
        slide[i].classList.remove('active');
    }

    //removemos la clase active de los puntos

    for (let x = 0; x < dots.children.length; x++) {
        dots.children[x].classList.remove('active');
    }

    //mostramos el slide
    slide[index-1].classList.add('active');

    //agregamos la clase active al punto donde se encuntra el slide
    dots.children[index-1].classList.add('active');

    
}



//puntos
for (let y = 0; y < dots.children.length; y++) {
    
    //por cada dot que ecuentre le agregamos el evento click y ejecutamo la funcion de slide
    dots.children[y].addEventListener('click',()=>{
        mostrarSlider(index=y+1);
        selectedIndex=y+1;
    });
}

}


/*========================================
Tabs Formulario
==========================================*/
const tabLink=document.querySelectorAll('.tab-link');
const formularios=document.querySelectorAll('.formulario');

for (let x = 0; x < tabLink.length; x++) {

tabLink[x].addEventListener('click',()=>{

    //removemos la clase active de todos los tabs encotrados
    tabLink.forEach((tab)=> tab.classList.remove('active'));

    //le agregamos la clase active al tab que se le hizo click
    tabLink[x].classList.add('active');

    //mostramos el formulario correspondiente
    //para los formularios funciona exactamente los mismo que los tabs
    formularios.forEach((form)=>form.classList.remove('active'));
    formularios[x].classList.add('active');
   
})
}


    </script>


  <!--Scripts de validaciones-->  
</script>
/*
    CREAMOS FUNCIONES PARA MOSTRAR ERROR EN PANTALLA Y ADEMAS VALIDAR SI LOS CAMPOS SON INGRESADOS CORECTAMENTE
*/

    //  validaciones de formulario
    //validacion para que el nombre de usuario se escriba en mayuscula

<script type="text/javascript">
   function mayus(e) {
   e.value = e.value.toUpperCase();
}
</script>


<script type="text/javascript">

function sinespacio(e) {

  var cadena =  e.value;
  var limpia = "";
  var parts = cadena.split(" ");
  var length = parts.length;

  for (var i = 0; i < length; i++) {
    nuevacadena = parts[i];
    subcadena = nuevacadena.trim();

    if(subcadena != "") {
      limpia += subcadena + " ";
    }
  }

  limpia = limpia.trim();
  e.value = limpia;

};

</script>

<script type="text/javascript">

function quitarespacios(e) {

  var cadena =  e.value;
  cadena = cadena.trim();

  e.value = cadena;

};

</script>
<script>

function solo_letras($cadena){
$permitidos = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ";
for ($i=0; $i<strlen($cadena); $i++){
if (strpos($permitidos, substr($cadena,$i,1))===false){
//no es válido;
return false;
}
} 
//si estoy aqui es que todos los caracteres son validos
return true;
} 
  function soloLetras(e){
      key = e.keyCode || e.which;
      tecla = String.fromCharCode(key).toLowerCase();
      letras = " áéíóúabcdefghijklmnñopqrstuvwxyz";
      especiales = ["8-37-39-46"];

       tecla_especial = false
      for(var i in especiales){
      if(key == especiales[i]){
         tecla_especial = true;
      break;
    }
  }

  if(letras.indexOf(tecla)==-1 && !tecla_especial){
    return false;
  }
}
function soloNumeros_tel(e)
{
        // capturamos la tecla pulsada
        var teclaPulsada=window.event ? window.event.keyCode:e.which;
        // capturamos el contenido del input
        var valor=document.getElementById("tele").value;

        if(valor.length<9)
        {
            // 13 = tecla enter
            // Si el usuario pulsa la tecla enter o el punto y no hay ningun otro
            // punto
            if(teclaPulsada==9)
            {
              return true;
            }

            // devolvemos true o false dependiendo de si es numerico o no
            return /\d/.test(String.fromCharCode(teclaPulsada));
          }else{
            return false;
          }
        }
      </script>

      <script type="text/javascript"> function solonumeros(e) {
       tecla = (document.all) ? e.keyCode : e.which;
       if (tecla==8) return true;
       else if (tecla==0||tecla==9)  return true;
          // patron =/[0-9\s]/;// -> solo letras
          patron =/[0-9\s]/;// -> solo numeros
          te = String.fromCharCode(tecla);
          return patron.test(te);
        }
      </script>
      <script type="text/javascript">

        function quitarespacios(e) {

          var cadena =  e.value;
          cadena = cadena.trim();

          e.value = cadena;

        };

      </script>
    </div>
   
  </div>
  
</div>
        
</script>  

<!--Script para mandar a llamar la validacion de mostrar contraseña-->
<script src="js/app.js"></script>

</body>

</html>