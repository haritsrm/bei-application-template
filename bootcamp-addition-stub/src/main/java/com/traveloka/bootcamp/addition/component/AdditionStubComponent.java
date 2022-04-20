package com.traveloka.bootcamp.addition.component;

import com.traveloka.bootcamp.addition.service.AdditionService;
import com.traveloka.bootcamp.addition.service.AdditionStubService;

public class AdditionStubComponent implements AdditionComponent {
    private final AdditionService additionService;

    public AdditionStubComponent() {
        this.additionService = new AdditionStubService();
    }

    @Override
    public AdditionService getAdditionService() {
        return additionService;
    }
}