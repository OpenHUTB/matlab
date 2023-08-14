function attribute=IBIS_AMI_GetAttribute(paramName,attributeName)




    ws=get_param(bdroot,'ModelWorkspace');
    if contains(get_param(bdroot,'Name'),'Tx')
        serDesStruct=evalin(ws,'TxTree.serDesStruct;');
        tree=evalin(ws,'TxTree;');
    elseif contains(get_param(bdroot,'Name'),'Rx')
        serDesStruct=evalin(ws,'RxTree.serDesStruct');
        tree=evalin(ws,'RxTree;');
    else
        error(message('serdes:rtwserdes:ModelMustBeTxRx'));
    end
    amiParamName=paramName;
    if contains(paramName,'Parameter.')
        amiParamName=regexprep(paramName,'Parameter\.','\.');
    elseif contains(paramName,'Signal.')
        amiParamName=regexprep(paramName,'Signal\.','\.');
    end
    amiNames=regexp(amiParamName,'\.','split');
    amiParam=amiNames{end};
    if length(amiNames)>1
        amiParent=strrep(amiParamName,['.',amiParam],'');
    else
        amiParent='';
    end

    attribute='';
    is_top_node=false;
    try
        if serdes.internal.ibisami.ami.parameter.AmiParameter.isReservedParameterName(amiParamName)
            param=eval(['serDesStruct.Reserved_Parameters.',amiParamName]);
        else
            try
                param=eval(['serDesStruct.Model_Specific.',amiParamName]);
            catch









                param=eval(['serDesStruct.Model_Specific.',regexprep(paramName,'Signal$','')]);
                is_top_node=true;
            end
        end
        if strcmp(attributeName,'Usage')
            if is_top_node
                attribute='Out';
            else
                attribute=char(param.Usage.Name);
            end
        elseif strcmp(attributeName,'Hidden')
            attribute=isParamHidden(amiParam,amiParent,param,tree);
        elseif strcmp(attributeName,'Format')
            attribute=char(param.Format.Name);
        elseif strcmp(attributeName,'Type')
            attribute=char(param.Type.Name);
        elseif strcmp(attributeName,'Min')
            if strcmp(param.Format.Name,'Range')
                attribute=str2double(param.Format.Min);
            end
        elseif strcmp(attributeName,'Max')
            if strcmp(param.Format.Name,'Range')
                attribute=str2double(param.Format.Max);
            end
        elseif strcmp(attributeName,'ListValues')
            if strcmp(param.Format.Name,'List')
                attribute=str2double(param.Format.Values);
            end
        elseif strcmp(attributeName,'ListTips')
            if strcmp(param.Format.Name,'List')

                attribute=strrep(['"',strtrim(sprintf('%s ',param.Format.ListTips{:})),'"'],' ','" "');
            end
        elseif strcmp(attributeName,'Description')
            attribute=char(param.Description);
        end
    catch
        if strcmp(attributeName,'Hidden')

            attribute=false;
        else
            attribute='';
        end
    end
end

function hidden=isParamHidden(amiParam,amiParent,param,tree)
    try
        if strcmp(amiParam,'TapWeights')&&~isempty(amiParent)
            node=tree.getTapNode(amiParent);
            hidden=node.Hidden;
        else
            hidden=param.Hidden;
        end
    catch
        hidden=false;
    end
end
