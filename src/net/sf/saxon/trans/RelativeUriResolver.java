package net.sf.saxon.trans;

import java.io.File;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import net.sf.saxon.StandardURIResolver;

public class RelativeUriResolver implements URIResolver {

	public final URIResolver baseResolver = new StandardURIResolver();
	@Override
	public Source resolve(String href, String base) throws TransformerException {
		File localfile = new File(href);
		if (localfile.exists()) {
			return baseResolver.resolve(localfile.getAbsolutePath(),localfile.getAbsolutePath());
		}
		return null;
	}

}
