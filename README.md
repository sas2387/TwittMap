# TwittMap
Shows Tweets on Map with the tweet text.<br/>
Currently Map shows max 10,000 tweets and then clears the markers to show new markers.<br/> (Tweak index.jsp to show more markers)<br/><br/>
The map fetches new tweets every 10 second.<br/> (Tweak index.jsp to show more markers)<br/><br/>
Each request from Elastic Search brings 1,000 records at a time using Scroll API and maintains a 2 minute session.<br/> (Tweak controller to get more records)<br/><br/>
Maven Web App Archetype<br/><br/>
Put following API Keys and URLs in src/main/webapp/WEB-INF/web.xml<br/>
(1) Google Maps JavaScript API Key<br/>
(2) Elastic Search URL with port number<br/>
