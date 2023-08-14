function[ovMode,rndModes,nonFiniteMode]=getMathModesAndNonFinite(simdTgtFcn)

    assert(~isempty(simdTgtFcn.Operation));

    ovMode=loc_convertToCrlOverflowMode(simdTgtFcn.Operation.OverflowMode);
    rndModes=loc_convertToCrlRoundingModes(simdTgtFcn.Operation.RoundingModes);

    nonFiniteMode='UNSPECIFIED';
    if~simdTgtFcn.Operation.SupportNonFinite
        nonFiniteMode='FORBIDDEN';
    end
end

function ovMode=loc_convertToCrlOverflowMode(aTgtOvMode)

    tgtOvModes={'OVERFLOW_UNSPECIFIED',...
    'OVERFLOW_SATURATE',...
    'OVERFLOW_WRAP'};
    crlOvModes={'RTW_SATURATE_UNSPECIFIED',...
    'RTW_SATURATE_ON_OVERFLOW',...
    'RTW_WRAP_ON_OVERFLOW'};

    persistent overflowModeMap;
    if isempty(overflowModeMap)
        overflowModeMap=containers.Map(tgtOvModes,crlOvModes);
    end

    ovMode='RTW_SATURATE_UNSPECIFIED';
    if~isempty(aTgtOvMode)
        aModeString=char(aTgtOvMode);
        assert(isKey(overflowModeMap,aModeString));
        ovMode=overflowModeMap(aModeString);
    end
end

function rndModes=loc_convertToCrlRoundingModes(aTgtRndModeArray)

    tgtRndModes={'ROUND_UNSPECIFIED',...
    'ROUND_FLOOR',...
    'ROUND_CEILING',...
    'ROUND_ZERO',...
    'ROUND_NEAREST',...
    'ROUND_NEAREST_ML',...
    'ROUND_SIMPLEST',...
    'ROUND_CONV'};
    crlRndModes={'RTW_ROUND_UNSPECIFIED',...
    'RTW_ROUND_FLOOR',...
    'RTW_ROUND_CEILING',...
    'RTW_ROUND_ZERO',...
    'RTW_ROUND_NEAREST',...
    'RTW_ROUND_NEAREST_ML',...
    'RTW_ROUND_SIMPLEST',...
    'RTW_ROUND_CONV'};

    persistent roundingModeMap;
    if isempty(roundingModeMap)
        roundingModeMap=containers.Map(tgtRndModes,crlRndModes);
    end

    rndModes={'ROUND_UNSPECIFIED'};
    if~isempty(aTgtRndModeArray)
        num=length(aTgtRndModeArray);
        rndModes=repmat({''},num,1);
        for i=1:num
            aModeString=char(aTgtRndModeArray(i));
            assert(isKey(roundingModeMap,aModeString))
            rndModes{i}=roundingModeMap(aModeString);
        end
    end
end