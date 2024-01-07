function datapathVisibilityUpdate(block,indepParamName)
    if~strcmp(get_param(bdroot(block),'SimulationStatus'),'stopped')

        return;
    end
    simStatus=get_param(bdroot(block),'SimulationStatus');
    systemObject=serdes.internal.callbacks.getSystemObject(block);
    if strcmp(simStatus,'stopped')&&~isempty(systemObject)
        indepValue=getSerDesSysObjValue(block,indepParamName);
        systemObject.(indepParamName)=indepValue;

        mask=Simulink.Mask.get(block);
        paramNames=fieldnames(systemObject);
        for paramIdx=1:size(paramNames,1)
            paramName=paramNames{paramIdx};
            if~strcmp(paramName,indepParamName)
                depParam=mask.getParameter(paramName);
                if~isempty(depParam)
                    if systemObject.isInactiveProperty(paramName)
                        depParam.set('Visible','off');
                    else
                        depParam.set('Visible','on');
                    end
                end
            end
        end
    end
end


function value=getSerDesSysObjValue(block,parameterName)

    strValue=get_param(block,parameterName);
    switch parameterName
    case 'Mode'

        switch strValue
        case 'Off'
            value=0;
        case 'On'
            value=1;
        case 'Fixed'
            value=1;
        case 'Adapt'
            value=2;
        end
    case 'Specification'
        value=strValue;
    otherwise
        value=str2double(strValue);
    end
end