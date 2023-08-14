function update(hObj,event)



    if strcmp(event,'attach')


        registerPropList(hObj,'NoDuplicate','All',[]);
    elseif strcmp(event,'switch_target')
        if~isempty(hObj.getConfigSet)
            hObj.getConfigSet.setProp('TemplateMakefile','fmu2cs_default_tmf');
            hObj.getConfigSet.setPropEnabled('TemplateMakefile','off');
            hObj.getConfigSet.setProp('GenerateMakefile','on');
            hObj.getConfigSet.setPropEnabled('GenerateMakefile','off');
            hObj.getConfigSet.setProp('GenCodeOnly','off');

        end
    end

end

