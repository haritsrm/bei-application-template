package com.traveloka.bootcamp.calculator.model;

public class CalculatorAddRequest {
    private int a;
    private int b;

    public CalculatorAddRequest() {}

    public CalculatorAddRequest(int a, int b) {
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
