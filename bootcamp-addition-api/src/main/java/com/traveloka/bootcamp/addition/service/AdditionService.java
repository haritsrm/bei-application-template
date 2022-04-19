package com.traveloka.bootcamp.addition.service;

import com.traveloka.bootcamp.addition.model.AddRequest;
import com.traveloka.bootcamp.addition.model.AddResponse;

public interface AdditionService {
    /**
     * Calculate a + b.
     *
     * @param a First Digit.
     * @param b Second Digit.
     * @return Result of a + b.
     */
    int add(int a, int b);

    /**
     * Calculate a + b within the request object.
     *
     * @param addRequest  The request containing the two digits.
     * @return The response containing the result.
     */
    AddResponse add(AddRequest addRequest);
}
