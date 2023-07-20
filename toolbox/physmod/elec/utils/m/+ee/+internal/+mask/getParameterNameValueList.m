function parameterNameValueList=getParameterNameValueList(blockHandle,sortFlag)





    if~exist('sortFlag','var')
        sortFlag=true;
    end
    if ishandle(blockHandle)
        name=get_param(blockHandle,'Name');
        parent=get_param(blockHandle,'Parent');
        blockName=[parent,'/',name];
    else
        blockName=blockHandle;
    end
    paramNames=ee.internal.mask.getUsableParameterNamesSortedOntoTabs(blockName,sortFlag);
    tabNames=fieldnames(paramNames);
    totalParams=0;
    for ii=1:length(tabNames)
        totalParams=totalParams+length(paramNames.(tabNames{ii}));
    end
    parameterNameValueList=cell(totalParams,1);
    currentParam=0;
    for ii=1:length(tabNames)
        for jj=1:length(paramNames.(tabNames{ii}))
            currentParam=currentParam+1;
            valueUnit=ee.internal.mask.getParamWithUnit(blockHandle,paramNames.(tabNames{ii}){jj});
            parameterNameValueList{currentParam}=...
            {paramNames.(tabNames{ii}){jj}...
            ,ee.internal.mask.mat2str(value(valueUnit,unit(valueUnit)))...
            ,tabNames{ii}...
            ,char(unit(valueUnit))};
        end
    end
end
