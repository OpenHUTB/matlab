function validateSimscapeNominalValues(expr)









    nomValues=simscape.nominal.internal.deserializeSimscapeNominalValues(expr);



    validateExpr={};

    for i=1:numel(nomValues)
        valueStr=nomValues(i).value;
        try
            val=evalin('base',valueStr);
        catch ME
            switch ME.identifier
            case 'MATLAB:UndefinedFunction'
                continue;
            otherwise
                topME=pm_exception('physmod:simscape:simscape:nominal:nominal:EvaluationError',...
                valueStr);
                throwAsCaller(topME.addCause(ME));
            end
        end

        validateExpr=[validateExpr;{val,nomValues(i).unit}];%#ok
    end

    try
        builtin('_simscape_validate_nominal_values',validateExpr);
    catch ME

        if(~isempty(ME.cause))
            throwAsCaller(ME.cause{1});
        else
            throwAsCaller(ME);
        end
    end

end

