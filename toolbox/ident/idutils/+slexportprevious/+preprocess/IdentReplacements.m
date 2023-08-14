function IdentReplacements(obj)




    if isR2017bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('sharedTrackingLibrary/Particle Filter');
    end

    if isR2016bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('sharedTrackingLibrary/Extended Kalman Filter');
        obj.removeLibraryLinksTo('sharedTrackingLibrary/Unscented Kalman Filter');
    end

    if isR2014aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('ctrlSharedLib/Kalman Filter');
    end

    if isR2013bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('ctrlSharedLib/Recursive Least Squares Estimator');
        obj.removeLibraryLinksTo('slident/Estimators/Recursive Least Squares Estimator');
        obj.removeLibraryLinksTo('slident/Estimators/Recursive Polynomial Model Estimator');
        obj.removeLibraryLinksTo('slident/Estimators/Model Type Converter');
    end

