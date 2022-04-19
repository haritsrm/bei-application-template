package com.traveloka.bootcamp.subtraction.model;

public class SubtractRequest {
    private int a;
    private int b;

    public SubtractRequest() {}

    public SubtractRequest(int a, int b) {
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
