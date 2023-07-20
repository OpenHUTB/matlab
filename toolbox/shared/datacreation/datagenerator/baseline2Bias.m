function[data,time]=baseline2Bias(propertiesIn)




    ALL_FIELDS={'biasvalue','dataIn','timeIn'};

    if~all(isfield(propertiesIn,ALL_FIELDS))
        error(message('datacreation:datacreation:datavariantinputstructthreshhold'));
    end

    if isenum(propertiesIn.dataIn)
        error(message('datacreation:datacreation:datavariantnoenum',mfilename));
    end

    if~isnumeric(propertiesIn.biasvalue)||~isscalar(propertiesIn.biasvalue)
        error(message('datacreation:datacreation:datavariantbias'));
    end

    data=propertiesIn.dataIn+propertiesIn.biasvalue;
    time=propertiesIn.timeIn;
