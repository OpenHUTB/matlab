function ResultDescription=fixmeSplitEntityArchitectureChecks(mdlTaskObj)






    ruleName='runSplitEntityArchitectureChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};
    model=checker.m_sys;


    hdlset_param(model,'SplitEntityArch','off');
    ResultDescription=ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_split_entity_architecture_fix'));
end
