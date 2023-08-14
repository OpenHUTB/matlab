function init(obj)




    model=obj.name;
    try


        obj.refMdls=find_mdlrefs(model,'AllLevels',0,'ReturnTopModelAsLastElement',0,...
        'KeepModelsLoaded',1,'MatchFilter',@Simulink.match.allVariants);
    catch
        obj.refMdls={};
    end

    cgb=get_param(model,'CodeGenBehavior');
    obj.CodeGen=~strcmp(cgb,'None');
    obj.CoderDictionary=get_param(model,'EmbeddedCoderDictionary');
    obj.DeploymentType=0;
    mapping=Simulink.CodeMapping.getCurrentMapping(model);
    if~isempty(mapping)
        dt=mapping.DeploymentType;
        if strcmp(dt,'Subcomponent')
            obj.DeploymentType=2;
        elseif strcmp(dt,'Component')||strcmp(dt,'Automatic')
            obj.DeploymentType=1;
        end
    end

