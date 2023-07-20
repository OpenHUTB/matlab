function[data,time]=baseline2ToleranceBoundSignal(propertiesIn)





    ALL_FIELDS={'lower_threshold','upper_threshold','dataIn','timeIn'};

    if~all(isfield(propertiesIn,ALL_FIELDS))
        error(message('datacreation:datacreation:datavariantinputstructthreshhold'));
    end

    dataIn=propertiesIn.dataIn;
    timeIn=propertiesIn.timeIn;

    if isenum(dataIn)
        error(message('datacreation:datacreation:datavariantnoenum',mfilename));
    end

    if propertiesIn.lower_threshold<0||propertiesIn.lower_threshold>1||~isscalar(propertiesIn.lower_threshold)
        error(message('datacreation:datacreation:datavariantthresholdpercent'));
    end

    if propertiesIn.upper_threshold<0||propertiesIn.upper_threshold>1||~isscalar(propertiesIn.upper_threshold)
        error(message('datacreation:datacreation:datavariantthresholdpercent'));
    end



    lower_threshold=propertiesIn.lower_threshold;
    upper_threshold=propertiesIn.upper_threshold;


    lowerThresholdVals=dataIn-dataIn*lower_threshold;
    upperThresholdVals=dataIn+dataIn*upper_threshold;

    data=datacreation.internal.DataGenerator.randBetweenValues(lowerThresholdVals,upperThresholdVals);
    time=timeIn;
