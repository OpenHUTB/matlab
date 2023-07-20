function categories=oldDataCategories()







    categories={'Inports',...
    'Outports',...
    'LocalParameters',...
    'GlobalParameters',...
    'SharedLocalDataStores',...
    'GlobalDataStores',...
    'InternalData',...
    'Constants'};

    categories=[categories(1:3),'ParameterArguments',categories(4:end)];

    if slfeature('EnableModelData')
        categories=[categories,'ModelData'];
    end


