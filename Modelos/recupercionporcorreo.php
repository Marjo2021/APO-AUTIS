<?php
include_once "config.php";
?>


<?php
//librerias
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

if(isset($_POST['Nombre_usuario'])) { // if que verfica el nombre de usuario
    if(isset($_POST['Correo'])) { // if que captura el identificador del button que se presiono para enviar la solicitud de cambio de correo

       $Nombre_usuario=($_POST['Nombre_usuario']); // se captura el valor del nombre del usuario

session_start();
$_SESSION['Nombre_usuario'] = $Nombre_usuario; // para ser usado a lo largo del archivo
$consulta="SELECT * FROM tbl_usuario WHERE Nombre_usuario='$Nombre_usuario'"; 
        $existe=$conn->query($consulta);
        $filas=$existe->num_rows;
      

        if($filas==0){
            
            echo '<script>
            alert("Datos incorrectos");
            window.location="../Vistas/modulos/metodos_recuperar_clave.php";
                  </script>';
        } else{ //construir el query para traer el dato del correo al cual se enviara la clave de recuperacion
               $consultar_correo = "SELECT c.Correo_electronico  
               FROM tbl_persona p, tbl_correo c, tbl_usuario u
               where p.Cod_persona = c.Cod_persona
               AND p.Cod_persona = u.Cod_persona
               AND u.NOMBRE_USUARIO = '$Nombre_usuario'";    

                $revision_correo =$conn->query($consultar_correo);
                 //se hace la consulta a la base de datos
             if($revision_correo->num_rows>0){
                 
                 while($fila=$revision_correo->fetch_assoc()){
                  $correo= $fila['Correo_Electronico'];

                            echo '<script>
                            alert("Verifique su Correo se ha enviado la clave");
                         window.location="../login";
                               </script>';
               
                            require "PHPMailer/Exception.php"; // aqui se utliza la libreria de PHPMAILER
                            require "PHPMailer/PHPMailer.php";
                            require "PHPMailer/SMTP.php";


                            function contraseña_random($length=8) // FUNCION para generar la contraseña aleatoria
                                {
                                $charset=" /^(?=.[a-z])(?=.[A-Z])(?=.\d)(?=.[@$!%?&])[A-Za-z\d@$!%?&]/";
                                $Contraseña="";
                         
                                for ($i=0;$i < $length;$i++)
                                {
                                 $rand= rand() % strlen($charset);
                                 $Contraseña.= substr($charset,$rand,1);
                         
                                }
                                return $Contraseña;
                         
                                 }
                                 
                                $contra= (contraseña_random()) ; //se captura la contrasena generada

                            //Se construye el update para cambiar la contrasena anterior por generada Y el estado pasa a pendiente
                           $query_cambio="UPDATE tbl_usuario
                                          SET Contraseña='$Contraseña',
                                          Cod_estatus = 5
                                          WHERE Nombre_usuario= '$Nombre_usuario'";

                            

                            $contraseña_cambiada=$conn->query($query_cambio); // se hace elquery a la base de datos

                            $oMail= new PHPMailer(true);


                           // $parametros_mail="SELECT "

                            $oMail->isSMTP();
                            $oMail->Host='smtp-mail.gmail.com';
                            $oMail->Port=587;
                            $oMail->SMTPSecure="tls";
                            $oMail->SMTPAuth=true;

                            $oMail->Username="grupoa288@gmail.com";//  
                            $oMail->Password="Grupo4analisis";
                            $oMail->setFrom("grupoa288@gmail.com"); // direccion de correo de destino hacia los correos de usuarios
                            $oMail->addAddress($correo); //Variable que recoger el correo al que sera enviado la clave de recuperacion.
                            $mensaje="<h2>Hola, $usuario</h2> Usted ha realizado una solicitud de recuperación de contraseña:</p>
                            <p><h3>su nueva contraseña es: ".utf8_decode($contra)."</h3></p>
                            <p>Esta contraseña solo tiene validez por 24 horas desde su fecha de envio.</p>
                            
                            <a href='http://localhost/apoautis/index.php'>
                            <button class='btn btn-primary btn-flat'> Cambiar contraseña</button>
                            </a>
                            
                            <p><h3>Gracias</h3></p>
                                  
                           ";

                           $oMail->Subject=utf8_decode("RECUPERACION DE CONTRASEÑA");
                            $oMail->msgHTML(utf8_decode($mensaje));
                            if(!$oMail->send())
                            echo $oMail->ErrorInfo;
                 }

            }
                            else {
                                echo '<script>
                                    alert("Verifique su Correo esta malo");
                                window.location="../vistas/modulos/tipo_recuperacion.php";
                                        </script>';
                            }


        }






    }

}




?>