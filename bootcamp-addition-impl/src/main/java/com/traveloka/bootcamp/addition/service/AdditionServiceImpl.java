package com.traveloka.bootcamp.addition.service;

import com.traveloka.bootcamp.addition.model.AddRequest;
import com.traveloka.bootcamp.addition.model.AddResponse;

public class AdditionServiceImpl implements AdditionService {
    @Override
    public int add(int a, int b) {
        return a + b;
    }

    @Override
    public AddResponse add(AddRequest addRequest) {
        int result = add(addRequest.getA(), addRequest.getB());
        return new AddResponse(result);
    }
}
