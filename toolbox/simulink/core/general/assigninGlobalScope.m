function assigninGlobalScope(model,varName,varValue)






























    model=convertStringsToChars(model);
    if ischar(model)
        load_system(model);
    end



    modelHandle=get_param(model,'Handle');
    if~isempty(modelHandle)&&slprivate('simInputGlobalWSExists',modelHandle)
        warning(message('Simulink:Data:CannotResolveVariablesInSimInputGlobalWS','assigninGlobalScope'));
    end

    varName=convertStringsToChars(varName);
    varInLibDD=0;
    if slfeature('SlModelBroker')>0||slfeature('SLLibrarySLDD')>0

        libDD=slprivate('getAllDictionariesOfLibrary',model);
        varInLibDD=slprivate('updateInDDSetIfExist',libDD,varName,varValue);
    end


    ddSpec=get_param(model,'DataDictionary');

    varInBWS=0;


    if strcmp(get_param(model,'EnableAccessToBaseWorkspace'),'on')
        if(~varInLibDD&&isempty(ddSpec))...
            ||evalin('base',sprintf('exist(''%s'', ''var'')',varName))
            assignin('base',varName,varValue);
            varInBWS=1;
        end
    end



    if~isempty(ddSpec)

        ddConn=Simulink.dd.open(ddSpec);
        if(~varInLibDD&&~varInBWS)...
            ||ddConn.entryExists(['Global.',varName])

            indirectAccessBWS=ddConn.EnableAccessToBaseWorkspace;
            ddConn.assignin(varName,varValue,'Global','SimulinkDataObject',indirectAccessBWS);
        end
        ddConn.close();
    end


