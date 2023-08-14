function out=getSourceSubsystemName(model)




    out='';
    h=getSourceSubsystemHandle(model);
    if ishandle(h)
        out=getfullname(h);
    end
