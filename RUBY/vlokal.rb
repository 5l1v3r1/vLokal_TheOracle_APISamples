require "net/http"
require "uri"

$user_agent = "vLokal Ruby API Bridge - 1.0"
url= "https://delivery.vlokal.com/accounts/login/"

def get_csrf_token(url)
   uri = URI.parse(url)
   http = Net::HTTP.new(uri.host, uri.port)
   http.use_ssl = true
   request = Net::HTTP::Get.new(uri.request_uri)
   request.add_field('User-Agent', $user_agent)
   response = http.request(request)
   set_cookies = response["set-cookie"]
   starts = "csrftoken="
   ends = ";"
   return set_cookies[/#{starts}(.*?)#{ends}/m, 1]
end

#Get CSRF Token
$csrf_token = get_csrf_token(url)

def get_session_id(url)
   username = "test_business"
   password = "tb@vlokal"
   uri = URI.parse(url)
   http = Net::HTTP.new(uri.host, uri.port)
   http.use_ssl = true
   request = Net::HTTP::Post.new(uri.request_uri)
   request.add_field("User-Agent", $user_agent)
   request.add_field("Content-type", "application/x-www-form-urlencoded")
   request.add_field("Referer", url)
   request.add_field("Cookie","csrftoken=".concat($csrf_token) )
   request.set_form_data({"username" => username, "password" => password, "csrfmiddlewaretoken" => $csrf_token, "next" => "/"})
   response = http.request(request)
   set_cookies = response["set-cookie"]
   starts = "sessionid="
   ends = ";"
   return set_cookies[/#{starts}(.*?)#{ends}/m, 1]
end

#Get SESSIONID
$session_id = get_session_id(url)

#Sample API Call
def new_order(order)
   url ="https://delivery.vlokal.com/api/orders/"
   uri = URI.parse(url)
   http = Net::HTTP.new(uri.host, uri.port)
   http.use_ssl = true
   request = Net::HTTP::Post.new(uri.request_uri)
   request.body = order
   request.add_field("User-Agent", $user_agent)
   request.add_field("Content-type", "application/json")
   request.add_field("X-CSRFToken", $csrf_token)
   request.add_field("Referer", url)
   request.add_field("Cookie","csrftoken=".concat($csrf_token).concat(";sessionid=").concat($session_id))
   response = http.request(request)
   return response.body
end

order_details = '{
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
}'
#Calling New Order API
puts new_order(order_details)