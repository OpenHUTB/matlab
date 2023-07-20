function[app,type,lang,appName]=getInfo(obj,mdl)








    app='';
    type='';
    lang='';
    appName='';

    if isempty(mdl)
        return;
    end

    if strcmp(get_param(mdl,'IsERTTarget'),'off')
        if strcmp(get_param(mdl,'UseSimulinkCoderFeatures'),'on')
            app='SimulinkCoder';
            appName='simulinkCoderApp';

            if Simulink.CodeMapping.isCppClassInterface(mdl)
                type='grt_cpp';
                lang='cpp';
            else
                type='grt';
                lang='c';
            end
        end

    elseif Simulink.CodeMapping.isAutosarCompliant(mdl)
        app='Autosar';
        appName='autosarApp';

        if Simulink.CodeMapping.isAutosarAdaptiveSTF(mdl)
            type='autosar_adaptive';
        else
            type='autosar';
        end

        if Simulink.CodeMapping.isCppClassInterface(mdl)
            lang='cpp';
        else
            lang='c';
        end

    elseif strcmp(get_param(mdl,'UseEmbeddedCoderFeatures'),'on')
        mapping=Simulink.CodeMapping.getCurrentMapping(mdl);



        if~isempty(mapping)&&isequal(mapping.DeploymentType,'Application')
            app='DDS';
            appName='ddsApp';
        else
            app='EmbeddedCoder';
            appName='embeddedCoderApp';
        end
        if Simulink.CodeMapping.isCppClassInterface(mdl)
            type='cpp';
            lang='cpp';
        else
            type='ert';
            lang='c';
        end
    end


