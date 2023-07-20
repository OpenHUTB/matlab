function paramPairs=getConcreteBlockParam(hBlk)





    paramPairs={};

    Simulink.Block.eval(hBlk);
    mws=get_param(hBlk,'MaskWSVariables');
    wsNames={mws.Name}';

    for idx=1:numel(wsNames)
        p=pm.sli.internal.getMaskParameterRecursive(hBlk,wsNames{idx});
        if~isempty(p)&&strcmp(p.Evaluate,'on')
            valStr=mws(idx).Value;
            if isa(valStr,'Simulink.Parameter')
                valStr=valStr.Value;
            end
            if~ischar(valStr)
                valStr=mat2str(valStr);
            end
            paramPairs{end+1}=p.Name;%#ok<AGROW>
            paramPairs{end+1}=valStr;%#ok<AGROW>
        end
    end


end