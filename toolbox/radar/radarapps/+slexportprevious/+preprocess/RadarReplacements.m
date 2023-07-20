function RadarReplacements(obj)




    if isR2019aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('radarlib/DBSCAN Clustering'));
        obj.removeLibraryLinksTo(sprintf('radarlib/Backscatter Bicyclist'));
    end

    if isR2018bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('radarlib/Backscatter Pedestrian');
    end

    if isR2018aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('radarlib/Pulse Compression Library');
    end

    if isR2017bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('radarlib/Pulse Waveform Library');
    end

    if isR2016aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('radarlib/Wideband Two-Ray Channel');
    end

    if isR2015aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('radarlib/Two-Ray Channel');
    end


