function TrackingUtilitiesReplacements(obj)
    if isR2020bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('trackingutilitieslib/Track Concatenation');
    end

    if isR2017aOrEarlier(obj.ver)        obj.removeLibraryLinksTo('trackingutilitieslib/Detection Concatenation');
    end
end
