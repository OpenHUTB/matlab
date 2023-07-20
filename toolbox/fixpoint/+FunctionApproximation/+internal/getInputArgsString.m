function[inputArgsString,inputArgs1String]=getInputArgsString(numInputs)





    inputArgsString=convertStringsToChars(strings(numInputs,1));
    inputArgsString{1}='inputValues1';

    if numInputs>1
        for i=2:numInputs
            inputArgsString{i}=',';
            inputArgsString{i}=[inputArgsString{i},'inputValues',num2str(i)];
        end
    end
    inputArgsString=[inputArgsString{:}];
    inputArgs1String='inputValues1';
end