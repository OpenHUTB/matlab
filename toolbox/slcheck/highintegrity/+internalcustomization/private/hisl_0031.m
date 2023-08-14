function hisl_0031

    rec=getNewCheckObject('mathworks.hism.hisl_0031',false,@hCheckAlgo,'None');

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function violations=hCheckAlgo(system)


    violations=[];
    modelName=bdroot(system);
    modelNameLen=length(modelName);
    recActionString='';

    if modelNameLen<=2||modelNameLen>64
        recActionString=[recActionString,'<li>',DAStudio.message('ModelAdvisor:hism:hisl_0031_issue_name_length'),'</li>'];
    end
    if~isempty(regexp(modelName,'([^a-zA-Z_0-9])|(^\d)|(^ )','once'))
        recActionString=[recActionString,'<li>',DAStudio.message('ModelAdvisor:hism:hisl_0031_issue_name_characters'),'</li>'];
    end
    if~isempty(regexp(modelName,'(^_)|(_$)','once'))
        recActionString=[recActionString,'<li>',DAStudio.message('ModelAdvisor:hism:hisl_0031_issue_name_underscore2'),'</li>'];
    end
    if~isempty(regexp(modelName,'(__)','once'))
        recActionString=[recActionString,'<li>',DAStudio.message('ModelAdvisor:hism:hisl_0031_issue_name_underscore'),'</li>'];
    end
    if Advisor.Utils.isaKeyword(modelName)
        recActionString=[recActionString,'<li>',DAStudio.message('ModelAdvisor:hism:hisl_0031_issue_name_reserved'),'</li>'];
    end

    if~isempty(recActionString)
        recActionString=['<ul>',recActionString,'</ul>'];
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'SID',modelName);
        vObj.RecAction=[DAStudio.message('ModelAdvisor:hism:hisl_0031_rec_action'),recActionString];
        violations=vObj;
    end

end
