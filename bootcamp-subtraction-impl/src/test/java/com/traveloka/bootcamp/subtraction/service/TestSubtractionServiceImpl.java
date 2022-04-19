package com.traveloka.bootcamp.subtraction.service;

import com.traveloka.bootcamp.subtraction.model.SubtractRequest;
import com.traveloka.bootcamp.subtraction.model.SubtractResponse;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

import static org.testng.Assert.assertEquals;

@Test(groups = "small")
public class TestSubtractionServiceImpl {
    private SubtractionService subtractionService;

    @BeforeClass
    public void setUp() {
        subtractionService = new SubtractionServiceImpl();
    }

    @Test
    public void testSubtract_WithIntegers_ReturnsCorrectResult() {
        assertEquals(subtractionService.subtract(2, 1), 1);
    }

    @Test
    public void testSubtract_WithAddRequest_ReturnsCorrectAddResponse() {
        SubtractResponse subtractResponse = subtractionService.subtract(new SubtractRequest(2, 1));
        assertEquals(subtractResponse.getResult(), 1);
    }
}
