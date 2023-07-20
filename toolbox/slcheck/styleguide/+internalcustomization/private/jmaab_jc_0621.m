function jmaab_jc_0621

    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.jmaab.jc_0621');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0621_title');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:jmaab:jc_0621_guideline'),newline,newline,DAStudio.message('ModelAdvisor:jmaab:jc_0621_tip')];


    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=true;
    rec.SupportsEditTime=true;

    inputParam1=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam2=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam2.Value='graphical';
    rec.setInputParameters({inputParam1,inputParam2});
    rec.setInputParametersLayoutGrid([1,6]);

    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@checkActionCallback);
    modifyAction.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');
    modifyAction.Description=DAStudio.message('ModelAdvisor:jmaab:jc_0621_ActionDescription');
    modifyAction.Enable=false;
    rec.setAction(modifyAction);

    rec.setReportStyle('ModelAdvisor.Report.BlockParameterStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.BlockParameterStyle'});
    rec.setLicense({styleguide_license});
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end
function result=checkActionCallback(~)
    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
    mdladvObj.setActionEnable(false);
    checkObj=mdladvObj.getCheckObj('mathworks.jmaab.jc_0621');


    FailingObjs=checkObj.ResultDetails;
    FailingObjs=arrayfun(@(x)x.Data,FailingObjs,'UniformOutput',false);
    cellfun(@(x)set_param(x,'IconShape','rectangular'),FailingObjs);

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(0);
    ft.setInformation(DAStudio.message('ModelAdvisor:jmaab:jc_0621_Action'));
    ft.setListObj(FailingObjs);

    result=ModelAdvisor.Paragraph;
    result.addItem(ft.emitContent);
end
