package com.traveloka.bootcamp.addition.service;

public class AdditionServiceImpl implements AdditionService {
    @Override
    public int add(int a, int b) {
        return a + b;
    }

    @Override
    public addResponse add(AddRequest addRequest) {
        int result = add(addRequest.getA(), addRequest.getB());
        return new addResponse(result);
    }
}
