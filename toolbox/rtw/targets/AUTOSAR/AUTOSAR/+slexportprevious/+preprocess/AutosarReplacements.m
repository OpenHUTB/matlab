function AutosarReplacements(obj)




    if isR2018aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('autosarspkglib_internal/Internal Trigger');
    end
