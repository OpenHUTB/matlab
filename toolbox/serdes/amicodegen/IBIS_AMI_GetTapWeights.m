function attribute=IBIS_AMI_GetTapWeights(paramName,attributeName,index)




    ws=get_param(bdroot,'ModelWorkspace');
    if contains(get_param(bdroot,'Name'),'Tx')
        serDesStruct=evalin(ws,'TxTree.serDesStruct;');
    elseif contains(get_param(bdroot,'Name'),'Rx')
        serDesStruct=evalin(ws,'RxTree.serDesStruct');
    else
        error(message('serdes:rtwserdes:ModelMustBeTxRx'));
    end
    amiParamName=paramName;
    if contains(paramName,'Parameter.')
        amiParamName=regexprep(paramName,'Parameter\.','\.');
    elseif contains(paramName,'Signal.')
        amiParamName=regexprep(paramName,'Signal\.','\.');
    end

    attribute='';
    try
        param=eval(['serDesStruct.Model_Specific.',amiParamName]);
        if strcmp(attributeName,'Name')
            names=fieldnames(param);
            attribute=names{index};
        elseif strcmp(attributeName,'Min')
            tapcells=struct2cell(param);
            if strcmp(tapcells{index}.Format.Name,'Range')
                attribute=str2double(tapcells{index}.Format.Min);
            end
        elseif strcmp(attributeName,'Max')
            tapcells=struct2cell(param);
            if strcmp(tapcells{index}.Format.Name,'Range')
                attribute=str2double(tapcells{index}.Format.Max);
            end
        elseif strcmp(attributeName,'Description')
            tapcells=struct2cell(param);
            attribute=char(tapcells{index}.Description);
        end
    catch
        attribute='';
    end
