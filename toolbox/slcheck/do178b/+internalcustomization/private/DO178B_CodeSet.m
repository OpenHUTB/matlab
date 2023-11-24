function DO178B_CodeSet

    dataFilePath=[matlabroot,filesep,'toolbox',filesep,'slcheck',filesep,'do178b',filesep,'private',filesep];

    rec=ModelAdvisor.Check('mathworks.do178.CodeSet');
    rec.Title=DAStudio.message('ModelAdvisor:do178b:CodeSetTitle');
    rec.CSHParameters.MapKey='ma.do178b';
    rec.CSHParameters.TopicID='CodeSetTitle';
    rec.setCallbackFcn(@(system)(Advisor.authoring.CustomCheck.checkCallback(system,...
    [dataFilePath,'DO178_CodeSet.xml'])),...
    'None','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:do178b:CodeSetTip');
    rec.setLicense({do178b_license});
    rec.Value(true);

    act=ModelAdvisor.Action;
    act.setCallbackFcn(@(task)(Advisor.authoring.CustomCheck.actionCallback(task)));
    act.Name=DAStudio.message('Advisor:engine:CCModifyButton');
    act.Description=DAStudio.message('Advisor:engine:CCActionDescription');
    rec.setAction(act)

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);