package com.lambda.ml.algos;

import com.lambda.ml.jpmml.JPMMLUtils;
import org.dmg.pmml.FieldName;
import org.jpmml.evaluator.FieldValue;
import org.dmg.pmml.Model;
import org.dmg.pmml.PMML;
import org.jpmml.evaluator.Evaluator;
import org.jpmml.evaluator.ModelEvaluator;
import org.jpmml.evaluator.ModelEvaluatorFactory;
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
 * Linear regression test to predict the number ring a abalone would have from a selected feature set.
 *
 * @author Lyndon Adams
 * @since  Apr, 2014
 */
public class LinearRegressionTest {

    static final String modelName = "AbaloneRingsPredictionLM";

    static final String pmmlFile = "abalone-rings-lm-prediction.xml";

    // Headers: "","whole_weight","diameter","rings","length","height"
    static final String testCSVFile = "test_abalone.csv";
    static final String cvsSplitBy = ",";

    static String pmmlFilePath;
    static String csvFilePath;

    /**
     * Lets find the file from the classpath since we put the required files on to ths classpath for ease of testing.
     *
     * @throws URISyntaxException
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
     * Predict the number of rings by using the offline PMML model. This is a contrived example but it does show the core requirements to use JPMML for scoring/prediction.
     *
     * @throws Exception
     */
    @Test
    public void predictAbaloneRings() throws Exception {

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

                double d =  Double.valueOf( tokens[2] );
                double e = Double.valueOf( tokens[3] );

                FieldName fieldName = requiredModelFeatures.get(0);

                // In this instance I know there is only one feature
                // For a production system this would be performed in a transformation stage and may collect data externally.
                FieldValue value = evaluator.prepare(fieldName, Double.valueOf(d));
                features.put( fieldName, value );

                Map<FieldName, ?> results = evaluator.evaluate( features );

                // Convert back to original ring value so the prediction become meaningful.
                double y = (Double)results.get( evaluator.getTargetField());
                int predictedRings = (int) Math.abs( Math.pow( 10, y));

                int expectedRings = (int) Math.abs( Math.pow( 10, e));

                double diameter =  Math.pow( 10, d);
                System.out.println(String.format("Diameter %f - Expected rings %d : Predicted rings: %d", diameter, expectedRings, predictedRings));
            }

            System.out.println(String.format("Predicted %d items in %dms", predications, System.currentTimeMillis() - startTime));

        }
    }

}
