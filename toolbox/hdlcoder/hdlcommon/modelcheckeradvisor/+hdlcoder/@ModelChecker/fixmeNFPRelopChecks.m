function ResultDescription=fixmeNFPRelopChecks(mdlTaskObj)




    List=ModelAdvisor.List;
    List.setType('bulleted');

    ruleName='runNFPRelopChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};
    checks=checker.m_Checks;

    for ii=1:length(checks)
        relopBlk=checks(ii).block;
        if getSimulinkBlockHandle(relopBlk)==-1
            continue;
        end

        set_param(relopBlk,'OutDataTypeStr','boolean');
        txtObjAndLink=ModelAdvisor.Text(relopBlk);
        as_numeric_string=['char([',num2str(relopBlk+0),'])'];
        txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
        List.addItem(txtObjAndLink)
    end
    ResultDescription=[ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:block_level_fix')),List];
end
