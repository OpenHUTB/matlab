function RFBlksReplacements(obj)




    verobj=obj.ver;

    if isR2021bOrEarlier(verobj)
        obj.removeLibraryLinksTo('rfmathmodels2/Power Amplifier');
    end

    if isR2020bOrEarlier(verobj)
        obj.removeLibraryLinksTo('rfmathmodels2/Mixer');
    end

    if isR2019bOrEarlier(verobj)
        obj.removeLibraryLinksTo('rfmathmodels2/Amplifier');
        obj.appendRule(['<SourceBlock|"rfmathmodels2/Lowpass RF Filter":',...
        'repval "rfmathmodels1/Lowpass RF Filter">']);
        obj.appendRule(['<SourceBlock|"rfmathmodels2/Highpass RF Filter":',...
        'repval "rfmathmodels1/Highpass RF Filter">']);
        obj.appendRule(['<SourceBlock|"rfmathmodels2/Bandpass RF Filter":',...
        'repval "rfmathmodels1/Bandpass RF Filter">']);
        obj.appendRule(['<SourceBlock|"rfmathmodels2/Bandstop RF Filter":',...
        'repval "rfmathmodels1/Bandstop RF Filter">']);
    end

    if isR2007aOrEarlier(verobj)
        obj.removeLibraryLinksTo('rfseriesshuntrlcs1/Series R');
        obj.removeLibraryLinksTo('rfseriesshuntrlcs1/Series L');
        obj.removeLibraryLinksTo('rfseriesshuntrlcs1/Series C');
        obj.removeLibraryLinksTo('rfseriesshuntrlcs1/Shunt R');
        obj.removeLibraryLinksTo('rfseriesshuntrlcs1/Shunt L');
        obj.removeLibraryLinksTo('rfseriesshuntrlcs1/Shunt C');
    end
end