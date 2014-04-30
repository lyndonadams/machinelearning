package com.lambda.ml.exceptions;

/**
 * Simple ML exception class.
 *
 * @author Lyndon Adams
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
