function mustBeCoefficientValue(value)

    if~iscell(value)
        value=num2cell(value);
    end

    valueGood=cellfun(@validationHelper,value);

    if~all(valueGood,'all')
        error(message("aero:FixedWing:NotANumberOrLT"))
    end

end

function valueGood=validationHelper(value)
    valueGood=true;


    if~isscalar(value)
        valueGood=false;
        return
    end


    if isnumeric(value)
        if~(isfinite(value)&&isreal(value))

            valueGood=false;
        end
    elseif class(value)~="Simulink.LookupTable"

        valueGood=false;
    end

end
