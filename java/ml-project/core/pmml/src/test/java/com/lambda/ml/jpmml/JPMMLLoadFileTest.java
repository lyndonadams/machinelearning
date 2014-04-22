package com.lambda.ml.jpmml;

import junit.framework.TestCase;
import org.dmg.pmml.Model;
import org.dmg.pmml.PMML;
import org.jpmml.manager.PMMLManager;
import org.junit.Test;

import java.net.URL;

import static junit.framework.Assert.assertNotNull;
import static junit.framework.Assert.assertNull;
import static junit.framework.Assert.assertTrue;

public class JPMMLLoadFileTest {

    private static final String pmmlFile = "abalone-rings-lm-prediction.xml";
    private static final String modelName = "AbaloneRingsPredictionLM";

    @Test
    public void loadFile(){

        try {
            URL url =  ClassLoader.getSystemResource( pmmlFile );
            String pmmlFilePath =  url.getPath();

            PMML pmml = JPMMLUtils.loadModel(pmmlFilePath);

            // Did we get a pmml model.
            assertNotNull(pmml);

            PMMLManager mgr = new PMMLManager( pmml );
            Model model = mgr.getModel( modelName );

            // Did we find the model we created and saved?
            assertNotNull(model);

        }catch(Exception e){
            assertTrue("Exception failure.", false);
        }

    }
}
