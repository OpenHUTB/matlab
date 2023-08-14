function mustBeLogical(value,varargin)

    exception='mlreportgen:report:validators:mustBeLogical';


    mustBeSingleValue=isempty(varargin)||varargin{1};
    if mustBeSingleValue
        mlreportgen.report.validators.mustBeSingleValue(value);
        if~condition(value)
            throw(createValidatorException(exception));
        end
    else

        checkContent(exception,@condition,value);
    end
end

function is=condition(value)
    if isnumeric(value)
        is=isempty(value)||value==1||value==0;
    else
        is=islogical(value);
    end
end
