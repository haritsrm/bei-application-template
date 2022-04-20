package com.traveloka.bootcamp.calculator.service;

import com.traveloka.bootcamp.calculator.model.CalculatorAddRequest;
import com.traveloka.bootcamp.calculator.model.CalculatorAddResponse;
import com.traveloka.bootcamp.calculator.model.CalculatorSubtractRequest;
import com.traveloka.bootcamp.calculator.model.CalculatorSubtractResponse;

/**
 * Calculator Service interface.
 *
 * As you might have noticed, this is a mirror to Addition and Subtraction service.
 * But we must not reuse / depend on either `bootcamp-addition-api` or `bootcamp-subtraction-api`.
 */
public interface CalculatorService {
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
    CalculatorAddResponse add(CalculatorAddRequest addRequest);

    /**
     * Calculate a - b.
     *
     * @param a First Digit.
     * @param b Second Digit.
     * @return Result of a - b.
     */
    int subtract(int a, int b);

    /**
     * Calculate a - b within the request object.
     *
     * @param subtractRequest  The request containing the two digits.
     * @return The response containing the result.
     */
    CalculatorSubtractResponse subtract(CalculatorSubtractRequest subtractRequest);
}