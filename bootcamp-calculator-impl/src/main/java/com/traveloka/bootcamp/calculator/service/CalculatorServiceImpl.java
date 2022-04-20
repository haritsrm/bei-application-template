package com.traveloka.bootcamp.calculator.service;

import com.traveloka.bootcamp.addition.model.AddRequest;
import com.traveloka.bootcamp.addition.model.AddResponse;
import com.traveloka.bootcamp.addition.service.AdditionService;
import com.traveloka.bootcamp.calculator.model.CalculatorAddRequest;
import com.traveloka.bootcamp.calculator.model.CalculatorAddResponse;
import com.traveloka.bootcamp.calculator.model.CalculatorSubtractRequest;
import com.traveloka.bootcamp.calculator.model.CalculatorSubtractResponse;
import com.traveloka.bootcamp.subtraction.model.SubtractRequest;
import com.traveloka.bootcamp.subtraction.model.SubtractResponse;
import com.traveloka.bootcamp.subtraction.service.SubtractionService;

public class CalculatorServiceImpl implements CalculatorService {
    // Dependencies on the consumed services
    private final AdditionService additionService;
    private final SubtractionService subtractionService;

    public CalculatorServiceImpl(AdditionService additionService,
                                 SubtractionService subtractionService) {
        this.additionService = additionService;
        this.subtractionService = subtractionService;
    }

    @Override
    public int add(int a, int b) {
        return additionService.add(a, b);
    }

    @Override
    public CalculatorAddResponse add(CalculatorAddRequest calculatorAddRequest) {
        AddRequest addRequest = new AddRequest(calculatorAddRequest.getA(), calculatorAddRequest.getB());
        AddResponse addResponse = additionService.add(addRequest);
        return new CalculatorAddResponse(addResponse.getResult());
    }

    @Override
    public int subtract(int a, int b) {
        return subtractionService.subtract(a, b);
    }

    @Override
    public CalculatorSubtractResponse subtract(CalculatorSubtractRequest calculatorSubtractRequest) {
        SubtractRequest subtractRequest = new SubtractRequest(calculatorSubtractRequest.getA(), calculatorSubtractRequest.getB());
        SubtractResponse subtractResponse = subtractionService.subtract(subtractRequest);
        return new CalculatorSubtractResponse(subtractResponse.getResult());
    }
}