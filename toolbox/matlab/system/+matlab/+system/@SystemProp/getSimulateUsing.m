function simUsing=getSimulateUsing(systemName,platformName)











    if nargin<=1
        platformName='Simulink';
    end

    fcnStr=[systemName,'.getSimulateUsingImpl'];
    if hasPlatformArgument(systemName)
        simUsing=feval(fcnStr,platformName);
    else
        simUsing=feval(fcnStr);
    end

    if isempty(simUsing)
        error(message('MATLAB:system:getSimulateUsingIsEmpty'))
    end

    if~(isstring(simUsing)||ischar(simUsing)||iscellstr(simUsing))
        error(message('MATLAB:system:getSimulateUsingInvalidType'));
    end

    simUsing=convertStringsToChars(simUsing);


    if ischar(simUsing)
        simUsing={simUsing};
    end

    isValueInvalid=~ismember(simUsing,{'Code generation','Interpreted execution'});
    if any(isValueInvalid)
        invalidValues=simUsing(isValueInvalid);
        error(message('MATLAB:system:getSimulateUsingInvalidValue',invalidValues{1}));
    end


    simUsing=unique(simUsing);
end

function result=hasPlatformArgument(systemName)
    result=false;
    metaClass=meta.class.fromName(systemName);
    mm=findobj(metaClass.MethodList,'-depth',0,'Name','getSimulateUsingImpl');
    if~isempty(mm)&&numel(mm.InputNames)>0
        result=true;
    end
end