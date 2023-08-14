function ResultDescription=fixmeNFPDTCChecks(mdlTaskObj)




    List=ModelAdvisor.List;
    List.setType('bulleted');

    ruleName='runNFPDTCChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};
    checks=checker.m_Checks;

    for ii=1:length(checks)
        dtcBlock=checks(ii).block;
        if getSimulinkBlockHandle(dtcBlock)==-1
            continue;
        end


        hdlcoder.ModelChecker.replace_block_MAWrapper(dtcBlock,'FloatTypecast');

        txtObjAndLink=ModelAdvisor.Text(dtcBlock);
        as_numeric_string=['char([',num2str(dtcBlock+0),'])'];
        txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
        List.addItem(txtObjAndLink)
    end
    ResultDescription=[ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:block_level_fix')),List];
end
