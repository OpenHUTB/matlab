function enabled=directoryListing(newEnabled)
    if connector.isRunning
        if nargin==1
            connector.internal.configurationSet('connector.directoryListing',newEnabled).get();
        end

        enabled=connector.internal.configurationGet('connector.directoryListing').get().value;
    else
        warning('Connector:MissingConfiguration','The configuration service was not loaded.');
        enabled=false;
    end
end
