package com.traveloka.bootcamp.calculator.component;

import com.traveloka.bootcamp.addition.component.AdditionComponent;
import com.traveloka.bootcamp.calculator.service.CalculatorService;
import com.traveloka.bootcamp.calculator.service.CalculatorServiceImpl;
import com.traveloka.bootcamp.subtraction.component.SubtractionComponent;

public class CalculatorLocalComponent implements CalculatorComponent {
    private final CalculatorService calculatorService;

    public CalculatorLocalComponent(AdditionComponent additionComponent,
                                    SubtractionComponent subtractionComponent) {
        calculatorService = new CalculatorServiceImpl(
                additionComponent.getAdditionService(),
                subtractionComponent.getSubtractionService()
        );
    }

    @Override
    public CalculatorService getCalculatorService() {
        return calculatorService;
    }
}