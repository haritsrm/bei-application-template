package com.traveloka.bootcamp.calculator;

import com.traveloka.bootcamp.addition.component.AdditionClientComponent;
import com.traveloka.bootcamp.addition.component.AdditionComponent;
import com.traveloka.bootcamp.calculator.component.CalculatorComponent;
import com.traveloka.bootcamp.calculator.component.CalculatorLocalComponent;
import com.traveloka.bootcamp.calculator.model.CalculatorAddRequest;
import com.traveloka.bootcamp.calculator.model.CalculatorSubtractRequest;
import com.traveloka.bootcamp.calculator.service.CalculatorService;
import com.travelola.bootcamp.subtraction.component.SubtractionClientComponent;
import com.traveloka.bootcamp.subtraction.component.SubtractionComponent;
import com.traveloka.common.application.TopLevelComponent;
import com.traveloka.common.application.healthcheck.HealthCheckService;
import com.traveloka.common.application.jetty.LogConfig;
import com.traveloka.common.application.jetty.LogDestination;
import com.traveloka.common.application.jetty.TravelokaApplication;
import com.traveloka.common.concurrent.ConcurrentComponent;
import com.traveloka.common.concurrent.ExecutorServiceSpec;
import com.traveloka.common.groovy.GroovyConfigParser;
import com.traveloka.common.http.HttpClientComponent;
import com.traveloka.common.monitor.OnlineMonitorComponent;
import com.traveloka.common.statsd.StatsDComponent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Random;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@TravelokaApplication(port = 8081, group = "arithmetic", logConfigs = {
        @LogConfig(applicationEnv = "dev", logDestination = LogDestination.CONSOLE)
})
public class CalculatorServiceComponent extends TopLevelComponent {

    private static final Logger logger = LoggerFactory.getLogger(CalculatorServiceComponent.class);
    private final AdditionRunnable additionRunnable;
    private final SubtractionRunnable subtractionRunnable;
    private ScheduledExecutorService additionScheduledExecutorService;
    private ScheduledExecutorService subtractionScheduledExecutorService;

    public CalculatorServiceComponent(String env, String group, String node) {
        super(env, group, node);

        // Initialise OnlineMonitoringComponent
        StatsDComponent statsDComponent = new StatsDComponent();
        ConcurrentComponent concurrentComponent = new ConcurrentComponent(statsDComponent);
        HttpClientComponent httpClientComponent = new HttpClientComponent(concurrentComponent);
        OnlineMonitorComponent onlineMonitorComponent = new OnlineMonitorComponent(concurrentComponent, statsDComponent);

        // Create AdditionComponent and SubtractionComponent based on Client config
        AdditionComponent additionComponent = new AdditionClientComponent(
                GroovyConfigParser.parseFromDir("additionClient", AdditionClientComponent.Config.class),
                httpClientComponent,
                concurrentComponent,
                onlineMonitorComponent
        );
        SubtractionComponent subtractionComponent = new SubtractionClientComponent(
                GroovyConfigParser.parseFromDir("subtractionClient", SubtractionClientComponent.Config.class),
                httpClientComponent,
                concurrentComponent,
                onlineMonitorComponent
        );

        CalculatorComponent calculatorComponent = new CalculatorLocalComponent(additionComponent, subtractionComponent);
        additionScheduledExecutorService = concurrentComponent.getExecutorFactoryBuilder().createScheduledThreadPool(
                new ExecutorServiceSpec(1, "tv-addition-%d")
        );
        additionRunnable = new AdditionRunnable(calculatorComponent.getCalculatorService());

        subtractionScheduledExecutorService = concurrentComponent.getExecutorFactoryBuilder().createScheduledThreadPool(
                new ExecutorServiceSpec(1, "tv-subtraction-%d")
        );
        subtractionRunnable = new SubtractionRunnable(calculatorComponent.getCalculatorService());
    }

    @Override
    public HealthCheckService getHealthCheckService() {
        return new HealthCheckService() {
            @Override
            protected Status check() {
                return Status.HEALTHY;
            }
        };
    }

    @Override
    public void start() {
        logger.info("Starting Up...");
        additionScheduledExecutorService.scheduleAtFixedRate(
                additionRunnable,
                0,
                250,
                TimeUnit.MILLISECONDS
        );
        subtractionScheduledExecutorService.scheduleAtFixedRate(
                subtractionRunnable,
                0,
                250,
                TimeUnit.MILLISECONDS
        );
    }

    @Override
    public void shutdown() {
        logger.info("Shutting Down...");
        additionScheduledExecutorService.shutdown();
        subtractionScheduledExecutorService.shutdown();
    }

    private static class AdditionRunnable implements Runnable {

        private final CalculatorService calculatorService;
        private final Random random;

        AdditionRunnable(CalculatorService calculatorService) {
            this.calculatorService = calculatorService;
            random = new Random();
        }

        @Override
        public void run() {
            int a = random.nextInt();
            int b = random.nextInt();

            logger.info(String.format("%d + %d = %d",
                    a,
                    b,
                    this.calculatorService.add(a, b)));

            int a1 = random.nextInt();
            int b1 = random.nextInt();

            logger.info(String.format("%d + %d = %d",
                    a1,
                    b1,
                    calculatorService.add(new CalculatorAddRequest(a1, b1)).getResult()));
        }
    }

    private static class SubtractionRunnable implements Runnable {

        private final CalculatorService calculatorService;
        private final Random random;

        SubtractionRunnable(CalculatorService calculatorService) {
            this.calculatorService = calculatorService;
            random = new Random();
        }

        @Override
        public void run() {
            int a = random.nextInt();
            int b = random.nextInt();

            logger.info(String.format("%d - %d = %d",
                    a,
                    b,
                    this.calculatorService.subtract(a, b)));

            int a1 = random.nextInt();
            int b1 = random.nextInt();

            logger.info(String.format("%d - %d = %d",
                    a1,
                    b1,
                    calculatorService.subtract(new CalculatorSubtractRequest(a1, b1)).getResult()));
        }
    }
}