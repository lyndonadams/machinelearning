package com.lambda.ml.jpmml;

import com.lambda.ml.exceptions.MLException;
import org.dmg.pmml.PMML;
import org.jpmml.model.ImportFilter;
import org.jpmml.model.JAXBUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import javax.xml.bind.JAXBException;
import javax.xml.transform.Source;
import java.io.*;

/**
 * JPMML util class that provides useful functions such as reading and writing pmml documents.
 *
 * @author Lyndon Adams
 * @since  Apr, 2014
 */
public final class JPMMLUtils {

    private static final Logger LOGGER = LoggerFactory.getLogger( "JPMMLUtils" );

    private JPMMLUtils(){
    }

    /**
     * Load a PMML model from the file system.
     *
     * @param file
     * @return
     * @throws MLException
     */
    public static final PMML loadModel(final String file) throws MLException {
        PMML pmml = null;

        File inputFilePath = new File( file );

        try( InputStream in = new FileInputStream( inputFilePath ) ){
            Source source = ImportFilter.apply(new InputSource(in));
            pmml = JAXBUtil.unmarshalPMML(source);

        } catch(  IOException | SAXException | JAXBException  e) {
            LOGGER.error(e.toString());
            throw new MLException( e);
        }
        return pmml;
    }
}
