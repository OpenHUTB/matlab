function[data,time]=baseline2TimeShift(propertiesIn)




    ALL_FIELDS={'dataIn','timeIn','timeshift'};

    if~all(isfield(propertiesIn,ALL_FIELDS))
        error(message('datacreation:datacreation:datavarianttimeshift'));
    end

    data=propertiesIn.dataIn;

    if~isnumeric(propertiesIn.timeshift)||~isscalar(propertiesIn.timeshift)
    end
    time=propertiesIn.timeIn+propertiesIn.timeshift;
