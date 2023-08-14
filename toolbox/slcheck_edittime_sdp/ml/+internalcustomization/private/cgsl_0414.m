function cgsl_0414

    rec=ModelAdvisor.Check('mathworks.codegen.cgsl_0414');
    msgCatalog=['ModelAdvisor:','sdp',':','cgsl_0414'];
    rec.Title=DAStudio.message([msgCatalog,'_title']);
    rec.TitleTips=[DAStudio.message([msgCatalog,'_guideline']),newline,newline,DAStudio.message([msgCatalog,'_tip'])];
    rec.SupportLibrary=false;
    rec.SupportExclusion=false;
    rec.SupportHighlighting=true;
    rec.Value=false;
    rec.CSHParameters.MapKey='ma.ecoder';
    rec.CSHParameters.TopicID='cgsl_0414';

    context='None';
    rec.setCallbackFcn(@(system,rec)Advisor.Utils.genericCheckCallback(system,rec,msgCatalog,@hCheckAlgo),context,'DetailStyle');

    rec.setLicense({'RTW_Embedded_Coder'});
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sdp_checks});
end

function violations=hCheckAlgo(system)
    violations=[];
    bd=bdroot(system);
    dict=get_param(bd,'EmbeddedCoderDictionary');
    if isempty(dict)

        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'SID',bd);
        vObj.Status=DAStudio.message('ModelAdvisor:sdp:cgsl_0414_warn1');
        vObj.RecAction=DAStudio.message('ModelAdvisor:sdp:cgsl_0414_rec_action1');
        violations=[violations;vObj];
    else
        dictObj=coder.dictionary.open(dict);



        if~strcmp(dictObj.getConfigurationType,'ServiceInterface')
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',bd);
            vObj.Status=DAStudio.message('ModelAdvisor:sdp:cgsl_0414_warn1');
            vObj.RecAction=DAStudio.message('ModelAdvisor:sdp:cgsl_0414_rec_action1');
            violations=[violations;vObj];
        end
    end
    try

        cm=coder.mapping.api.get(bd);
        depType=getDeploymentType(cm);

        if~strcmp(depType,'Component')

            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',bd);
            vObj.Status=DAStudio.message('ModelAdvisor:sdp:cgsl_0414_warn2');
            vObj.RecAction=DAStudio.message('ModelAdvisor:sdp:cgsl_0414_rec_action2');
            violations=[violations;vObj];
        end

    catch
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'SID',bd);
        vObj.Status=DAStudio.message('ModelAdvisor:sdp:cgsl_0414_warn2');
        vObj.RecAction=DAStudio.message('ModelAdvisor:sdp:cgsl_0414_rec_action2');
        violations=[violations;vObj];
    end

    violations=[violations;checkDepTypeForSubmodels(bd)];

end

function violations=checkDepTypeForSubmodels(bd)
    mdlRefs=find_system(bd,'BlockType','ModelReference');
    violations=[];
    for i=1:numel(mdlRefs)
        modelName=get_param(mdlRefs{i},'ModelName');

        try


            load_system(modelName);
            cm=coder.mapping.api.get(modelName);
            depType=getDeploymentType(cm);
            close_system(modelName);
            if~strcmp(depType,'Subcomponent')


                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',mdlRefs{i});
                vObj.Status=DAStudio.message('ModelAdvisor:sdp:cgsl_0414_warn2');
                vObj.RecAction=DAStudio.message('ModelAdvisor:sdp:cgsl_0414_rec_action2');
                violations=[violations;vObj];
            end
        catch
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',mdlRefs{i});
            vObj.Status=DAStudio.message('ModelAdvisor:sdp:cgsl_0414_warn2');
            vObj.RecAction=DAStudio.message('ModelAdvisor:sdp:cgsl_0414_rec_action2');
            violations=[violations;vObj];
            close_system(modelName);
        end
    end
end
