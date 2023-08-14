function ResultDescription=fixmeArchitectureNameChecks(mdlTaskObj)





    ruleName='runArchitectureNameChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};
    model=checker.m_sys;


    hdlset_param(model,'VHDLArchitectureName','rtl');
    ResultDescription=ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_architecture_name_fix'));
end
