function[isRestored,restoredModels]=restoreConfigSet(mdl)


















    switch nargout
    case{0,1}
        isRestored=slprivate('restoreBDConfigSetImpl',mdl);
    case 2
        [isRestored,restoredModels]=slprivate('restoreBDConfigSetImpl',mdl);
    end

end

