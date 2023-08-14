

function expression=i_extractExpressionFromSimulinkParameterValue(value)

    expression='';
    if~isa(value,'string')
        return;
    end


    index=strfind(value,'=');
    if isempty(index)||(index(1)==strlength(value))
        return;
    end

    index=1+index(1);
    expression=char(extractBetween(value,index,strlength(value)));
end