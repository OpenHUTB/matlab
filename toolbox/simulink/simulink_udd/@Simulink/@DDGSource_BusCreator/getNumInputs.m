function[num]=getNumInputs(source)




    inputs=source.state.Inputs;
    numIn=source.str2doubleNoComma(inputs);
    if isempty(numIn)||isnan(numIn)
        numIn=length(strfind(inputs,','))+1;
    end

    num=num2str(numIn);
end

