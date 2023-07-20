function ResultDescription=fixmeFileExtensionChecks(mdlTaskObj)






    ruleName='runFileExtensionChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};
    model=checker.m_sys;

    targetLanguage=hdlget_param(model,'TargetLanguage');

    if strcmpi(targetLanguage,'VHDL')

        hdlset_param(model,'VHDLFileExtension','.vhd');
        extensionStr='''.vhd''';
        ResultDescription=ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_file_extension_fix',targetLanguage,extensionStr));
    else

        hdlset_param(model,'VerilogFileExtension','.v');
        extensionStr='''.v''';
        ResultDescription=ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_file_extension_fix',targetLanguage,extensionStr));
    end
end
