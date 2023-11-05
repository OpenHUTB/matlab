function availableProviders=getProvidersFor(providerList,args)
    registry=comparisons.internal.Registry.Instance;
    providers=registry.(providerList);
    canHandle=arrayfun(...
    @(provider)providerCanHandle(provider,args),...
providers...
    );
    availableProviders=providers(canHandle);

    if~isempty(availableProviders)
        priorities=arrayfun(@(x)x.getPriority(args{:}),availableProviders);
        [~,inds]=sort(priorities,"descend");
        availableProviders=availableProviders(inds);
    end
end

function bool=providerCanHandle(provider,args)
    try
        bool=provider.canHandle(args{:});
    catch
        bool=false;
    end
end
