package service;

import io.searchbox.client.JestClient;
import io.searchbox.client.JestClientFactory;
import io.searchbox.client.config.HttpClientConfig;
import io.searchbox.core.Bulk;
import io.searchbox.core.Delete;
import io.searchbox.core.Index;
import io.searchbox.indices.CreateIndex;
import io.searchbox.indices.mapping.PutMapping;


import twitter4j.FilterQuery;
import twitter4j.StallWarning;
import twitter4j.Status;
import twitter4j.StatusDeletionNotice;
import twitter4j.StatusListener;
import twitter4j.TwitterStream;
import twitter4j.TwitterStreamFactory;
import twitter4j.conf.ConfigurationBuilder;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import pojo.*;


public class StreamAndUpload {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		final List<Tweet> tweets = new ArrayList<Tweet>();

		JestClientFactory factory = new JestClientFactory();
        factory.setHttpClientConfig(new HttpClientConfig
        		.Builder("")
        		.multiThreaded(true)
                .build());
        final JestClient client = factory.getObject();
        
        
        ConfigurationBuilder cb = new ConfigurationBuilder();
        cb.setDebugEnabled(true);
        cb.setOAuthConsumerKey("");
        cb.setOAuthConsumerSecret("");
        cb.setOAuthAccessToken("");
        cb.setOAuthAccessTokenSecret("");
        
        
        TwitterStream twitterStream = new TwitterStreamFactory(cb.build()).getInstance();
        
        StatusListener statusListener = new StatusListener() {
			
			public void onException(Exception arg0) {
				// TODO Auto-generated method stub
				
			}
			
			public void onTrackLimitationNotice(int arg0) {
				// TODO Auto-generated method stub
				
			}
			
			public void onStatus(Status status) {
				
				if(status.getGeoLocation() != null){
					Tweet newTweet = new Tweet();
					SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
					String time = sdf.format(status.getCreatedAt());
					String statusstring = status.getText().replaceAll("'", "\\\\'");
					statusstring = statusstring.replaceAll("\\s+", " ");
					
					newTweet.setLat(status.getGeoLocation().getLatitude());
					newTweet.setLng(status.getGeoLocation().getLongitude());
					newTweet.setText(statusstring);
					newTweet.setTime(status.getCreatedAt());
					newTweet.setId(String.valueOf(status.getId()));
					newTweet.setUser(status.getUser().getScreenName());
					
					System.out.println(newTweet.toString());
					
					tweets.add(newTweet);
					newTweet = null;
					
					
					/*Index index = new Index.Builder(newTweet).index("twitter").type("tweet").build();
					try {
						client.execute(index);
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}*/
					
				}
				
				if(tweets.size() >= 50){
					Bulk.Builder builder = new Bulk.Builder()
		                    .defaultIndex("twitter")
		                    .defaultType("tweet");

		            for(Tweet t:tweets){
		                builder.addAction(new Index.Builder(t).index("twitter").type("tweet").id(t.getId()).build());
		            }
		            Bulk bulk = builder.build();
		            try {
						client.execute(bulk);
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
		            tweets.clear();
		            try {
						Thread.sleep(10000);
					} catch (InterruptedException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}

				}

			
			}
			
			public void onStallWarning(StallWarning arg0) {
				// TODO Auto-generated method stub
				
			}
			
			public void onScrubGeo(long arg0, long arg1) {
				// TODO Auto-generated method stub
				
			}
			
			public void onDeletionNotice(StatusDeletionNotice arg0) {
				// TODO Auto-generated method stub
				
			}
		};
		
		twitterStream.addListener(statusListener);
		//twitterStream.firehose(0);
		FilterQuery fq = new FilterQuery();
		double locations[][] = {{-180,-90},{180,90}};
		fq.locations(locations);
		twitterStream.filter(fq);
		
		
		//twitterStream.sample();
	}
        
	}


