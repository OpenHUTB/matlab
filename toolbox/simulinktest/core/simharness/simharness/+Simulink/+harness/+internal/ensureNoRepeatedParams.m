function ensureNoRepeatedParams(input)
    n=length(input);
    fields=[];
    for i=1:2:n
        fieldName=input{i};
        if isfield(fields,fieldName)
            DAStudio.error('Simulink:Harness:RepeatingInputParameters',fieldName);
        else
            fields.(fieldName)=input{i+1};
        end
    end
