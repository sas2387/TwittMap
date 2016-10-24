<%@page import="java.util.ArrayList"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no">
    <meta charset="utf-8">
    <title>Marker Clustering</title>
    <style>
      html, body {
        height: 100%;
        margin: 0;
        padding: 0;
      }
      #map {
        height: 100%;
        width: 80%;
        float: right;
      }
      #searchPanel {
      	height: 100%;
        width: 20%;
        float: left;
        background-color: #EDE8E8;
      }
 
    </style>
    
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js">
</script>


<%-- <%
String keyword = request.getParameter("keyword");


Class.forName("com.mysql.jdbc.Driver");
// setup the connection with the DB.
Connection connect = DriverManager.getConnection("jdbc:mysql://localhost/tweetmapdb?"
        + "user=root&password=");
// statements allow to issue SQL queries to the database
Statement statement = connect.createStatement();
// resultSet gets the result of the SQL query
String query="";
if(keyword==null || keyword.trim().equals("")){
	query = "select tweet_id,tweet_latitude,tweet_longitude from tweets";
} else {
	query = "select tweet_id,tweet_latitude,tweet_longitude from tweets where tweet_text LIKE  '%"+keyword+"%'";
}

ResultSet resultSet = statement.executeQuery(query);
//System.out.println(query);
ArrayList<Double> latitudes = new ArrayList<Double>();
ArrayList<Double> longitudes = new ArrayList<Double>();
while(resultSet.next()){
	  latitudes.add(resultSet.getDouble("tweet_latitude"));
	  longitudes.add(resultSet.getDouble("tweet_longitude"));
}
connect.close();

%>--%> 
	<script>
	var locations = [];
	var tweetsText = [];
	var map;
	var markers;
	var markerCluster;
	scrollId="";
	limit=10000;
	lastCount=0;
	
	
	
	function loadNewLocations() {
		var keywordVal = document.getElementById('keyword').value;
		$.get("<%= request.getContextPath().toString()%>/GetTweetsElasticSearch?scrollId="+scrollId+"&keyword="+keywordVal, function(results, status){
        	
        	var result = JSON.parse(results);
        	var tweets = result.tweets;
        	scrollId=result.scrollId;
        	lastCount+=tweets.length;
        	//alert(lastCount)
        	if(lastCount>limit){
        		limit+=5000;
        		clearMarkersaa();
        	}
   
        	
     		for (var i=0;i <tweets.length; i++){
     			var newLocation = {lat : tweets[i].lat, lng : tweets[i].lng};
     			locations.push(newLocation);
     			
     			var tweetText = tweets[i].text;
     			
     			var image = '<%= request.getContextPath().toString()%>/images/tweet_icon.png';
     			
     			var newMarker = new google.maps.Marker({
     	              position: newLocation,
     	              icon: image,
     	              title : decodeURIComponent((tweetText+'').replace(/\+/g, '%20'))
     	            });
     			
     			newMarker.setMap(map);
     			markers.push(newMarker);
     		}
     		markerCluster = new MarkerClusterer(map, markers,
     	            {imagePath: 'https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/m'});
    	});
	}
	
	
	function loadLocations() {	
		var keywordVal = document.getElementById('keyword').value;
		
		
		    	$.get("<%= request.getContextPath().toString()%>/GetTweetsElasticSearch?keyword="+keywordVal, function(results, status){
	            	//alert("Data: " + results + "\nStatus: " + status);
	            	
	            	if(keywordVal != null && keywordVal != ""){
	            		clearInterval(interval);
	            		locations = [];
						tweetsText = [];
						
						clearMarkersaa();
	            	}
	            	var result = JSON.parse(results);
	            	alert(result.tweets.length)
	            	var tweets = result.tweets;
	            	lastCount+=tweets.length;
	            	scrollId=result.scrollId;
	            	//alert(scrollId);
	            	
	         		for (var i=0;i <tweets.length; i++){
	         			var newLocation = {location : {lat : tweets[i].lat, lng : tweets[i].lng}, text : tweets[i].text};
	         			locations.push(newLocation);
	         			tweetsText.push(tweets[i].text);
	         			
	         		}
	         		alert(locations.length)
	         		if(keywordVal == null || keywordVal == "")
	         			interval = setInterval(loadNewLocations, 10000);
	         		initMap();
	        	});
	}
      function initMap() {

        map = new google.maps.Map(document.getElementById('map'), {
          zoom: 2,
          center: {lat: 34.5133, lng: -94.1629}//{lat: -28.024, lng: 140.887}
        });

        // Add some markers to the map.
        // Note: The code uses the JavaScript Array.prototype.map() method to
        // create an array of markers based on a given "locations" array.
        // The map() method here has nothing to do with the Google Maps API.
       
        var image = '<%= request.getContextPath().toString()%>/images/tweet_icon.png';

        markers = locations.map(function(location, i) {
            return new google.maps.Marker({
              position: location.location,
              icon: image,
              title : decodeURIComponent((location.text+'').replace(/\+/g, '%20'))//decodeURIComponent((tweetsText[i]+'').replace(/\+/g, '%20'))
            });
          });

        // Add a marker clusterer to manage the markers.
        markerCluster = new MarkerClusterer(map, markers,
            {imagePath: 'https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/m'});
      }
      
      /*google.maps.Map.prototype.clearMarkers = function() {
    	    for(var i=0; i < this.markers.length; i++){
    	        this.markers[i].setMap(null);
    	    }
    	    this.markers = new Array();
    	    alert("clear markers");
    	};*/
     
      
    	
    	function clearMarkersaa() {
    	    for(var i=0; i < this.markers.length; i++){
    	        this.markers[i].setMap(null);
    	    }
    	    this.markers = [];
    	    alert("clear markers" + markers.length);
    	    //markerCluster.setMap(null);
    	    markerCluster.repaint();
    	    
    	    map = new google.maps.Map(document.getElementById('map'), {
    	          zoom: 2,
    	          center: {lat: 34.5133, lng: -94.1629}//{lat: -28.024, lng: 140.887}
    	        });
    	    markerCluster = new MarkerClusterer(map, markers,
    	            {imagePath: 'https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/m'});
    	
    	    markerCluster.clearMarkers();
    	    
    	}
    	
      <%--<%
      int i=0;
      for(i=0;i<latitudes.size()-1;i++){
    	  out.print("{lat: "+latitudes.get(i)+", lng: "+longitudes.get(i)+"}, ");
      }
      out.print("{lat: "+latitudes.get(i)+", lng: "+longitudes.get(i)+"}");
      %>--%>
      /*];*/
      
    </script>
    <script src="https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/markerclusterer.js">
    </script>
    <script async defer
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCUx6LjDDN-OHV7RxlPxNCZnm98vvNH87I&callback=initMap"> 
    </script>
    <script type="text/javascript">
    function hideAndShow() {
		var searchPanel = document.getElementById("searchPanel");
		var mapPanel = document.getElementById("map");
		var formObject = document.getElementById("searchForm");
		var btnHideShow = document.getElementById("searchForm");
		
		if(searchPanel.style.width == "5%"){
			formObject.style.display = "block";
			searchPanel.style.width = "20%";
			mapPanel.style.width = "80%";
		}
		else {
			formObject.style.display = "none";
			searchPanel.style.width = "5%";
			mapPanel.style.width = "95%";
			initMap();
		}
		
		
	}
    
    </script>
  </head>

<body>


<div id="searchPanel" align="center" >
	
	
	<div onclick="hideAndShow()" style="direction: ltr; cursor:pointer; margin-top:10px; margin-right: 4px; float:right; overflow: hidden; text-align: center; position: relative; color: rgb(0, 0, 0); font-family: Roboto,Arial,sans-serif; -moz-user-select: none; font-size: 11px; background-color: rgb(255, 255, 255); padding: 8px; border-bottom-left-radius: 2px; border-top-left-radius: 2px; background-clip: padding-box; box-shadow: 0px 1px 4px -1px rgba(0, 0, 0, 0.3); min-width: 22px; max-width:30px; font-weight: 500;" draggable="false" title="Hide or Show">
	&lt;&lt;&gt;&gt;	
	</div>
	
	
	<br><br><br><br><br><br><br><br>
	
	<form id="searchForm" name="searchForm" method="get" action="javascript::loadLocations()" style="margin-top: 35%">
		<table>
		<tr>
		<td>Select Keyword</td>
		</tr>
		<tr><td>
		<select id="keyword" name="keyword">
			<option value="">--select--</option>
			<option value="love">Love</option>
			<option value="travel">Travel</option>
			<option value="friend">Friend</option>
			<option value="fun">Fun</option>
			<option value="trump">Trump</option>
		</select></td>
		</tr>
		<tr><td> <input type="submit" id="submit" value="Search" onclick="loadLocations()" /></td></tr>
		</table>
	
	
	</form>
	

</div>


<div id="map">

</div>
</body>
<script type="text/javascript">
loadLocations();

</script>
</html>