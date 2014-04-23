package com.lambda.ml.jpmml;

import com.lambda.ml.exceptions.MLException;
import org.dmg.pmml.FieldName;
import org.dmg.pmml.PMML;
import org.jpmml.evaluator.Evaluator;
import org.jpmml.evaluator.FieldValue;
import org.jpmml.model.ImportFilter;
import org.jpmml.model.JAXBUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import javax.xml.bind.JAXBException;
import javax.xml.transform.Source;
import java.io.*;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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

    /**
     * Build a feature set to use against a PMML model.
     *
     * @param evaluator
     * @param requiredModelFeatures
     * @param data
     * @return  Map<FieldName, FieldValue>
     */
    public static final Map<FieldName, FieldValue> buildFeatureSet(Evaluator evaluator, List<FieldName> requiredModelFeatures, Object[] data){

        Map<FieldName, FieldValue> features = new LinkedHashMap<>();

        for(int i=0; i<requiredModelFeatures.size(); i++){
            FieldName fieldName= requiredModelFeatures.get( i);
            FieldValue value = evaluator.prepare(fieldName, data[i]);
            features.put( fieldName, value);
        }
        return features;
    }

}
