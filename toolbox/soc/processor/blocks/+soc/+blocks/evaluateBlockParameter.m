function value=evaluateBlockParameter(value,mdl)





    value=iGetNonCellValue(value);
    if isvarname(value)
        mdlWks=get_param(mdl,'ModelWorkspace');
        if mdlWks.hasVariable(value)
            value=mdlWks.evalin(value);
        elseif Simulink.data.existsInGlobal(mdl,value)
            value=Simulink.data.evalinGlobal(mdl,value);
        else
            error(message('soc:scheduler:VariableNotDefined',value));
        end
    elseif~isnumeric(value)
        value=eval(value);
    end

    function val=iGetNonCellValue(val)
        if iscell(val)
            val=val{1};
        end
    end
end
