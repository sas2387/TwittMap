package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class GetTweets extends HttpServlet{
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		
		
		
		// TODO Auto-generated method stub
		try{
		Class.forName("com.mysql.jdbc.Driver");
	      // setup the connection with the DB.
	      Connection connect = DriverManager.getConnection("jdbc:mysql://localhost/tweetmapdb?"
	              + "user=root&password=");
	      // statements allow to issue SQL queries to the database
	      Statement statement = connect.createStatement();
	      // resultSet gets the result of the SQL query
	      String query="select * from tweets LIMIT 0,25";
	      
	      ResultSet resultSet = statement.executeQuery(query);
	      //System.out.println(query);
	      ArrayList<Double> latitudes = new ArrayList<Double>();
	      ArrayList<Double> longitudes = new ArrayList<Double>();
	      
	      while(resultSet.next()){
	    	  latitudes.add(resultSet.getDouble("tweet_latitude"));
	    	  longitudes.add(resultSet.getDouble("tweet_longitude"));
	      }
	      connect.close();	
	      PrintWriter pw = resp.getWriter();
	      pw.write("eqfeed_callback({\"tweets\":[");
	      int i=0;
	      for(i=0;i<latitudes.size()-1;i++){
	    	  pw.write("{lat: "+latitudes.get(i)+", lng: "+longitudes.get(i)+"}, ");
	      }
	      pw.write("{lat: "+latitudes.get(i)+", lng: "+longitudes.get(i)+"}");
	      pw.write("]})");
	      pw.close();
		}catch(Exception e){
			e.printStackTrace();
		}
	}
}

