function ResultDescription=setSampleTime(sampleTimeStr,candidateBlks)




    List=ModelAdvisor.List;
    List.setType('bulleted');

    for ii=1:numel(candidateBlks)
        objParam=get_param(candidateBlks{ii},'ObjectParameters');
        if isfield(objParam,'SampleTime')
            set_param(candidateBlks{ii},'SampleTime',sampleTimeStr);
        elseif isfield(objParam,'tsamp')
            set_param(candidateBlks{ii},'tsamp',sampleTimeStr);
        elseif isfield(objParam,'CountSampTime')
            set_param(candidateBlks{ii},'CountSampTime',sampleTimeStr);
        elseif strcmpi(get_param(candidateBlks{ii},'BlockType'),'ground')

            blkName=get_param(candidateBlks{ii},'Name');
            newConstBlk=hdlcoder.ModelChecker.replace_block_MAWrapper(candidateBlks{ii},'built-in/Constant');
            set_param(newConstBlk{1},'Value','0');
            set_param(newConstBlk{1},'OutDataTypeStr','Inherit: Inherit via back propagation');
            set_param(newConstBlk{1},'Name',blkName);
            set_param(newConstBlk{1},'SampleTime',sampleTimeStr);
        else
            continue;
        end
        txtObjAndLink=ModelAdvisor.Text(candidateBlks{ii});
        as_numeric_string=['char([',num2str(candidateBlks{ii}+0),'])'];
        txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
        List.addItem(txtObjAndLink)
    end
    ResultDescription=[ModelAdvisor.Text(DAStudio.message('HDLShared:hdlmodelchecker:block_level_fix')),List];
end