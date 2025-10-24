<?php
        # Retrieve settings from Parameter Store
        error_log('Retrieving settings');
        require 'aws-autoloader.php';
      
        #$az = file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone');

        $ch = curl_init();

        // get a valid TOKEN
        $headers = array (
                'X-aws-ec2-metadata-token-ttl-seconds: 21600' );
        $url = "http://169.254.169.254/latest/api/token";
        #echo "URL ==> " .  $url;
        curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers );
        curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );
        curl_setopt( $ch, CURLOPT_CUSTOMREQUEST, "PUT" );
        curl_setopt( $ch, CURLOPT_URL, $url );
        $token = curl_exec( $ch );
        
        #echo "<p> TOKEN :" . $token;
        // then get metadata of the current instance 
        $headers = array (
                'X-aws-ec2-metadata-token: '.$token );
        
        $url = "http://169.254.169.254/latest/meta-data/placement/availability-zone";
        
        curl_setopt( $ch, CURLOPT_URL, $url );
        curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers );
        curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );
        curl_setopt( $ch, CURLOPT_CUSTOMREQUEST, "GET" );
        $result = curl_exec( $ch );
        $az = curl_exec( $ch );
        
        #echo "<p> RESULT :" . $result;

        $region = substr($az, 0, -1);
        
        try {
        $secrets_client = new Aws\SecretsManager\SecretsManagerClient([
          'version' => 'latest',
          'region'  => $region
        ]);
        #fetch the endpoint ep
        $rds_client = new  Aws\Rds\RdsClient([
          'version' => 'latest',
          'region'  => $region
        ]);
        $dbresult = $rds_client->describeDBInstances();
        $dbresult = $dbresult['DBInstances'][0]['Endpoint']['Address'];
        $ep = $dbresult;
        #echo $ep;
        #
        #fetch secrets for the endpoint
        $secretresults = $secrets_client->listSecrets(array(
          ['Key'=>['name'],
          'Values'=>['rds!']
          ])
          );
          $result = $secrets_client->getSecretValue([
            'SecretId' => $secretresults['SecretList'][0]['Name'],
        ]);
        $result = $result['SecretString'];
        $result = json_decode($result, true);
  #      echo $result;

        #$result = $result['SecretString'];
   #     print($result);
        #$result = json_decode($result, true);
        $un = $result['username'];
        $pw = $result['password'];
        $db = 'countries';

        }
        catch (Exception $e) {
          $ep = '';
          $db = '';
          $un = '';
          $pw = '';
        }
      error_log('Settings are: ' . $ep. " / " . $db . " / " . $un . " / " . $pw);
      #echo " Check your Database settings ";
      ?>
