function out=isConfigSetResolved(model)











    cs=getActiveConfigSet(model);
    if isa(cs,'Simulink.ConfigSetRef')
        knownResolved=(cs.SourceResolved=="on")&&(cs.UpToDate=="on");
        if~knownResolved
            cs.refresh(true);
        end
        out=(cs.SourceResolved=="on");
    else
        out=true;
    end
