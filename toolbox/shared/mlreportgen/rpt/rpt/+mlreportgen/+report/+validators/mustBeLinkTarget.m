function mustBeLinkTarget(value,varargin)

    exception='mlreportgen:report:validators:mustBeLinkTarget';


    if ischar(value)
        value=string(value);
    end



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
    is=isEmpty(value)||isString(value)||...
    isa(value,'mlreportgen.dom.LinkTarget');
end
