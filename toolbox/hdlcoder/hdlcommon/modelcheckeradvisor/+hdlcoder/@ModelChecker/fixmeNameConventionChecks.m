function ResultDescription=fixmeNameConventionChecks(mdlTaskObj)







    ruleName='runNameConventionChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};
    List=ModelAdvisor.List;
    List.setType('bulleted');
    FailedList=ModelAdvisor.List;
    FailedList.setType('bulleted');


    [candidateBlks,candidateSignals]=hdlcoder.ModelChecker.getInvalidNames(checker.m_DUT);

    invPattern=({'vdd','vss','gnd','vcc','vref'});

    for ii=1:numel(candidateBlks)
        blkH=candidateBlks(ii);
        blkName=get_param(blkH,'Name');

        newblkName=replace(lower(blkName),invPattern,'rsvd');
        try
            set_param(blkH,'Name',newblkName);
        catch me %#ok<NASGU>
            path=getfullname(blkH);
            addtoList(path,FailedList);
            continue;
        end

        path=getfullname(blkH);
        addtoList(path,List);
    end


    for ii=1:numel(candidateSignals)
        sigH=candidateSignals(ii);
        sigName=get_param(sigH,'Name');

        newSigName=replace(lower(sigName),invPattern,'rsvd');
        try
            set_param(sigH,'Name',newSigName);
        catch me %#ok<NASGU>
            blkH=get_param(sigH,'SrcBlockHandle');
            if ishandle(blkH)
                path=getfullname(blkH);
                addtoList(path,FailedList);
            end
            continue;
        end
        blkH=get_param(sigH,'SrcBlockHandle');
        if ishandle(blkH)
            path=getfullname(blkH);
            addtoList(path,List);
        end
    end

    ResultDescription=[ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_name_fix')),List];
    if~isempty(FailedList.Items)
        ResultDescription(end+1)=ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_name_fix_fail'));
        ResultDescription(end+1)=FailedList;
    end


    function addtoList(path,List)
        txtObjAndLink=ModelAdvisor.Text(path);
        as_numeric_string=['char([',num2str(path+0),'])'];
        txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
        List.addItem(txtObjAndLink)
    end
end

