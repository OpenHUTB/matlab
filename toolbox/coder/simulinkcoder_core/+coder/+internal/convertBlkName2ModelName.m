function[base_name,fileName]=convertBlkName2ModelName(block_name,maxIdLength)






    i=1;
    while i<=length(block_name)&&isspace(block_name(i))
        i=i+1;
    end
    block_name(1:i-1)=[];
    i=length(block_name);
    while i>0&&isspace(block_name(i))
        i=i-1;
    end
    block_name(i+1:end)=[];
    fileName=block_name;










    firstchar=coder.internal.Utilities.LocalFindFirstValidChar(block_name);
    if(firstchar==0)
        base_name='sfun_target';
    else
        lastchar=coder.internal.Utilities.LocalFindFirstInvalidChar(block_name((firstchar+1):end));
        if lastchar==0
            base_name=block_name(firstchar:end);
        else
            lastchar=lastchar+firstchar-1;
            base_name=block_name(firstchar:lastchar);
        end
    end





    maxModelNameLength=min(maxIdLength,namelengthmax-3);

    if(length(base_name)>maxModelNameLength)
        base_name=base_name(1:maxModelNameLength);
    end

end