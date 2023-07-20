function UpdateParamUnitsToSlUnits(block,h)




    reason='Replace unit symbol deprecated in Simscape';

    pvPair=simscape.engine.library.internal.UpdateParamUnitsToSlUnitsPVs(block);

    if isempty(pvPair)
        return;
    end

    if~(askToReplace(h,block))
        return;
    end

    funcSet=uSafeSetParam(h,block,pvPair{:});
    appendTransaction(h,block,reason,{funcSet});

end
