import requests
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
	headers = {'User-Agent': user_agent, 'Referer': url}
	r = requests.get(url,headers=headers)
	set_cookie = r.headers['Set-Cookie']
	return find_between(set_cookie,"csrftoken=",";")

# Get CSRF Token
csrf_token = get_csrf_token(url)

def get_session_id(url):
	global user_agent
	global csrftoken
	payload = { 'username':'test_business', 'password':'tb@vlokal', 'csrfmiddlewaretoken':csrf_token, 'next':'/' }
	headers = { 'Content-type': 'application/x-www-form-urlencoded', 'User-Agent': user_agent, 'Referer': url, 'Cookie': 'csrftoken='+csrf_token }
	r = requests.post(url, data=payload, headers=headers, allow_redirects=False)
	set_cookie = r.headers['Set-Cookie']
	return find_between(set_cookie,"sessionid=",";")

# Get Session ID
session_id = get_session_id(url)

#Sample API Calls

def new_order(order):
	global csrf_token
	global session_id
	global user_agent
	url = "https://delivery.vlokal.com/api/orders/"
	headers = { 'Content-type': 'application/json', 'User-Agent': user_agent, 'Referer': url, 'Cookie': 'csrftoken='+csrf_token+';sessionid='+session_id, 'X-CSRFToken': csrf_token }
	r = requests.post(url, data=order, headers=headers)
	return r.text

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