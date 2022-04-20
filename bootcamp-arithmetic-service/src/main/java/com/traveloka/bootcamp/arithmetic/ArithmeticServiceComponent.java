package com.traveloka.bootcamp.arithmetic;

import com.traveloka.bootcamp.addition.component.AdditionComponent;
import com.traveloka.bootcamp.addition.component.AdditionLocalComponent;
import com.traveloka.bootcamp.addition.service.AdditionService;
import com.traveloka.bootcamp.subtraction.component.SubtractionComponent;
import com.traveloka.bootcamp.subtraction.component.SubtractionLocalComponent;
import com.traveloka.bootcamp.subtraction.service.SubtractionService;
import com.traveloka.common.application.TopLevelComponent;
import com.traveloka.common.application.healthcheck.HealthCheckService;
import com.traveloka.common.application.jetty.LogConfig;
import com.traveloka.common.application.jetty.LogDestination;
import com.traveloka.common.application.jetty.TravelokaApplication;
import com.traveloka.common.application.jetty.servlet.ServletUrl;
import com.traveloka.common.concurrent.ConcurrentComponent;
import com.traveloka.common.monitor.OnlineMonitorComponent;
import com.traveloka.common.statsd.StatsDComponent;
import org.dk.rpc.server.JsonRpcDoubleDispatchAsyncHttpServlet;
import org.dk.rpc.server.RpcAsyncServletComponent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@TravelokaApplication(port = 8080, group = "arithmetic", logConfigs = {
        @LogConfig(applicationEnv = "dev", logDestination = LogDestination.CONSOLE)
})
public class ArithmeticServiceComponent extends TopLevelComponent {

    private static final Logger logger = LoggerFactory.getLogger(ArithmeticServiceComponent.class);

    @ServletUrl("/addition")
    private final JsonRpcDoubleDispatchAsyncHttpServlet additionServiceRpcServlet;

    @ServletUrl("/subtraction")
    private final JsonRpcDoubleDispatchAsyncHttpServlet subtractionServiceRpcServlet;

    public ArithmeticServiceComponent(String env, String group, String node) {
        super(env, group, node);

        StatsDComponent statsDComponent = new StatsDComponent();
        ConcurrentComponent concurrentComponent = new ConcurrentComponent(statsDComponent);
        OnlineMonitorComponent onlineMonitorComponent = new OnlineMonitorComponent(concurrentComponent, statsDComponent);

        AdditionComponent additionComponent = new AdditionLocalComponent();
        additionServiceRpcServlet = new RpcAsyncServletComponent(
                new RpcAsyncServletComponent.Config(),
                additionComponent.getAdditionService(),
                AdditionService.class,
                onlineMonitorComponent.getOnlineMonitorProcessorFactory()
        ).getServlet();

        SubtractionComponent subtractionComponent = new SubtractionLocalComponent();
        subtractionServiceRpcServlet = new RpcAsyncServletComponent(
                new RpcAsyncServletComponent.Config(),
                subtractionComponent.getSubtractionService(),
                SubtractionService.class,
                onlineMonitorComponent.getOnlineMonitorProcessorFactory()
        ).getServlet();
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
    public void shutdown() {
        logger.debug("Shutting Down...");
    }

    @Override
    public void start() {
        logger.debug("Starting Up...");
    }
}