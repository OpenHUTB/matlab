function importParameters(oldBlockH,newBlockH,inlineAll)







    oldCompImpl=systemcomposer.utils.getArchitecturePeer(oldBlockH);
    oldComp=systemcomposer.internal.getWrapperForImpl(oldCompImpl);

    paramNames=oldComp.getParameterNames;

    if isempty(paramNames)
        return;
    end

    newCompImpl=systemcomposer.utils.getArchitecturePeer(newBlockH);
    newComp=systemcomposer.internal.getWrapperForImpl(newCompImpl);

    for paramName=paramNames
        locCopyOneParameter(oldComp,newComp,paramName,inlineAll);
    end

end


function locCopyOneParameter(oldComp,newComp,paramName,inlineAll)



    param=oldComp.Architecture.getParameter(paramName);
    paramDef=param.Type;

    isPromoted=contains(paramName,".");

    if isPromoted

        if inlineAll

            path=extractBefore(paramName,'.');
            name=extractAfter(paramName,'.');
            newComp.Architecture.exposeParameter(Path=path,Parameters=name);
            newParamName=paramName;
        else


            newParamName=replace(paramName,{'.','/'},"_");
            newComp.Architecture.addParameter(newParamName,...
            Type=paramDef.Type,...
            Dimensions=paramDef.Dimensions,...
            Complexity=paramDef.Complexity,...
            Value=param.Value,...
            Units=paramDef.Units,...
            Description=paramDef.Description,...
            Minimum=paramDef.Minimum,...
            Maximum=paramDef.Maximum);
        end
    else

        newParamName=paramDef.Name;
        newComp.Architecture.addParameter(newParamName,...
        Type=paramDef.Type,...
        Dimensions=paramDef.Dimensions,...
        Complexity=paramDef.Complexity,...
        Value=param.Value,...
        Units=paramDef.Units,...
        Description=paramDef.Description,...
        Minimum=paramDef.Minimum,...
        Maximum=paramDef.Maximum);
    end


    paramValue=oldComp.getParameterValue(paramName);
    newComp.setParameterValue(newParamName,paramValue);

end