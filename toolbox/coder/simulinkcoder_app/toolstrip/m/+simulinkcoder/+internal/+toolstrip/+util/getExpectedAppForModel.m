function app=getExpectedAppForModel(mdl)




    if Simulink.CodeMapping.isAutosarCompliant(mdl)
        app='AutosarApp';
    elseif strcmp(get_param(mdl,'IsERTTarget'),'on')
        app='EmbeddedCoderApp';
    else
        app='SimulinkCoderApp';
    end