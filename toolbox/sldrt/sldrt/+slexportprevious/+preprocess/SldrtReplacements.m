function SldrtReplacements(obj)




    if isR2021bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('sldrtlib/Video Input');
    end

    if isR2018aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('sldrtlib/Servo Output');
    end

    if isR2017aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('sldrtlib/Internet of Things/ThingSpeak Input');
        obj.removeLibraryLinksTo('sldrtlib/Internet of Things/ThingSpeak Output');
    end

    if isR2016bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('sldrtlib/Target Profiling/Execution Time');
        obj.removeLibraryLinksTo('sldrtlib/Target Profiling/Timestamp');
    end

    if isR2011bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('rtwinlib/Real-Time\nSynchronization'));
    end

    if isR2007aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('rtwinlib/Frequency Output');
        obj.removeLibraryLinksTo('rtwinlib/Packet Input');
        obj.removeLibraryLinksTo('rtwinlib/Packet Output');
        obj.removeLibraryLinksTo('rtwinlib/Stream Input');
        obj.removeLibraryLinksTo('rtwinlib/Stream Output');
    end

