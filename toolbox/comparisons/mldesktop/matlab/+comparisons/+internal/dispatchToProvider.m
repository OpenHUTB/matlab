function app=dispatchToProvider(providerList,args)




    import comparisons.internal.getProvidersFor
    availableProviders=getProvidersFor(providerList,args);

    if~isempty(availableProviders)
        chosenProvider=availableProviders(1);
        app=chosenProvider.handle(args{:});
        return
    end

    app=[];
end

