
function DO178B_OptionSet


    dataFilePath=[matlabroot,filesep,'toolbox',filesep,'slcheck',filesep,'do178b',filesep,'private',filesep];

    rec=ModelAdvisor.Check('mathworks.do178.OptionSet');
    rec.Title=DAStudio.message('ModelAdvisor:do178b:OptionSetTitle');
    rec.CSHParameters.MapKey='ma.do178b';
    rec.CSHParameters.TopicID='OptionSetTitle';
    rec.setCallbackFcn(@(system)(Advisor.authoring.CustomCheck.checkCallback(system,...
    [dataFilePath,'DO178_OptionSet.xml'])),...
    'None','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:do178b:OptionSetTip');
    rec.setLicense({do178b_license});
    rec.Value(true);

    act=ModelAdvisor.Action;
    act.setCallbackFcn(@(task)(Advisor.authoring.CustomCheck.actionCallback(task)));
    act.Name=DAStudio.message('Advisor:engine:CCModifyButton');
    act.Description=DAStudio.message('Advisor:engine:CCActionDescription');
    rec.setAction(act)

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);