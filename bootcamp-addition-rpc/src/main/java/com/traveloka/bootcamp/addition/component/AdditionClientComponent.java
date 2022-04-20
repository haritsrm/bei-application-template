package com.traveloka.bootcamp.addition.component;

import com.traveloka.bootcamp.addition.component.AdditionComponent;
import com.traveloka.bootcamp.addition.service.AdditionService;
import com.traveloka.common.concurrent.ConcurrentComponent;
import com.traveloka.common.http.HttpClientComponent;
import com.traveloka.common.monitor.OnlineMonitorComponent;
import org.dk.rpc.client.RpcClientSingleEndpointComponent;

public class AdditionClientComponent implements AdditionComponent {
    private AdditionService additionService;

    public AdditionClientComponent(Config config,
                                   HttpClientComponent httpClientComponent,
                                   ConcurrentComponent concurrentComponent,
                                   OnlineMonitorComponent onlineMonitorComponent) {

        RpcClientSingleEndpointComponent<AdditionService> additionServiceRpcClient =
                new RpcClientSingleEndpointComponent<>(
                        config.rpcClient,
                        httpClientComponent.getRpcJettyHttpClientFactory(),
                        concurrentComponent.getExecutorFactoryBuilder(),
                        onlineMonitorComponent.getOnlineMonitorListenerProxyFactory(),
                        AdditionService.class,
                        config.hostname,
                        config.port,
                        "/addition");

        additionService = additionServiceRpcClient.getProxy();
    }

    @Override
    public AdditionService getAdditionService() {
        return additionService;
    }

    public static class Config {
        RpcClientSingleEndpointComponent.Config rpcClient;
        String hostname;
        int port;
    }
}
