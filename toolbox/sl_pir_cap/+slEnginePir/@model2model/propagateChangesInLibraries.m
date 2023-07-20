function errMsg=propagateChangesInLibraries(this,aBrokenLinks)%#ok



    errMsg=[];
    for lIdx=1:length(aBrokenLinks)
        try
            set_param(aBrokenLinks{lIdx},'linkstatus','propagatehierarchy');
        catch ME


            error(ME.message);
        end
    end
end
