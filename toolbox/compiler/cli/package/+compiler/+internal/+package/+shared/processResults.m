function processResults(packageID,buildID,target,runtimeProducts,pkgOptions,packageTime,packageSize)





    matlab.ddux.internal.logData(matlab.ddux.internal.DataIdentification("CO","CO_COMPILER","CO_COMPILER_PACKAGE_RESULTS"),...
    'build_id',string(buildID),...
    'package_id',string(packageID),...
    'target',string(target),...
    'package_size',int64(packageSize),...
    'package_time',int64(packageTime));



    if~isempty(runtimeProducts)
        pcm=matlab.depfun.internal.ProductComponentModuleNavigator;
        productInfo=cellfun(@(X)pcm.productInfo(X),runtimeProducts);
        produtNames=strrep({productInfo.intPName},'mcrproducts/','');

        matlab.ddux.internal.logData(matlab.ddux.internal.DataIdentification("CO","CO_COMPILER","CO_COMPILER_PACKAGE_PRODUCTS"),...
        'package_id',string(packageID),...
        'product_id',string(runtimeProducts),...
        'product_name',string(produtNames));
    end

    if~isempty(pkgOptions)

        options=properties(pkgOptions);

        optionsList={'ExecuteDockerBuild','AdditionalInstructions','AdditionalPackages'};

        optionsProcess={'Value','Count','Count'};
        optionsMap=containers.Map(optionsList,optionsProcess);


        idx=contains(optionsList,options);
        if any(idx)

            collectableOptions=optionsList(idx);

            collectableData=strings(1,length(collectableOptions));
            for i=1:length(collectableOptions)

                optData=pkgOptions.(collectableOptions{i});
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
                matlab.ddux.internal.logData(matlab.ddux.internal.DataIdentification("CO","CO_COMPILER","CO_COMPILER_PACKAGE_OPTIONS"),...
                'package_id',packageID,...
                'options',string(collectableOptions),...
                'options_data',collectableData);
            end
        end

    end


