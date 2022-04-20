package com.traveloka.bootcamp.calculator.model;

public class CalculatorSubtractRequest {
    private int a;
    private int b;

    public CalculatorSubtractRequest() {}

    public CalculatorSubtractRequest(int a, int b) {
        this.a = a;
        this.b = b;
    }

    public int getA() {
        return a;
    }

    public int getB() {
        return b;
    }
}
