function out=parseInputSpecification(inputSpec,modelUsed)





    out.InputMap=struct();

    if isempty(inputSpec)
        out.error=getString(message('stm:general:MappedFailedNoData'));
        return;
    end

    if length(inputSpec.InputMap)<1



        out.error=getEmptyMessage(inputSpec.Mode,modelUsed);
        return;
    end

    warningCount=0;
    failedCount=0;

    sizeOfSpecs=length(inputSpec.InputMap);
    inputMap=repmat(struct('DataSourceName',[],...
    'PortNumber',[],...
    'BlockPath',[],...
    'BlockName',[],...
    'SignalName',[],...
    'Status',[],...
    'Type',[]),...
    sizeOfSpecs,1);

    if length(inputSpec.InputMap)>0 %#ok<ISMT>






        for i=1:length(inputSpec.InputMap)
            if inputSpec.InputMap(i).Status==0
                failedCount=failedCount+1;
            elseif inputSpec.InputMap(i).Status==2
                warningCount=warningCount+1;
            end

            inputMap(i).DataSourceName=inputSpec.InputMap(i).DataSourceName;
            inputMap(i).PortNumber=inputSpec.InputMap(i).PortNumber;
            inputMap(i).BlockPath=inputSpec.InputMap(i).BlockPath;
            inputMap(i).BlockName=inputSpec.InputMap(i).BlockName;
            inputMap(i).SignalName=inputSpec.InputMap(i).SignalName;
            inputMap(i).Status=double(inputSpec.InputMap(i).Status);
            inputMap(i).Type=inputSpec.InputMap(i).Type;
        end



        if failedCount>0
            out.status=4;
        elseif warningCount>0
            out.status=3;
        else
            out.status=2;
        end


    end

    out.mode=getMappingMode(inputSpec.Mode);
    out.custom=inputSpec.CustomSpecFile;
    out.inputstring=inputSpec.InputString;
    out.InputMap=inputMap;
end

function errorMsg=getEmptyMessage(mappingMode,modelName)
    modeStr='';
    mappingModeUsed=mappingMode;

    if ischar(mappingModeUsed)
        mappingModeUsed=getMappingMode(mappingMode);
    end

    switch lower(mappingModeUsed)
    case 3
        modeStr=getString(message('sl_sta:mapping:radioIndex'));
    case 2
        modeStr=getString(message('sl_inputmap:inputmap:radioSignalName'));
    case 0
        modeStr=getString(message('sl_inputmap:inputmap:radioBlockName'));
    case 1
        modeStr=getString(message('sl_inputmap:inputmap:radioBlockPath'));
    case 4
        modeStr=getString(message('sl_inputmap:inputmap:radioCustom'));
    end

    errorMsg=getString(message('stm:InputsView:emptyMapping',modeStr,modelName));
end

function intMode=getMappingMode(strMode)







    intMode=0;

    if strcmpi(strMode,'BlockPath')
        intMode=1;
    elseif strcmpi(strMode,'SignalName')
        intMode=2;
    elseif strcmpi(strMode,'Index')||strcmpi(strMode,'PortOrder')


        intMode=3;
    elseif strcmpi(strMode,'Custom')
        intMode=4;
    end
end