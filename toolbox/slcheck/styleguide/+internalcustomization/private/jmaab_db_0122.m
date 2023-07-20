function jmaab_db_0122

    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.CheckStrongDataTyping';
    SubCheckCfg(1).subcheck.InitParams.Name='db_0122_a';

    rec=slcheck.Check('mathworks.jmaab.db_0122',SubCheckCfg,{sg_maab_group,sg_jmaab_group});
    rec.relevantEntities=@getRelevantBlocks;
    rec.setDefaultInputParams();
    rec.LicenseString={styleguide_license,'Stateflow'};
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;

    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@modifyStrongDataTypingProperty);
    modifyAction.Name=DAStudio.message('ModelAdvisor:jmaab:db_0122_ModifyButtonText');
    modifyAction.Description=DAStudio.message('ModelAdvisor:jmaab:db_0122_ModifyButtonDesc');
    modifyAction.Enable=true;
    rec.setAction(modifyAction);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);
end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    entities=Advisor.Utils.Stateflow.sfFindSys...
    (system,FollowLinks,LookUnderMasks,{'-isa','Stateflow.Chart'},false);
end

function result=modifyStrongDataTypingProperty(taskobj)
    result=ModelAdvisor.Paragraph();
    mdladvObj=taskobj.MAObj;
    rt=sfroot;

    ResultData=mdladvObj.getCheckResult(taskobj.MAC);
    sfhandle=Simulink.ID.getHandle(ResultData{1}.ListObj);
    sfObj=cellfun(@(x)rt.idToHandle(sfprivate('block2chart',x)),sfhandle,'UniformOutput',false);

    tmpText=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:jmaab:db_0122_FontUpdateText'));
    tmpText.setColor('pass');

    result.addItem(tmpText);
    result.addItem(' Total:')
    result.addItem(ModelAdvisor.Text(mat2str(length(sfObj))));
    result.addItem(ModelAdvisor.LineBreak);
    result.addItem(ModelAdvisor.LineBreak);
    resultList=ModelAdvisor.List;


    for i=1:length(sfObj)
        if length(sfObj{i}.Name)>=1
            resultList.addItem(sfObj{i}.getFullName);
        end
    end

    result.addItem(resultList);


    mdladvObj.setActionEnable(false);

end