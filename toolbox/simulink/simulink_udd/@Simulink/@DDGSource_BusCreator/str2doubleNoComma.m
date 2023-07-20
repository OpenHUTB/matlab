function[result]=str2doubleNoComma(~,input)


    if(contains(input,',')||~isreal(str2double(input)))
        result=NaN;
        return;
    end

    result=str2double(input);
    return;

end

