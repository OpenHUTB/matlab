function remappedName=mapDataStoreName(subsys,name)




    remappedName=name;
    if slfeature('SSMaskDataStores')
        dataStoreNames=get_param(subsys,'DSMNamesCell');
        dataStoreValues=get_param(subsys,'DSMValuesCell');
        numNames=length(dataStoreNames);
        numValues=length(dataStoreValues);
        if numNames==numValues
            for i=1:numNames
                if strcmp(name,dataStoreNames{i})
                    remappedName=dataStoreValues{i};
                    break
                end
            end
        end
    end
