function ResultDescription=fixmeHDLRecipChecks(mdlTaskObj)




    List=ModelAdvisor.List;
    List.setType('bulleted');

    ruleName='runHDLRecipChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};
    checks=checker.m_Checks;

    for ii=1:length(checks)
        blkType=get_param(checks(ii).block,'BlockType')
        if strcmpi(blkType,'Reciprocal')
            recipBlk=checks(ii).block;
            if getSimulinkBlockHandle(recipBlk)==-1
                continue;
            end


            repBlk=hdlcoder.ModelChecker.replace_block_MAWrapper(recipBlk,'Math');

            set_param(repBlk{1},'Function','reciprocal');


            set_param(repBlk{1},'AlgorithmMethod','Newton-Raphson');
            set_param(repBlk{1},'AlgorithmType','Newton-Raphson');

            txtObjAndLink=ModelAdvisor.Text(repBlk{1});
            as_numeric_string=['char([',num2str(repBlk{1}+0),'])'];
            txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
            List.addItem(txtObjAndLink)
        elseif strcmpi(blkType,'Math')
            MathBlk=checks(ii).block;
            if getSimulinkBlockHandle(MathBlk)==-1
                continue;
            end


            productBlk=hdlcoder.ModelChecker.replace_block_MAWrapper(MathBlk,'Product');

            set_param(productBlk{1},'Inputs','/');

            hdlset_param(productBlk,'Architecture','ShiftAdd');

            set_param(productBlk{1},'OutDataTypeStr','Inherit: Inherit via internal rule')

            txtObjAndLink=ModelAdvisor.Text(productBlk{1});
            as_numeric_string=['char([',num2str(productBlk{1}+0),'])'];
            txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
            List.addItem(txtObjAndLink)
        end
    end
    ResultDescription=[ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:block_level_fix')),List];
end
