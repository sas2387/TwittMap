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
	var map;
	var markers;
	var markerCluster;
	limit=5000;
	lastCount=0;
	setInterval(loadNewLocations, 5000);
	loadLocations();
	
	
	function loadNewLocations() {
		$.get("<%= request.getContextPath().toString()%>/GetTweetsElasticSearch?lastCount="+lastCount, function(results, status){
        	
        	var result = JSON.parse(results);
        	var tweets = result.tweets;
        	lastCount+=tweets.length;
        	if(lastCount>limit){
        		limit+=10000;
        		clearMarkers();
        	}
   
        	
     		for (var i=0;i <tweets.length; i++){
     			var newLocation = {lat : tweets[i].lat, lng : tweets[i].lng};
     			locations.push(newLocation);
     			
     			var image = '<%= request.getContextPath().toString()%>/images/tweet_icon.png';
     			
     			var newMarker = new google.maps.Marker({
     	              position: newLocation,
     	              icon: image
     	            });
     			
     			newMarker.setMap(map);
     			markers.push(newMarker);
     		}
     		var markerCluster = new MarkerClusterer(map, markers,
     	            {imagePath: 'https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/m'});
    	});
	}
	
	
	function loadLocations() {	
		    	$.get("<%= request.getContextPath().toString()%>/GetTweetsElasticSearch?lastCount="+lastCount, function(results, status){
	            	//alert("Data: " + results + "\nStatus: " + status);
	            	
	            	var result = JSON.parse(results);
	            	var tweets = result.tweets;
	            	lastCount+=tweets.length;
	            	
	         		for (var i=0;i <tweets.length; i++){
	         			var newLocation = {lat : tweets[i].lat, lng : tweets[i].lng};
	         			locations.push(newLocation);
	         			
	         		}

	
	         		initMap();
	         		//google.maps.event.trigger(document.getElementById('map'), 'resize');
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
              position: location,
              icon: image
            });
          });

        // Add a marker clusterer to manage the markers.
        var markerCluster = new MarkerClusterer(map, markers,
            {imagePath: 'https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/m'});
      }
      
      google.maps.Map.prototype.clearMarkers = function() {
    	    for(var i=0; i < this.markers.length; i++){
    	        this.markers[i].setMap(null);
    	    }
    	    this.markers = new Array();
    	};
     
      
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

<body">


<div id="searchPanel" align="center" >
	
	
	<div onclick="hideAndShow()" style="direction: ltr; cursor:pointer; margin-top:10px; margin-right: 4px; float:right; overflow: hidden; text-align: center; position: relative; color: rgb(0, 0, 0); font-family: Roboto,Arial,sans-serif; -moz-user-select: none; font-size: 11px; background-color: rgb(255, 255, 255); padding: 8px; border-bottom-left-radius: 2px; border-top-left-radius: 2px; background-clip: padding-box; box-shadow: 0px 1px 4px -1px rgba(0, 0, 0, 0.3); min-width: 22px; max-width:30px; font-weight: 500;" draggable="false" title="Hide or Show">
	&lt;&lt;&gt;&gt;	
	</div>
	
	
	<br><br><br><br><br><br><br><br>
	
	<form id="searchForm" name="searchForm" method="get" action="index.jsp" style="margin-top: 35%">
		<select id="keyword" name="keyword">
			<option id="">--select--</option>
			<option id="love">Love</option>
			<option id="travel">Travel</option>
			<option id="friend">Friend</option>
			<option id="fun">Fun</option>
			<option id="trump">Trump</option>
		</select>
		<input type="submit" id="submit" value="Search" />
	
	
	</form>
	

</div>


<div id="map">


</div>
</body>
</html>