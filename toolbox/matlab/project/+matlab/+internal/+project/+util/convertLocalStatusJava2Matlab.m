function matlabEnumValue=convertLocalStatusJava2Matlab(javaString)





    matlabString=char(javaString);

    if strcmp(matlabString,'NOT_UNDER_CM')
        matlabEnumValue='NotUnderSourceControl';
    else
        matlabEnumValue=capitaliseFirstLetter(lower(matlabString));
    end

end


function output=capitaliseFirstLetter(input)
    output=input;
    if~isempty(input)
        output=[upper(input(1)),input(2:end)];
    end
end