package com.traveloka.bootcamp.subtraction.service;

import com.traveloka.bootcamp.subtraction.model.SubtractRequest;
import com.traveloka.bootcamp.subtraction.model.SubtractResponse;

public class SubtractionServiceImpl implements SubtractionService {
    @Override
    public int subtract(int a, int b) {
        return a - b;
    }

    @Override
    public SubtractResponse subtract(SubtractRequest request) {
        int result = subtract(request.getA(), request.getB());
        return new SubtractResponse(result);
    }
}
