function[data,time]=baseline2BoundSignalFlatThreshold(propertiesIn)




    ALL_FIELDS={'lower_threshold','upper_threshold','dataIn','timeIn'};

    if~all(isfield(propertiesIn,ALL_FIELDS))
        error(message('datacreation:datacreation:datavariantinputstructthreshhold'));
    end


    dataIn=propertiesIn.dataIn;
    timeIn=propertiesIn.timeIn;

    if isenum(dataIn)
        error(message('datacreation:datacreation:datavariantnoenum',mfilename));
    end

    if~isscalar(propertiesIn.lower_threshold)||~isnumeric(propertiesIn.lower_threshold)
        error(message('datacreation:datacreation:datavariantthresholdflat'));
    end

    if~isscalar(propertiesIn.upper_threshold)||~isnumeric(propertiesIn.upper_threshold)
        error(message('datacreation:datacreation:datavariantthresholdflat'));
    end

    lowerThresholdVals=ones(size(dataIn))*propertiesIn.lower_threshold;
    upperThresholdVals=ones(size(dataIn))*propertiesIn.upper_threshold;


    data=datacreation.internal.DataGenerator.randBetweenValues(lowerThresholdVals,upperThresholdVals);
    time=timeIn;

