function processResults(buildResults)
    matlab.ddux.internal.logData(matlab.ddux.internal.DataIdentification("CO","CO_COMPILER","CO_COMPILER_BUILD_RESULTS"),...
    'build_id',buildResults.BuildID,...
    'target',buildResults.BuildType,...
    'build_time',int32(buildResults.BuildDuration));
    if~isempty(buildResults.NumericRuntimeDefinition)
        pcm=matlab.depfun.internal.ProductComponentModuleNavigator;
        productInfo=cellfun(@(X)pcm.productInfo(X),buildResults.NumericRuntimeDefinition);
        produtNames=strrep({productInfo.intPName},'mcrproducts/','');

        matlab.ddux.internal.logData(matlab.ddux.internal.DataIdentification("CO","CO_COMPILER","CO_COMPILER_BUILD_PRODUCTS"),...
        'build_id',buildResults.BuildID,...
        'product_id',string(buildResults.NumericRuntimeDefinition),...
        'product_name',string(produtNames));
    end

    if~isempty(buildResults.IncludedSupportPackages)
        matlab.ddux.internal.logData(matlab.ddux.internal.DataIdentification("CO","CO_COMPILER","CO_COMPILER_BUILD_SP"),...
        'build_id',buildResults.BuildID,...
        'support_packages',string(buildResults.IncludedSupportPackages));
    end



    optionsList={'Interface','SampleGenerationFiles','ClassMap','TreatInputsAsNumeric'};

    optionsProcess={'Value','Set','Count','Value'};
    optionsMap=containers.Map(optionsList,optionsProcess);


    options=properties(buildResults.Options);


    idx=contains(optionsList,options);
    if any(idx)

        collectableOptions=optionsList(idx);

        collectableData=strings(1,length(collectableOptions));
        for i=1:length(collectableOptions)

            optData=buildResults.Options.(collectableOptions{i});
            switch(optionsMap(collectableOptions{i}))
            case 'Value'
                collectableData(i)=string(optData);
            case 'Set'
                if isempty(optData)
                    collectableData(i)="empty";
                else
                    collectableData(i)="set";
                end
            case 'Count'
                collectableData(i)=string(length(optData));
            end
        end


        if~isempty(collectableOptions)
            matlab.ddux.internal.logData(matlab.ddux.internal.DataIdentification("CO","CO_COMPILER","CO_COMPILER_BUILD_OPTIONS"),...
            'build_id',buildResults.BuildID,...
            'options',string(collectableOptions),...
            'options_data',collectableData);
        end


    end

