package com.traveloka.bootcamp.subtraction.component;

import com.traveloka.bootcamp.subtraction.service.SubtractionService;
import com.traveloka.bootcamp.subtraction.service.SubtractionServiceImpl;

public class SubtractionLocalComponent implements SubtractionComponent {
    private final SubtractionService subtractionService;

    public SubtractionLocalComponent() {
        this.subtractionService = new SubtractionServiceImpl();
    }

    @Override
    public SubtractionService getSubtractionService() {
        return subtractionService;
    }
}
