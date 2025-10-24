<html>
     <body>
          <?php
               include 'get-parameters.php';
               $_pick = $_POST['selection'];

               switch ($_pick) {
                    case "Q1":

                         include 'mobile.php';
                         break;

                    case "Q2":
                         include 'population.php';
                         break;

                    case "Q3":
                         include 'lifeexpectancy.php';
                         break;

                    case "Q4":
                         include 'gdp.php';
                         break;

                    case "Q5":
                         include 'mortality.php';
                         break;
               }
          ?>

          <div id="Copyright" class="center">
               <h5>&copy; 2020, Amazon Web Services, Inc. or its Affiliates. All rights reserved.</h5>
          </div>
     </body>
</html>
