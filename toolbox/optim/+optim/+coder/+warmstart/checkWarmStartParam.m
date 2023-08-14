function val=checkWarmStartParam(val,name)














%#codegen

    coder.allowpcode('plain');

    coder.internal.assert(coder.internal.isConst(val),...
    'optim_codegen:warmstart:OptionValueNotConstant',name,'IfNotConst','Fail');

    if~isempty(val)

        switch name
        case{'MaxLinearEqualities','MaxLinearInequalities'}

            coder.internal.assert(optim.coder.options.internal.checkNonNegInt(val),...
            'optimlib:warmstart:InvalidMaxLinearProperty',name);

            if isinf(val)
                val=-1;
            end
        otherwise
            coder.internal.assert(false,'MATLAB:optimfun:optimset:InvalidParamName',name);
        end
    end

end