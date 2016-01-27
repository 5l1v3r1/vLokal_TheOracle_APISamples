<?php
//////////////////////////////
// vLokal API Bridge Sample Code
/////////////////////////////

//API Auth Call

$user_agent = "vLokal PHP API Bridge - 1.0";
$url = "https://delivery.vlokal.com/accounts/login/?next=/";
$csrftoken = GetCSRFToken($url);
$sessionid = GetSession($url);

//API Auth
function GetSession($url)
{
	$username='test_business';
	$password='tb@vlokal';
	global $csrftoken;
	global $user_agent;
	$curl_handle = curl_init();
	$request_headers = array();
	$request_headers[] = 'User-Agent: '. $user_agent;
	$request_headers[] = 'Content-type: application/x-www-form-urlencoded';
	$request_headers[] = 'Cookie: csrftoken='.$csrftoken;

	$options = array
	(
	    CURLOPT_URL=>$url,
	    CURLOPT_HEADER=>true,
	    CURLOPT_RETURNTRANSFER=>true,
	    CURLOPT_FOLLOWLOCATION=>true,
	    CURLOPT_USERAGENT=>$user_agent,
	    CURLOPT_HTTPHEADER=> $request_headers,
	    CURLOPT_POST=>1,
	    CURLOPT_POSTFIELDS=>"username=".$username."&password=".$password."&csrfmiddlewaretoken=".$csrftoken."&next=/", 
	);
	curl_setopt_array($curl_handle,$options);
	$response = curl_exec($curl_handle);
	preg_match_all('/^Set-Cookie:\s*([^;]*)/mi', $response, $matches);
	$cookies = array();
	foreach($matches[1] as $item) {
	    parse_str($item, $cookie);
	    $cookies = array_merge($cookies, $cookie);
	}
	return $cookies['sessionid'];
}

//Function to get CSRF Token
function GetCSRFToken($url)
{
	global $user_agent; 	
	$curl_handle = curl_init();
	$options = array
	(
	    CURLOPT_URL=>$url,
	    CURLOPT_HEADER=>true,
	    CURLOPT_RETURNTRANSFER=>true,
	    CURLOPT_FOLLOWLOCATION=>true,
	    CURLOPT_USERAGENT=>$user_agent
	);
	curl_setopt_array($curl_handle,$options);
	$response = curl_exec($curl_handle);
	curl_close($curl_handle);
	preg_match_all('/^Set-Cookie:\s*([^;]*)/mi', $response, $matches);
	$cookies = array();
	foreach($matches[1] as $item) {
	    parse_str($item, $cookie);
	    $cookies = array_merge($cookies, $cookie);
	}
	return $cookies['csrftoken'];
}
//Returns the Header required for API Calls
function APIHeaders()
{
	global $csrftoken;
	global $sessionid;
	$request_headers = array();
	$request_headers[] = 'Content-type: application/json';
	$request_headers[] = 'Cookie: csrftoken='.$csrftoken.';sessionid='.$sessionid;
	$request_headers[] = 'X-CSRFToken: '.$csrftoken;
	return $request_headers;
}
//API Calls

//Create a New Order
function NewOrder($order)
{
	global $user_agent;
	$curl_handle = curl_init();
	$options = array
	(
	    CURLOPT_URL=>'http://delivery.vlokal.com/api/orders/',
	    CURLOPT_HEADER=>true,
	    CURLOPT_RETURNTRANSFER=>true,
	    CURLOPT_FOLLOWLOCATION=>true,
	    CURLOPT_USERAGENT=>$user_agent,
	    CURLOPT_HTTPHEADER=> APIHeaders(),
	    CURLOPT_POST=>1,
	    CURLOPT_POSTFIELDS=>$order,
	);
	curl_setopt_array($curl_handle,$options);
	$response = curl_exec($curl_handle);
	return $response;
}

//Sample Order Details
$order_details = <<<EOT
{
"delivery_address": {
"landmark": "Landmark",
"area": "Area",
"building": "Building"
},
"delivery_customer": {
"name": "Customer Name"
},
"delivery_mobile": {
"number": "9999999999"
},
"reference_id": "May be your order id",
"description": "Any special instructions to delivery boy",
"title": "Pick n Drop",
"requested_pickup_time": "2016-01-14 00:57:00",
"requested_delivery_time": "2016-01-14 01:27:00",
"payment": {
"amount": 100,
"mode": 1
}
}
EOT;

//Create a New Order and get the response back
echo NewOrder($order_details);

?>