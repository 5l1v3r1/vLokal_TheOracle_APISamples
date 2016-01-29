import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import javax.net.ssl.HttpsURLConnection;
import java.util.List;
import java.util.regex.Pattern;
import java.util.regex.Matcher;


public class vlokal {

	private final String USER_AGENT = "vLokal Java API Bridge - 1.0";

	public static void main(String[] args) throws Exception {

		vlokal api = new vlokal();
		String AUTH_URL = "https://delivery.vlokal.com/accounts/login/";
		//GET CSRF Token
		String CSRF_TOKEN = api.getCSRFToken(AUTH_URL);
		//GET SESSION ID
		String SESSION_ID = api.getSessionID(AUTH_URL, CSRF_TOKEN);

		//Sample API Calls
		String api_url = "https://delivery.vlokal.com/api/orders/";
		String order_details = "{\"delivery_address\":{\"landmark\": \"Landmark\",\"area\": \"Area\",\"building\": \"Building\"},\"delivery_customer\": {\"name\": \"Customer Name\"},\"delivery_mobile\": {\"number\": \"9999999999\"},\"reference_id\": \"May be your order id\",\"description\": \"Any special instructions to delivery boy\",\"title\": \"Pick n Drop\",\"requested_pickup_time\": \"2016-01-14 00:57:00\",\"requested_delivery_time\": \"2016-01-14 01:27:00\",\"payment\": {\"amount\": 100,\"mode\": 1}}";
		System.out.println(api.newOrder(api_url,order_details,CSRF_TOKEN,SESSION_ID));
	}
	private String findBetween(String data, String start, String end){

		Pattern p = Pattern.compile(Pattern.quote(start) + "(.*?)" + Pattern.quote(end));
		Matcher m = p.matcher(data);
		while (m.find()) {
		  return (m.group(1));
		}
		return "";
	}

	//GET CSRF TOKEN
	private String getCSRFToken(String url) throws Exception {
		
		String csrftoken ="";
		URL obj = new URL(url);
		HttpURLConnection con = (HttpURLConnection) obj.openConnection();
		con.setRequestMethod("GET");
		con.setRequestProperty("User-Agent", USER_AGENT);
		con.setRequestProperty("Referer", url);
		List<String> cookies = con.getHeaderFields().get("Set-Cookie");
		if (con != null) {
		con.disconnect();
		}
		return findBetween(cookies.toString(),"csrftoken=",";");
	}
	
	//GET SESSION ID
	private String getSessionID(String url, String csrftoken) throws Exception {
		
		String username = "test_business";
		String password = "tb@vlokal";
		String sessionid = "";
		URL obj = new URL(url);
		HttpsURLConnection con = (HttpsURLConnection) obj.openConnection();
		con.setInstanceFollowRedirects(false);
		con.setFollowRedirects(false);
		con.setRequestMethod("POST");
		con.setRequestProperty("User-Agent", USER_AGENT);
		con.setRequestProperty("Content-type", "application/x-www-form-urlencoded");
		con.setRequestProperty("Referer", url);
		con.setRequestProperty("Cookie", "csrftoken="+csrftoken);
		String post_body = "username=" + username + "&password=" + password + "&csrfmiddlewaretoken=" + csrftoken + "&next=/";
		con.setDoOutput(true);
		DataOutputStream wr = new DataOutputStream(con.getOutputStream());
		wr.writeBytes(post_body);
		wr.flush();
		wr.close();
		List<String> cookies = con.getHeaderFields().get("Set-Cookie");
		if (con != null) {
		con.disconnect();
		}
		return findBetween(cookies.toString(),"sessionid=",";");
	}

	private String newOrder(String url, String order, String csrftoken, String sessionid) throws Exception {

		URL obj = new URL(url);
		HttpsURLConnection con = (HttpsURLConnection) obj.openConnection();
		con.setRequestMethod("POST");
		con.setRequestProperty("User-Agent", USER_AGENT);
		con.setRequestProperty("Content-type", "application/json");
		con.setRequestProperty("Referer", url);
		con.setRequestProperty("Cookie", "csrftoken="+csrftoken+";sessionid="+sessionid);
		con.setRequestProperty("X-CSRFToken", csrftoken);
		con.setDoOutput(true);
		DataOutputStream wr = new DataOutputStream(con.getOutputStream());
		wr.writeBytes(order);
		wr.flush();
		wr.close();
		BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
		String inputLine;
		StringBuffer response = new StringBuffer();
		while ((inputLine = in.readLine()) != null) {
		    response.append(inputLine);
		}
		in.close();
		if (con != null) {
		con.disconnect();
		}
		return response.toString();
	}

}