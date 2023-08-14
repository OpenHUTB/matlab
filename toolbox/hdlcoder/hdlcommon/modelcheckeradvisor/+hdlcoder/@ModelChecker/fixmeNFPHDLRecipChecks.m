function ResultDescription=fixmeNFPHDLRecipChecks(mdlTaskObj)




    List=ModelAdvisor.List;
    List.setType('bulleted');

    ruleName='runNFPHDLRecipChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};
    checks=checker.m_Checks;

    for ii=1:length(checks)
        recipBlk=checks(ii).block;
        if getSimulinkBlockHandle(recipBlk)==-1
            continue;
        end


        repBlk=hdlcoder.ModelChecker.replace_block_MAWrapper(recipBlk,'Math');

        set_param(repBlk{1},'Function','reciprocal');

        txtObjAndLink=ModelAdvisor.Text(repBlk{1});
        as_numeric_string=['char([',num2str(repBlk{1}+0),'])'];
        txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
        List.addItem(txtObjAndLink)
    end
    ResultDescription=[ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:block_level_fix')),List];
end
