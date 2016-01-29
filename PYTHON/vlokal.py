import urllib2, urllib, cookielib
user_agent = "vLokal Python API Bridge - 1.0"
url = "https://delivery.vlokal.com/accounts/login/"

def find_between(s, first, last ):
    try:
        start = s.index( first ) + len( first )
        end = s.index( last, start )
        return s[start:end]
    except ValueError:
        return ""

def get_csrf_token(url):
   global user_agent
   request = urllib2.Request(url)
   request.add_header('User-Agent', user_agent)
   request.add_header('Referer', url)
   response = urllib2.urlopen(request)
   set_cookie = response.info().getheader('Set-Cookie')
   return find_between(set_cookie,"csrftoken=",";")

# Get CSRF Token
csrf_token = get_csrf_token(url)

def get_session_id(url):
   global user_agent
   global csrftoken
   cookieprocessor = urllib2.HTTPCookieProcessor()
   opener = urllib2.build_opener(cookieprocessor)
   urllib2.install_opener(opener)
   query_args = { 'username':'test_business', 'password':'tb@vlokal', 'csrfmiddlewaretoken':csrf_token, 'next':'/' }
   request = urllib2.Request(url)
   request.add_data(urllib.urlencode(query_args))
   request.add_header('User-Agent', user_agent)
   request.add_header('Referer', url)
   request.add_header('Content-type','application/x-www-form-urlencoded')
   request.add_header('Cookie','csrftoken='+csrf_token)
   response = urllib2.urlopen(request)
   for cookie in cookieprocessor.cookiejar:
      if cookie.name == "sessionid":
         break
   return cookie.value

# Get Session ID
session_id = get_session_id(url)

#Sample API Calls

def new_order(order):
   global csrf_token
   global session_id
   global user_agent
   url = "https://delivery.vlokal.com/api/orders/"
   request = urllib2.Request(url,order)
   request.add_header('User-Agent', user_agent)
   request.add_header('Referer', url)
   request.add_header('Content-type','application/json')
   request.add_header('Cookie','csrftoken='+csrf_token+';sessionid='+session_id)
   request.add_header('X-CSRFToken',csrf_token)
   contents = urllib2.urlopen(request).read()
   return contents

order_details = """{
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
}"""

print new_order(order_details)