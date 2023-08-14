function SL3DReplacements(obj)




    if isR2018bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('vrlib/Utilities/VR Rotation to\nRotation Matrix'));
        obj.removeLibraryLinksTo(sprintf('vrlib/Utilities/MATLAB to\nVR Coordinates'));
        obj.removeLibraryLinksTo(sprintf('vrlib/Utilities/VR to MATLAB\nCoordinates'));
    end

    if isR2018aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('vrlib/VR RigidBodyTree');
    end

    if isR2011aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('vrlib/VR Source');
    end

    if isR2008aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('vrlib/VR Tracer');
    end

    if isR2006aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('vrlib/VR Text Output');
    end

