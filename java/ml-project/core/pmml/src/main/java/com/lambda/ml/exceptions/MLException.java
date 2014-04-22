package com.lambda.ml.exceptions;

/**
 * Created with IntelliJ IDEA.
 * User: lyndonadams
 * Date: 16/04/2014
 * Time: 00:49
 * To change this template use File | Settings | File Templates.
 */
public class MLException extends Exception {
    public MLException() {
    }

    public MLException(String message) {
        super(message);
    }

    public MLException(String message, Throwable cause) {
        super(message, cause);
    }

    public MLException(Throwable cause) {
        super(cause);
    }

    public MLException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }
}
