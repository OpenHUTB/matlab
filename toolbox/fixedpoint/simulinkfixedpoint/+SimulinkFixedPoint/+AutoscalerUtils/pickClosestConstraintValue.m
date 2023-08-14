function closestValue=pickClosestConstraintValue(originalValue,constraintValues,greaterThan)




















    if~isempty(constraintValues)
        diffValue=constraintValues-originalValue;
        if greaterThan
            indicesGreaterThan=diffValue>=0;
            if any(indicesGreaterThan)
                closestValue=min(constraintValues(indicesGreaterThan));
            else
                closestValue=constraintValues(end);
            end
        else
            indicesLessThan=diffValue<=0;
            if any(indicesLessThan)
                closestValue=max(constraintValues(indicesLessThan));
            else
                closestValue=constraintValues(1);
            end
        end
    else
        closestValue=originalValue;
    end
end