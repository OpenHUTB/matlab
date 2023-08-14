

function attribute=IBIS_AMI_GetReservedInfo(paramName)
    ws=get_param(bdroot,'ModelWorkspace');
    if strcmp(paramName,'Root_Name')
        if contains(get_param(bdroot,'Name'),'Tx')
            attribute=char(evalin(ws,'TxTree.Name;'));
        elseif contains(get_param(bdroot,'Name'),'Rx')
            attribute=char(evalin(ws,'RxTree.Name'));
        else
            error(message('serdes:rtwserdes:ModelMustBeTxRx'));
        end
    else
        if contains(get_param(bdroot,'Name'),'Tx')
            serDesStruct=evalin(ws,'TxTree.serDesStruct;');
        elseif contains(get_param(bdroot,'Name'),'Rx')
            serDesStruct=evalin(ws,'RxTree.serDesStruct');
        else
            error(message('serdes:rtwserdes:ModelMustBeTxRx'));
        end
        attribute='';
        try
            param=eval(['serDesStruct.Reserved_Parameters.',paramName]);
            if strcmp(paramName,'AMI_Version')
                attribute=str2double(param.CurrentValue);
            elseif strcmp(paramName,'Init_Returns_Impulse')
                attribute=param.CurrentValue;
            elseif strcmp(paramName,'GetWave_Exists')
                attribute=param.CurrentValue;
            end
        catch
            attribute='';
        end
    end
