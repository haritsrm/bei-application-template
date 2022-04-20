package com.traveloka.bootcamp.addition.service;

import com.traveloka.bootcamp.addition.model.AddRequest;
import com.traveloka.bootcamp.addition.model.AddResponse;

/**
 * Stub implementation of AdditionService.
 *
 * Note this is duplicate of AdditionServiceImpl because the real implementation is simple.
 * However, imagine if the real implementation actually depends on other resources as well (e.g. db, other services).
 * Then the stub implementation will hide all of those dependencies.
 */
public class AdditionStubService implements AdditionService {
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