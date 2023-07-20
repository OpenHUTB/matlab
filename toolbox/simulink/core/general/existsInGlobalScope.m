function varExists=existsInGlobalScope(model,varName)




















    varExists=0;


    varName=convertStringsToChars(varName);
    if~isvarname(varName)
        return;
    end


    model=convertStringsToChars(model);
    if ischar(model)&&~bdIsLoaded(model)
        load_system(model);
    end



    modelHandle=get_param(model,'Handle');
    if~isempty(modelHandle)&&slprivate('simInputGlobalWSExists',modelHandle)
        warning(message('Simulink:Data:CannotResolveVariablesInSimInputGlobalWS','existsInGlobalScope'));
    end

    if strcmp(get_param(model,'EnableAccessToBaseWorkspace'),'on')

        varExists=evalin('base',['exist(''',varName,''', ''var'');']);
        if varExists
            return;
        end
    end

    ddSpec=get_param(model,'DataDictionary');
    if~isempty(ddSpec)

        ddConn=Simulink.dd.open(ddSpec);



        varExists=double(ddConn.entryExists(['Global.',varName],true));
        if varExists
            return;
        end
    end


    if(slfeature('SlModelBroker')>0||slfeature('SLLibrarySLDD')>0)
        libDD=slprivate('getAllDictionariesOfLibrary',model);
        varExists=slprivate('existsInDictionarySet',libDD,varName);
    end


