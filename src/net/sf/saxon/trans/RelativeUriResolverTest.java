package net.sf.saxon.trans;

import static org.junit.Assert.*;

import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import org.junit.Test;

import net.sf.saxon.Configuration;

public class RelativeUriResolverTest {

	@Test
	public void test()  {
		Configuration config = new Configuration();
		URIResolver uriResolver=null;
		try {
			uriResolver = config.makeURIResolver("net.sf.saxon.trans.RelativeUriResolver");
		} catch (TransformerException e) {
			e.printStackTrace();
		}
		assertNotNull(uriResolver);
	}

}
