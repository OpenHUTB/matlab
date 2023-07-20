

function prev=globalVariableParserAnalysis(value)


    persistent val;
    if isempty(val)
        val=true;
    end
    prev=val;
    if nargin>0
        val=value;
    end
end

