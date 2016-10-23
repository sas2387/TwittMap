package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.lucene.queryparser.xml.builders.RangeQueryBuilder;
import org.elasticsearch.index.query.QueryBuilder;
import org.elasticsearch.search.builder.SearchSourceBuilder;

import io.searchbox.client.JestClient;
import io.searchbox.client.JestClientFactory;
import io.searchbox.client.JestResult;
import io.searchbox.client.config.HttpClientConfig;
import io.searchbox.core.Search;
import io.searchbox.core.SearchResult;
import io.searchbox.core.SearchScroll;
import io.searchbox.params.Parameters;
import pojo.*;

import org.elasticsearch.index.query.QueryBuilders;

/**
 * Servlet implementation class GetTweetsElasticSearch
 */
public class GetTweetsElasticSearch extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public GetTweetsElasticSearch() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		//response.getWriter().append("Served at: ").append(request.getContextPath());
        // Construct a new Jest client according to configuration via factory
		JestResult result;
		String scrollId="";
        
		String searchParameter = request.getParameter("keyword");
		String scrollIdParameter = request.getParameter("scrollId");
		//System.out.println(scrollIdParameter);

		
		JestClientFactory factory = new JestClientFactory();
        factory.setHttpClientConfig(new HttpClientConfig
                .Builder("https://search-twittmap-pm2j52d7r2epphdbvoasrcp7jm.us-west-2.es.amazonaws.com:443")
                .multiThreaded(true)
                .build());
        JestClient client = factory.getObject();
        
        if(scrollIdParameter==null ){
	        SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
	        searchSourceBuilder.size(1000);
	        searchSourceBuilder.from(0);
	        
	        if(searchParameter != null && !"".equals(searchParameter))
	        		searchSourceBuilder.query(QueryBuilders.matchQuery("text",searchParameter));
	        else 
	    	   searchSourceBuilder.query(QueryBuilders.matchAllQuery());
	    
	
	        Search search = new Search.Builder(searchSourceBuilder.toString())
	                // multiple index or types can be added.
	                .addIndex("twitter")
	                .addType("tweet")
	                .setParameter(Parameters.SCROLL, "2m")
	                .build();
	        //System.out.println("Executing simple");
	        result = client.execute(search);
        }else{
        	//System.out.println("Executing scroll");
        	 SearchScroll scroll = new SearchScroll.Builder(scrollIdParameter, "2m")
                     .setParameter(Parameters.SIZE, 10000).build();
            result = client.execute(scroll);
        }
        //System.out.println(result.getJsonString());
        scrollId = result.getJsonObject().getAsJsonPrimitive("_scroll_id").getAsString();
        
        List<Tweet> tweets = result.getSourceAsObjectList(Tweet.class);
        //System.out.println(tweets.size());
        if(tweets.size()>0) {
//        for(Tweet t:tweets){
//            System.out.println(t.getId());
//            System.out.println(t.getLat());
//            System.out.println(t.getLng());
//            System.out.println(t.getText());
//            System.out.println(t.getTime());
//            System.out.println(t.getUser());
//        }
        
        	Tweet t = null;
	        PrintWriter pw = response.getWriter();
		      pw.write("{\"tweets\":[");
		      int i=0;
		      for(i=0;i<tweets.size()-1;i++){
		    	  t = tweets.get(i);
		    	  pw.write("{\"lat\": "+t.getLat()+", \"lng\": "+t.getLng()+"}, ");
		      }
		      t = tweets.get(i);
		      pw.write("{\"lat\": "+t.getLat()+", \"lng\": "+t.getLng()+"}");
		      pw.write("], \"scrollId\" : \""+scrollId+"\"}");
		      pw.close();
        }
    }
	

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
