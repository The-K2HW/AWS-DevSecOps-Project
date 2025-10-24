<a href="query.php">Pick another query</a>

 <?php
        //SQL to get birthrate and life expectancy
        $sql = "select name, birthrate, lifeexpectancy from countrydata_final;";
        $conn = new mysqli($_SESSION['ep'], $_SESSION['un'], $_SESSION['pw'], $_SESSION['db']);
        if ($conn->connect_error) {
            error_log('Connection error: ' . $conn->connect_error);
            var_dump('Connection error: ' . $conn->connect_error);
        }
        else {
          $result = $conn->query($sql);
          if ($result->num_rows > 0) {
              //echo "success";
              echo '<table style="width: 100%">';
              echo '<tr>';
              echo '<th style="text-align:left">Country Name</th>';
              echo '<th style="text-align:left">Birth Rate</th>';

              echo '<th style="text-align:left">Life Expectancy</th>';
              echo '</tr>';

              while($row = $result->fetch_assoc()) {
              //echo '<p>';

              echo '<tr>';
              echo '<td>';
              echo $row["name"];
              echo '&nbsp';
              echo '<td>';
              echo $row["birthrate"];
              echo '&nbsp';
              echo '<td>';
              echo $row["lifeexpectancy"];
              echo '&nbsp';
              echo '<br';
              echo '</tr>';
              }
              echo '</table>';
          }
        }
    ?>
