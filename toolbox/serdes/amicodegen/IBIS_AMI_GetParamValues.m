

function value=IBIS_AMI_GetParamValues(param)
    ws=get_param(bdroot,'ModelWorkspace');
    names=strsplit(param,'.');
    try
        if evalin(ws,['isa(',names{1},', ''Simulink.Parameter'')'])
            new_names{1}=names{1};
            new_names{2}='Value';
            for i=2:length(names)
                new_names{i+1}=names{i};
            end
            param=strjoin(new_names,'.');
        end
        value=evalin(ws,param);
    catch
        value=0;
    end
    if~isempty(enumeration(value))
        value=int32(value);
    end
    value=reshape(value,1,numel(value));
