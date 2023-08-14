function isInRange=checkRange(curVal,repMin,repMax,proposedDt)




    isInRange=true;
    if~isempty(curVal)&&~isinf(curVal)&&~isempty(repMax)&&~isempty(repMin)
        if curVal>=repMax
            isInRange=SimulinkFixedPoint.AutoscalerAlertsUtil.checkIfWithinEps(curVal,repMax,proposedDt);
        elseif curVal<=repMin
            isInRange=SimulinkFixedPoint.AutoscalerAlertsUtil.checkIfWithinEps(curVal,repMin,proposedDt);
        end
    end
end
