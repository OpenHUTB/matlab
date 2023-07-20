function SLCIModelConfigurationSettings



    mlock;
    [~,panes]=SLCIConfigMap();
    mdladvRoot=ModelAdvisor.Root;
    for i=1:numel(panes)
        idStr=strrep(panes{i},'Pane','Settings');
        rec=ModelAdvisor.Check(['mathworks.slci.',idStr]);
        rec.Title=DAStudio.message(['Slci:compatibility:',panes{i},'Title']);
        rec.CSHParameters.MapKey='ma.slci';
        rec.CSHParameters.TopicID=['mathworks.slci.',idStr];
        rec.setCallbackFcn((@(system)(CheckConfigParams(system,panes{i}))),'None','StyleOne');
        rec.TitleTips=DAStudio.message(['Slci:compatibility:',panes{i},'TitleTips']);
        rec.Value=true;
        rec.PreCallbackHandle=@slciModel_pre;
        rec.PostCallbackHandle=@slciModel_post;
        rec.LicenseName={'Simulink_Code_Inspector'};
        modifyAction=ModelAdvisor.Action;
        modifyAction.setCallbackFcn(@modifyCodeSet);
        modifyAction.Name=DAStudio.message('Slci:compatibility:ModifySettings');
        modifyAction.Description=DAStudio.message(['Slci:compatibility:',panes{i},'ModifyTip']);
        modifyAction.Enable=true;
        rec.setAction(modifyAction);
        mdladvRoot.publish(rec,'Simulink Code Inspector');
    end
end

function ftObjs=CheckConfigParams(system,pane)
    ftObjs=MARunSLCIConfigChecks(pane,system);
end

function result=modifyCodeSet(taskobj)
    mdladvObj=taskobj.MAObj;
    system=bdroot(mdladvObj.System);
    ID=taskobj.getID;
    dots=strfind(taskobj.getID,'.');
    pane=ID(dots(end)+1:end);
    pane=strrep(pane,'Settings','Pane');
    getSLCIModelObj(system,'init');
    result=MARunSLCIConfigChecks(pane,system,'fix');
    result=result.emitHTML;
end







