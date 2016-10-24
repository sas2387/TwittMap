# TwittMap
Shows Tweets on Map with the tweet text.
Currently Map shows max 10,000 tweets and then clears the markers to show new markers. (Tweak index.jsp to show more markers)
The map fetches new tweets every 10 second. (Tweak index.jsp to show more markers)
Each request from Elastic Search brings 1,000 records at a time using Scroll API and maintains a 2 minute session. (Tweak controller to get more records)

Maven Web App Archetype

Put following API Keys and URLs in src/main/webapp/WEB-INF/web.xml
(1) Google Maps JavaScript API Key
(2) Elastic Search URL with port number
