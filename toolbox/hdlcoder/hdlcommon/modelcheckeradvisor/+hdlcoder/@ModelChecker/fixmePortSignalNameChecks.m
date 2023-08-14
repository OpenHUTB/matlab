function ResultDescription=fixmePortSignalNameChecks(mdlTaskObj)






    checker=hdlcoder.ModelChecker.getModelChecker(mdlTaskObj,'runPortSignalNameChecks');

    List=ModelAdvisor.List;
    List.setType('bulleted');

    [candidatePorts,candidateSignals]=hdlcoder.ModelChecker.getInvalidPortSignalNames(checker.m_DUT);


    for ii=1:numel(candidatePorts)
        portH=candidatePorts(ii);
        portName=get_param(portH,'Name');

        newName=fixPortSignalName(portName,'_port');
        set_param(portH,'Name',newName);
        path=getfullname(portH);
        addtoList(path);
    end


    for ii=1:numel(candidateSignals)
        sigH=candidateSignals(ii);
        sigName=get_param(sigH,'Name');

        newSigName=fixPortSignalName(sigName,'_sig');
        set_param(sigH,'Name',newSigName);
        blkH=get_param(sigH,'SrcBlockHandle');
        if ishandle(blkH)
            path=getfullname(blkH);
            addtoList(path);
        end
    end

    ResultDescription=[ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:industry_std_portsignal_name_fix')),List];




    function newName=fixPortSignalName(name,suffix)
        len=strlength(name);
        if(len<2)
            newName=lower(strcat(name,suffix));
        elseif(len>40)
            newName=name(1:40);
        else
            newName=name;
        end
    end

    function addtoList(path)
        txtObjAndLink=ModelAdvisor.Text(path);
        as_numeric_string=['char([',num2str(path+0),'])'];
        txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
        List.addItem(txtObjAndLink)
    end
end
