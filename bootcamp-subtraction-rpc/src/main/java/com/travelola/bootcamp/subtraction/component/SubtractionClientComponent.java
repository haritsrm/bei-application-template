package com.travelola.bootcamp.subtraction.component;

import com.traveloka.bootcamp.subtraction.component.SubtractionComponent;
import com.traveloka.bootcamp.subtraction.service.SubtractionService;
import com.traveloka.common.concurrent.ConcurrentComponent;
import com.traveloka.common.http.HttpClientComponent;
import com.traveloka.common.monitor.OnlineMonitorComponent;
import org.dk.rpc.client.RpcClientSingleEndpointComponent;

public class SubtractionClientComponent implements SubtractionComponent {
    private SubtractionService subtractionService;

    public SubtractionClientComponent(Config config,
                                      HttpClientComponent httpClientComponent,
                                      ConcurrentComponent concurrentComponent,
                                      OnlineMonitorComponent onlineMonitorComponent) {
        RpcClientSingleEndpointComponent<SubtractionService> subtractionServiceRpcClient = new RpcClientSingleEndpointComponent<>(
                config.rpcClient,
                httpClientComponent.getRpcJettyHttpClientFactory(),
                concurrentComponent.getExecutorFactoryBuilder(),
                onlineMonitorComponent.getOnlineMonitorListenerProxyFactory(),
                SubtractionService.class,
                config.hostname,
                config.port,
                "/subtraction");

        subtractionService = subtractionServiceRpcClient.getProxy();
    }

    @Override
    public SubtractionService getSubtractionService() {
        return subtractionService;
    }

    public static class Config {
        RpcClientSingleEndpointComponent.Config rpcClient;
        String hostname;
        int port;
    }
}
