function ResultDescription=fixmeSubsystemNameChecks(mdlTaskObj)






    checker=hdlcoder.ModelChecker.getModelChecker(mdlTaskObj,'runSubsystemNameChecks');

    List=ModelAdvisor.List;
    List.setType('bulleted');

    candidateBlks=hdlcoder.ModelChecker.getInvalidSubsystemNames(checker.m_DUT);


    for ii=1:numel(candidateBlks)
        blkH=candidateBlks(ii);
        blkName=get_param(blkH,'Name');
        len=strlength(blkName);
        if(len<2)
            newName=lower(strcat(blkName,'_ss'));
        elseif(len>32)
            newName=blkName(1:32);
        else
            continue;
        end
        set_param(blkH,'Name',newName);
        path=getfullname(blkH);
        addtoList(path);
    end

    ResultDescription=[ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_subsystem_name_fix')),List];

    function addtoList(path)
        txtObjAndLink=ModelAdvisor.Text(path);
        as_numeric_string=['char([',num2str(path+0),'])'];
        txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
        List.addItem(txtObjAndLink)
    end

end
