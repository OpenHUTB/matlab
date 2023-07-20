function[success,info,newCount]=rmidlgApply(linkSource,reqs)





    [fPath,remainder]=strtok(linkSource,'|');
    if any(remainder=='-')
        range=sscanf(remainder,'|%d-%d',2);
        range=range';
    else
        range=remainder(2:end);
    end
    try
        id=rmiml.setReqs(reqs,fPath,range);
        if isempty(id)
            success=false;
            info=['Failed to create Named Range in ',fPath];
            newCount=-1;
        else
            success=true;
            info='';
            newCount=length(reqs);
        end
    catch Mex
        success=false;
        info=Mex.message;
        newCount=-1;
    end
end
