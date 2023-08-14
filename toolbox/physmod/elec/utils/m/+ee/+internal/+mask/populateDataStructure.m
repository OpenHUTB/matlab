function localDataSet=populateDataStructure(parameterNameValueList)


    dataStructureName='parameterHelper';
    localDataSet=simscapeBlockDataset(dataStructureName,'');
    for ii=1:length(parameterNameValueList)
        localDataSet.parameters.addParameter(parameterNameValueList{ii}{1},parameterNameValueList{ii}{2});
        localDataSet.parameters.addParameter([parameterNameValueList{ii}{1},'_unit'],parameterNameValueList{ii}{4});
    end
end