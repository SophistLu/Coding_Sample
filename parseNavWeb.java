# Copyright (c) 2015 - Zhaoyu Lu <zylu@g.ucla.com>

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.FilterWriter;
import java.io.ObjectOutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.swing.tree.TreeNode;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Attributes;
import org.jsoup.nodes.DataNode;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.select.Elements;
import org.jsoup.select.NodeTraversor;
import org.jsoup.select.NodeVisitor;

public class parseNavWeb {
	public static void main(String[] args) {
		try {
			// Parse Navigation website for links
			String htmlNow = "http://www.2345.com/";
			Document doc = Jsoup.connect(htmlNow).get(); // Get website content
			Element body = doc.body();
			Elements eles = body.select("a");
			
			FileWriter outLine = new FileWriter("d://websites.txt"); //New file
			
			for(Iterator it = eles.iterator(); it.hasNext();){
				Element e = (Element) it.next();
				if(e.attr("abs:href").split("265").length>1) { continue; }
				if(e.attr("abs:href").isEmpty()) { continue; }
				outLine.write(e.attr("abs:href") + System.getProperty("line.separator"));
			}
			
			outLine.close();
			System.out.println("Finished.");
			
		} catch (Exception e) {
			System.out.println(e);
		}
	}
}





