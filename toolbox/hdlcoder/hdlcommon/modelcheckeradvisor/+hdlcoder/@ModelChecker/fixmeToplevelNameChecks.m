function ResultDescription=fixmeToplevelNameChecks(mdlTaskObj)







    ruleName='runToplevelNameChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};
    List=ModelAdvisor.List;
    List.setType('bulleted');
    FailedList=ModelAdvisor.List;
    FailedList.setType('bulleted');


    [candidateDUT,candidatePorts]=hdlcoder.ModelChecker.getInvalidPortAndDutNames(checker.m_DUT);


    if~isempty(candidateDUT)
        dutH=candidateDUT;
        dutName=get_param(dutH,'Name');
        newName=fixToplevelName(dutName);

        try
            set_param(dutH,'Name',newName);
            path=getfullname(dutH);
            addtoList(path,List);
            checker.m_DUT=path;
        catch me %#ok<NASGU>
            path=getfullname(dutH);
            addtoList(path,FailedList);
        end
    end


    for ii=1:numel(candidatePorts)
        portH=candidatePorts(ii);
        portName=get_param(portH,'Name');
        newName=fixToplevelName(portName);

        try
            set_param(portH,'Name',newName);
        catch me %#ok<NASGU>
            path=getfullname(portH);
            addtoList(path,FailedList);
            continue;
        end

        path=getfullname(portH);
        addtoList(path,List);
    end

    ResultDescription=[ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_toplevel_name_fix')),List];
    if~isempty(FailedList.Items)
        ResultDescription(end+1)=ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_toplevel_name_fix_fail'));
        ResultDescription(end+1)=FailedList;
    end



    function newName=fixToplevelName(name)
        lowerName=lower(name);
        upperName=upper(name);
        if~strcmp(lowerName,name)&&~strcmp(upperName,name)
            name=lowerName;
        end

        len=strlength(name);
        if(len>16)
            name=name(1:16);
        end
        newName=name;
    end


    function addtoList(path,List)
        txtObjAndLink=ModelAdvisor.Text(path);
        as_numeric_string=['char([',num2str(path+0),'])'];
        txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
        List.addItem(txtObjAndLink)
    end
end


