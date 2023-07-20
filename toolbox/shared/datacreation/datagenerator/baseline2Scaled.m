function[data,time]=baseline2Scaled(propertiesIn)




    ALL_FIELDS={'dataIn','timeIn','scalefactor'};

    if~all(isfield(propertiesIn,ALL_FIELDS))
        error(message('datacreation:datacreation:datavariantscale'));
    end

    if isenum(propertiesIn.dataIn)
        error(message('datacreation:datacreation:datavariantnoenum',mfilename));
    end

    if~isnumeric(propertiesIn.scalefactor)||~isscalar(propertiesIn.scalefactor)
        error(message('datacreation:datacreation:datavariantscalefactorvalue'));
    end

    data=propertiesIn.dataIn*propertiesIn.scalefactor;
    time=propertiesIn.timeIn;
