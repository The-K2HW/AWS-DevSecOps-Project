<html>
<head>
<meta charset="UTF-8">
<title>Query Page</title>
<link rel="stylesheet" href="css/styles.css">
</head>


<body class="bodyStyle">
	

	<div id="header" class="mainHeader">
		<hr>
		<div class="center"><H1>Example Social Research Organization</H1></div>
	</div>
	<br>
		<hr>
		<div class="center"><H2>Country Data Query Page</H2></div>
	</div>
	<br>
		<H2><a href="index.php">Home</a></H2>
		
	</div>
	
	<H2>Please select which query you want to run.</H2>
	<form id="form1" method="post" action='query2.php'>
	<select name="selection">
	 <option value="">Select...</option>     
     <option value='Q1'>Mobile phones</option>  
     <option value='Q2'>Population</option>
     <option value='Q3'>Life Expectancy</option>
     <option value='Q4'>GDP</option>
     <option value='Q5'>Childhood Mortality</option>
     
   </select>
   
   <input type="submit" value="Submit">
   </form>
 
<br>
<div id="Copyright" class="center">
    <h5>&copy; 2020, Amazon Web Services, Inc. or its Affiliates. All rights
        reserved.</h5>
</div>

</body>
</html>