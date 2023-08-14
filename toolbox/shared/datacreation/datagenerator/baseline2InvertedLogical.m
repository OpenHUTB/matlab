function[data,time]=baseline2InvertedLogical(propertiesIn)




    ALL_FIELDS={'dataIn','timeIn'};

    if~all(isfield(propertiesIn,ALL_FIELDS))
        error(message('datacreation:datacreation:datavariantbasic'));
    end

    dataIn=propertiesIn.dataIn;
    timeIn=propertiesIn.timeIn;

    if~isa(dataIn,'double')&&~isa(dataIn,'logical')
        error(message('datacreation:datacreation:datavariantinvert'));
    end

    time=timeIn;
    data=~dataIn;
