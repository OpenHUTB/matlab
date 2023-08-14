function mustBeEquation(value,holeId,varargin)

    exception='mlreportgen:report:validators:mustBeEquation';


    if ischar(value)
        value=string(value);
    end


    mustBeSingleValue=isempty(varargin)||varargin{1};
    if mustBeSingleValue
        mlreportgen.report.validators.mustBeSingleValue(value);
        if~condition(value,holeId)
            throw(createValidatorException(exception,holeId));
        end
    else

        checkContent(exception,@condition,value,holeId);
    end
end

function is=condition(value,holeId)
    is=isEmpty(value)||isString(value)||...
    isa(value,'mlreportgen.dom.Image');
    if~is&&isa(value,'mlreportgen.report.HoleReporter')
        if isempty(value.HoleId)
            is=isempty(holeId);
        else
            is=(value.HoleId==holeId);
        end
    end
end
