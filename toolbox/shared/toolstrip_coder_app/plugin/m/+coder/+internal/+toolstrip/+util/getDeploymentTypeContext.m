function ctx=getDeploymentTypeContext(mdl)



    ctx='';
    cgb=get_param(mdl,'CodeGenBehavior');
    switch cgb
    case 'None'
        return;
    case 'Inherit'
        dpType='Auto';
    case 'Default'
        mapping=Simulink.CodeMapping.getCurrentMapping(mdl);
        if~isempty(mapping)&&isa(mapping,'Simulink.CoderDictionary.ModelMapping')
            dpType=mapping.DeploymentType;
            if strcmp(dpType,'Unset')
                dpType='Auto';
            end
        else
            pt=coder.internal.toolstrip.util.getPlatformType(mdl);
            if pt==0
                dpType='Auto';
            else
                dpType='Component';
            end
        end
    end

    ctx=['Deploy_',dpType];