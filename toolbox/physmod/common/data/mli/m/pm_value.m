function v=pm_value(val,unitExpression)
















    narginchk(1,3);

    if nargin<2
        unitExpression='1';
    end

    try
        if~pm_isunit(unitExpression)
            pm_error('physmod:common:data:mli:value:InvalidUnit',unitExpression);
        end
        valUnit=simscape.Unit(1);
        if isa(val,'DataManager.Value')
            valUnit=val.unit;
            val=value(val,valUnit);
            valUnit=simscape.Unit(valUnit);
        end
        if isa(val,'simscape.Value')
            valUnit=unit(val);
            val=value(val);
        end
        if valUnit~=simscape.Unit(1)
            pm_error('physmod:common:data:mli:value:ValueNotUnitless',char(valUnit));
        end

        if~isnumeric(val)
            pm_error('physmod:common:data:mli:value:ValueNotNumeric')
        end

        v=DataManager.Value(val,unitExpression);
    catch e
        e.throwAsCaller;
    end

end
