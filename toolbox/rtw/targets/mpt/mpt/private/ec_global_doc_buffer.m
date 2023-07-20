function buffer=ec_global_doc_buffer(modelName)





    ecMPTGlobalBuffer=[];
    rtwprivate('rtwattic','AtticData','ecMPTGlobalBuffer',ecMPTGlobalBuffer);

    toolVersion=ec_mp_tool_version;
    ec_reg_global_buffer('ToolVersion',toolVersion,1);
    ec_reg_global_buffer('Date',date,1);
    ec_reg_global_buffer('Created',get_param(modelName,'Created'),1);
    ec_reg_global_buffer('Creator',get_param(modelName,'Creator'),1);
    ec_reg_global_buffer('ModifiedBy',get_param(modelName,'ModifiedBy'),1);
    ec_reg_global_buffer('ModifiedDate',get_param(modelName,'ModifiedDate'),1);
    ec_reg_global_buffer('ModifiedComment',get_param(modelName,'ModifiedComment'),1);
    ec_reg_global_buffer('ModelVersion',get_param(modelName,'ModelVersion'),1);
    ec_reg_global_buffer('Description',get_param(modelName,'Description'),1);
    ec_reg_global_buffer('LastModifiedBy',get_param(modelName,'LastModifiedBy'),1);
    ec_reg_global_buffer('LastModificationDate',get_param(modelName,'LastModifiedDate'),1);
    ec_reg_global_buffer('ModifiedHistory',get_param(modelName,'ModifiedHistory'),1);



    [abstract,history,notes,otherSym,otherTxt]=ec_mp_global_comments(modelName);
    if isempty(abstract)==0
        ec_reg_global_buffer('Abstract',abstract,1);
    end
    if isempty(history)==0
        ec_reg_global_buffer('History',history,1);
    end
    if isempty(notes)==0
        ec_reg_global_buffer('Notes',notes,1);
    end
    for i=1:length(otherSym)
        ec_reg_global_buffer(otherSym{i},otherTxt{i},1);
    end
    buffer=rtwprivate('rtwattic','AtticData','ecMPTGlobalBuffer');

    function ec_reg_global_buffer(bufferName,bufferContent,customFlag)

        ecMPTGlobalBuffer=rtwprivate('rtwattic','AtticData','ecMPTGlobalBuffer');
        info=[];
        info.bufferName=bufferName;
        info.bufferContent=bufferContent;
        info.customFlag=customFlag;
        ecMPTGlobalBuffer{end+1}=info;
        rtwprivate('rtwattic','AtticData','ecMPTGlobalBuffer',ecMPTGlobalBuffer);
