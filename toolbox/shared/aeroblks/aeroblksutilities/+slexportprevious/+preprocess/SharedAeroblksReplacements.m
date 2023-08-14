function SharedAeroblksReplacements(obj)




    if isR2013bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('shared6dof/6DOF (Euler Angles)');
        obj.removeLibraryLinksTo('shared3dof/3DOF (Body Axes)');
    end

    if isR2007aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('sharedtransform/Rotation Angles to\nDirection Cosine Matrix'));
        obj.removeLibraryLinksTo(sprintf('sharedtransform/Direction Cosine Matrix\nto Rotation Angles'));
        obj.removeLibraryLinksTo('sharedtransform/Rotation Angles to Quaternions');
        obj.removeLibraryLinksTo('sharedtransform/Quaternions to Rotation Angles');
    end

    if isR2006aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('sharedschedule/Interpolate\nMatrix(x) '));
        obj.removeLibraryLinksTo(sprintf('sharedschedule/Interpolate\nMatrix(x,y) '));
    end

