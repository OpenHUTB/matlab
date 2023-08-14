function out=dispatchToNoGUIProvider(providerList,args)




    out='';

    import comparisons.internal.getProvidersFor
    availableProviders=getProvidersFor(providerList,args);

    if~isempty(availableProviders)
        chosenProvider=availableProviders(1);
        out=chosenProvider.handle(args{:});
    end
end