function value=getParam(block,param)




    value=[];
    if strcmp(getfullname(block),bdroot(block))

        return
    end

    try
        if strcmpi(get_param(block,'Mask'),'on')
            maskObj=Simulink.Mask.get(block);
            if ismember(lower(param),lower({maskObj.Parameters.Name}))
                value=get_param(block,param);
            end
        end
    catch ME
        error('slplc:invalidParamToGet','Invalid parameter name %s for PLC block %s',param,block);
    end

end
