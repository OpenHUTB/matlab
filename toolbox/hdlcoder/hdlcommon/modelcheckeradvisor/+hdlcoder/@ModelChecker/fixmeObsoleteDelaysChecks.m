function ResultDescription=fixmeObsoleteDelaysChecks(mdlTaskObj)







    ruleName='runObsoleteDelaysChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};

    udeBlks=hdlcoder.ModelChecker.find_system_MAWrapper(checker.m_DUT,...
    'MaskType','Unit Delay Enabled');
    udrBlks=hdlcoder.ModelChecker.find_system_MAWrapper(checker.m_DUT,...
    'MaskType','Unit Delay Resettable');
    uderBlks=hdlcoder.ModelChecker.find_system_MAWrapper(checker.m_DUT,...
    'MaskType','Unit Delay Enabled Resettable');

    ResultDescription=replaceObsoleteDelays([udeBlks,udrBlks,uderBlks]);
end

function ResultDescription=replaceObsoleteDelays(obsoleteBlks)




    List=ModelAdvisor.List;
    List.setType('bulleted');



    hdlsllibLoaded=bdIsLoaded('hdlsllib');
    if~hdlsllibLoaded
        hdlsllibHandle=load_system('hdlsllib');
    end

    for ii=1:numel(obsoleteBlks)

        maskType=get_param(obsoleteBlks{ii},'MaskType');
        blkName=get_param(obsoleteBlks{ii},'Name');
        initCond=get_param(obsoleteBlks{ii},'vinit');
        sampleTime=get_param(obsoleteBlks{ii},'tsamp');

        if strcmp(maskType,'Unit Delay Enabled')
            newBlk=hdlcoder.ModelChecker.replace_block_MAWrapper(obsoleteBlks{ii},'hdlsllib/Discrete/Unit Delay Enabled Synchronous');
        elseif strcmp(maskType,'Unit Delay Resettable')
            newBlk=hdlcoder.ModelChecker.replace_block_MAWrapper(obsoleteBlks{ii},'hdlsllib/Discrete/Unit Delay Resettable Synchronous');
        elseif strcmp(maskType,'Unit Delay Enabled Resettable')
            newBlk=hdlcoder.ModelChecker.replace_block_MAWrapper(obsoleteBlks{ii},'hdlsllib/Discrete/Unit Delay Enabled Resettable Synchronous');
        else
            continue
        end

        set_param(newBlk{1},'Name',blkName);
        set_param(newBlk{1},'InitialCondition',initCond);
        set_param(newBlk{1},'SampleTime',sampleTime);

        txtObjAndLink=ModelAdvisor.Text(obsoleteBlks{ii});
        as_numeric_string=['char([',num2str(obsoleteBlks{ii}+0),'])'];
        txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
        List.addItem(txtObjAndLink)
    end


    if~hdlsllibLoaded
        close_system(hdlsllibHandle);
    end

    ResultDescription=[ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:block_level_replace')),List];

end