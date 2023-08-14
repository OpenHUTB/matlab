function fileName=makeValidFileName(name)







    validCodes=[(48:57),(65:90),(97:122)];
    numChar=numel(name);
    i=1;
    while(i<=numChar)
        if isempty(intersect(double(name(i)),validCodes))
            numChar=numChar-1;
            name(i)='';
        else
            i=i+1;
        end
    end
    fileName=name;
    assert(isempty(intersect(double(name(1)),(48:57))),...
    'The name cannot start with a number. Change the name to start with a letter.');
end
