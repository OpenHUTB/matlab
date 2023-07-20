function coreDumpFound=cleanTargetCoreDumps(tg)
    try
        tg.status();
        coreDumpFound=false;
    catch ex
        if(strcmpi(ex.identifier,'slrealtime:target:coreFilesFound'))
            coreDumpFound=true;
        else
            rethrow(ex);
        end
    end
    if(coreDumpFound)
        slrealtime.getCrashStack(tg);
    end
end