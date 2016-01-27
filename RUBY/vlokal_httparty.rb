require 'httparty'

$user_agent = "vLokal Ruby API Bridge - 1.0"
url= "https://delivery.vlokal.com/accounts/login/"

def get_csrf_token(url)
   response = HTTParty.get(url,
    headers: { "User-Agent" => $user_agent })
   set_cookies = response.headers["set-cookie"]
   starts = "csrftoken="
   ends = ";"
   return set_cookies[/#{starts}(.*?)#{ends}/m, 1]
end

#Get CSRF Token
$csrf_token = get_csrf_token(url)

def get_session_id(url)
   username = "test_business"
   password = "tb@vlokal"
   response = HTTParty.post(url, 
   	cookies: { "csrftoken" => $csrf_token },
   	body: { "username" => username, "password" => password, "csrfmiddlewaretoken" => $csrf_token, "next" => "/" }, 
   	headers: { "User-Agent" => $user_agent, "Content-type" => "application/x-www-form-urlencoded", "Referer" => url},
      follow_redirects: false)
   set_cookies = response.headers["set-cookie"]
   starts = "sessionid="
   ends = ";"
   return set_cookies[/#{starts}(.*?)#{ends}/m, 1]
end

#Get SESSIONID
$session_id = get_session_id(url)

def api_headers()
   return { "User-Agent" => $user_agent, "Content-type" => "application/json", "X-CSRFToken" => $csrf_token }
end

#Sample API Call
def new_order(order)
   url ="http://delivery.vlokal.com/api/orders/"
   response = HTTParty.post(url, 
      cookies: { "csrftoken" => $csrf_token, "sessionid" => $session_id },
      body: order, 
      headers: api_headers())
   return response.body
end

order_details = <<-JSON
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
JSON
#Calling New Order API
puts new_order(order_details)