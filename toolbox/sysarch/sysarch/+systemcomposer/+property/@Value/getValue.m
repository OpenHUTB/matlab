function value=getValue(this)
    try
        value=this.getValueIfExists();
        isempty(value);
    catch ME1 %#ok<NASGU>
        value=[];
    end
    if isempty(value)
        try
            exp=this.type.makeDefaultExpression();
        catch ME2 %#ok<NASGU>
            exp=[];
        end

        if isempty(exp)
            value=exp;
        elseif(isa(this.type,'systemcomposer.property.Enumeration')&&...
            systemcomposer.property.Enumeration.isValidEnumerationName(this.type.MATLABEnumName))
            exp=[this.type.MATLABEnumName,'(',exp,')'];
            value=eval(exp);
        else
            value=eval(exp);
        end
    end
end

