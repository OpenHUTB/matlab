function ResultDescription=fixmeInlineConfigurationsChecks(mdlTaskObj)


    ruleName='runInlineConfigurationsChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};
    model=checker.m_sys;


    hdlset_param(model,'InlineConfigurations','on');
    ResultDescription=ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:fix_runInlineConfigurationsChecks'));
end
