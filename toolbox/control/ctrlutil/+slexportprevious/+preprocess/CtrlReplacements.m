function CtrlReplacements(obj)

    if isR2017bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('sharedTrackingLibrary/Particle Filter');
    end

    if isR2016bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('sharedTrackingLibrary/Extended Kalman Filter');
        obj.removeLibraryLinksTo('sharedTrackingLibrary/Unscented Kalman Filter');
    end

    if isR2014aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('ctrlSharedLib/Kalman Filter');
        obj.removeLibraryLinksTo('cstblocks/Linear Parameter Varying/LPV System');
    end

