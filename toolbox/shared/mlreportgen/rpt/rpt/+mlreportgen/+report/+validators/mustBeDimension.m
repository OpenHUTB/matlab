


function mustBeDimension(value,varargin)

    exception='mlreportgen:report:validators:mustBeDimension';

    if ischar(value)
        value=string(value);
    end

    if isempty(varargin)||varargin{1}
        mlreportgen.report.validators.mustBeSingleValue(value);
        if~isempty(value)&&~condition(value)
            throw(createValidatorException(exception));
        end
    end
end

function cdn=condition(value)
    units=mlreportgen.utils.units;
    cdn=units.isValidDimensionString(value);
end
