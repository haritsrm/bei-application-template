package com.traveloka.bootcamp.subtraction.component;

import com.traveloka.bootcamp.subtraction.service.SubtractionService;
import com.traveloka.bootcamp.subtraction.service.SubtractionStubService;

public class SubtractionStubComponent implements SubtractionComponent {

    private final SubtractionService subtractionService;

    public SubtractionStubComponent() {
        this.subtractionService = new SubtractionStubService();
    }

    @Override
    public SubtractionService getSubtractionService() {
        return subtractionService;
    }
}