function populateDataStructureInModel(testModelName,parameterNameValueList)


    dataStructureName='parameterHelper';
    initializationString=sprintf('%s = simscapeBlockDataset(''%s'',''Parameter helper object for %s'');',...
    dataStructureName,dataStructureName,testModelName);
    mws=get_param(testModelName,'modelworkspace');
    evalin(mws,initializationString);
    localDataSet=evalin(mws,dataStructureName);
    for ii=1:length(parameterNameValueList)
        set_param([testModelName,'/DUT'],parameterNameValueList{ii}{1},parameterNameValueList{ii}{2},...
        [parameterNameValueList{ii}{1},'_UNIT'],parameterNameValueList{ii}{4});
        localDataSet.parameters.addParameter(parameterNameValueList{ii}{1},parameterNameValueList{ii}{2});
    end
end