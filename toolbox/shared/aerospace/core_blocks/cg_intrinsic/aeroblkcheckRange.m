function value=aeroblkcheckRange(value,min_value,max_value)







%#codegen

    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');

    if(value<min_value)
        value=min_value;
    elseif(value>max_value)
        value=max_value;
    end
end
