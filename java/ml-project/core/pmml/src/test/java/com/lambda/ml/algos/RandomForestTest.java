package com.lambda.ml.algos;

import com.lambda.ml.jpmml.JPMMLUtils;
import org.dmg.pmml.FieldName;
import org.dmg.pmml.Model;
import org.dmg.pmml.PMML;
import org.jpmml.evaluator.*;
import org.jpmml.manager.PMMLManager;
import org.junit.Before;
import org.junit.Test;

import java.io.BufferedReader;
import java.io.FileReader;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static junit.framework.TestCase.assertNotNull;

/**
 * Linear regression test for
 *
 * @author Lyndon Adams
 * @since  Apr, 2014
 */
public class RandomForestTest {

    private static final String modelName = "IrisPredictionRForest";

    private static final String pmmlFile = "iris-randomforest-prediction.xml";

    // Headers: sepal length,sepal width,petal length,petal width,species
    private static final String testCSVFile = "test_iris.csv";
    private final static String cvsSplitBy = ",";

    private static String pmmlFilePath;
    private static String csvFilePath;

    /**
     * Lets find the file from the classpath since we put the required files on to ths classpath for ease of testing.
     *
     * @throws java.net.URISyntaxException
     */
    @Before
    public void resolveFilePaths() throws URISyntaxException {
        URL url =  ClassLoader.getSystemResource( pmmlFile );
        pmmlFilePath =  url.getPath();

        url =  ClassLoader.getSystemResource( testCSVFile );
        csvFilePath = url.getPath();
    }

    /**
     *
     *
     * @throws Exception
     */
    @Test
    public void loadPMMLModel() throws Exception {

        PMML pmml = JPMMLUtils.loadModel(pmmlFilePath);

        // Did we get a pmml model.
        assertNotNull(pmml);

        PMMLManager mgr = new PMMLManager( pmml );
        Model model = mgr.getModel( modelName );

        // Did we find the model we created and saved?
        assertNotNull( model );
    }

    /**
     * Predict the flower species by using the offline PMML model. This is a contrived example but it does show the core requirements to use JPMML for prediction.
     *
     * @throws Exception
     */
    @Test
    public void predictSpecies() throws Exception {

        PMML pmml = JPMMLUtils.loadModel( pmmlFilePath );
        PMMLManager mgr = new PMMLManager( pmml );

        ModelEvaluator<?> modelEvaluator = (ModelEvaluator<?>) mgr.getModelManager(modelName, ModelEvaluatorFactory.getInstance());
        Evaluator evaluator = modelEvaluator;

        // Get the list of required feature set model needs to predict.
        List<FieldName> requiredModelFeatures = evaluator.getActiveFields();

        try ( BufferedReader br = new BufferedReader(new FileReader( csvFilePath ))){

            Map<FieldName, FieldValue> features = new LinkedHashMap<>();
            String line = null;


            // Counters see how long and number of predictions
            long startTime = System.currentTimeMillis();
            int predications = 0;


            // For each CSV line perform a predict.
            while ((line = br.readLine()) != null) {

                predications++;
                String[] tokens = line.split( cvsSplitBy );


                Double[] pfeatures = {
                        Double.valueOf( tokens[0] ),
                        Double.valueOf( tokens[1] ) ,
                        Double.valueOf( tokens[2] ),
                        Double.valueOf( tokens[3] )
                };

                String expectedSpecies = tokens[4];

                for(int i=0; i<4;i++){
                    FieldName fieldName = requiredModelFeatures.get(i);

                    FieldValue value = evaluator.prepare(fieldName, pfeatures[i]);
                    features.put( fieldName, value );
                }

                Map<FieldName, ?> results = evaluator.evaluate( features );

                // Convert back to original ring value so the prediction become meaningful.
                DefaultClassificationMap<String> predicatedLabel = (DefaultClassificationMap)results.get( evaluator.getTargetField());


               System.out.println("\nPredication");
               for(String key : predicatedLabel.keySet() ){
                   System.out.println(String.format("Predicated species [ %s --> %f ]  - Expected species [ %s ]", key, predicatedLabel.getProbability(key), expectedSpecies ));
               }

            }
            System.out.println(String.format("Predicted %d items in %dms", predications, System.currentTimeMillis() - startTime));

        }
    }

}
