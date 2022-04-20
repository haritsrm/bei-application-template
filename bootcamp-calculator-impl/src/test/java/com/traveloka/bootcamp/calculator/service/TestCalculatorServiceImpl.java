package com.traveloka.bootcamp.calculator.service;

import com.traveloka.bootcamp.addition.component.AdditionComponent;
import com.traveloka.bootcamp.addition.component.AdditionStubComponent;
import com.traveloka.bootcamp.subtraction.component.SubtractionComponent;
import com.traveloka.bootcamp.subtraction.component.SubtractionStubComponent;
import org.testng.annotations.Test;

import static org.testng.Assert.*;

@Test(groups = "small")
public class TestCalculatorServiceImpl {

    private final CalculatorService calculatorService;

    public TestCalculatorServiceImpl() {
        // creates stub components
        AdditionComponent additionComponent = new AdditionStubComponent();
        SubtractionComponent subtractionComponent = new SubtractionStubComponent();

        calculatorService = new CalculatorServiceImpl(
                additionComponent.getAdditionService(),
                subtractionComponent.getSubtractionService()
        );
    }

    @Test
    public void testAdd_WithIntegers_ReturnCorrectResult() {
        assertEquals(calculatorService.add(1, 2), 3);
    }

    @Test
    public void testSubtract_WithIntegers_ReturnCorrectResult() {
        assertEquals(calculatorService.subtract(2, 1), 1);
    }

    // and so on...
}