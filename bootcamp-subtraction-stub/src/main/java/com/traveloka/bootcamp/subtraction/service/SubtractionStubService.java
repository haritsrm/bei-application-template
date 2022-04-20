package com.traveloka.bootcamp.subtraction.service;

import com.traveloka.bootcamp.subtraction.model.SubtractRequest;
import com.traveloka.bootcamp.subtraction.model.SubtractResponse;

/**
 * Stub implementation of SubtractionService.
 *
 * Note this is duplicate of SubtractionServiceImpl because the real implementation is simple.
 * However, imagine if the real implementation actually depends on other resources as well (e.g. db, other services).
 * Then the stub implementation will hide all of those dependencies.
 */
public class SubtractionStubService implements SubtractionService {
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