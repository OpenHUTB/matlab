function ResultDescription=fixmeNFPSuggestionChecks(mdlTaskObj)








    ruleName='runNFPSuggestionChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};
    model=checker.m_sys;

    fc=hdlcoder.createFloatingPointTargetConfig('NATIVEFLOATINGPOINT');
    hdlset_param(model,'FloatingPointTargetConfig',fc);
    ResultDescription=ModelAdvisor.Text('The Target Configuration was changed to Native Floating Point');
end
