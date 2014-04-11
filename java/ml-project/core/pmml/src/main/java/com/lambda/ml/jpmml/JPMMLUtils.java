package com.lambda.ml.jpmml;

import org.dmg.pmml.PMML;
import org.jpmml.model.ImportFilter;
import org.jpmml.model.JAXBUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.InputSource;

import javax.xml.transform.Source;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;


/**
 * JPMML util class that provides useful functions such as reading and writing pmml documents.
 *
 * @author Lyndon Adams
 * @since  Apr, 2014
 */
public final class JPMMLUtils {

    public static final Logger logger = LoggerFactory.getLogger( "JPMMLUtils" );

    private JPMMLUtils(){}

    /**
     * Load a PMML model from the file system.
     *
     * @param file
     * @return
     * @throws Exception
     */
    public final static PMML loadModel(final String file) throws Exception {

        PMML pmml = null;

        File inputFilePath = new File( file );

        try( InputStream in = new FileInputStream( inputFilePath ) ){

            Source source = ImportFilter.apply(new InputSource(in));
            pmml = JAXBUtil.unmarshalPMML(source);

        } catch( Exception e) {
            logger.error( e.toString() );
            throw e;
        }
        return pmml;
    }
}
