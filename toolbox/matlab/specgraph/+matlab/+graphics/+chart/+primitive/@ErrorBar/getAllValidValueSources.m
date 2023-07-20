function valueSources=getAllValidValueSources(hObj)




    valueSources=["XData";"YData"];

    if~isempty(hObj.XNegativeDelta_I)||~isempty(hObj.XPositiveDelta_I)
        valueSources=[valueSources;"X Delta"];
    end

    if~isempty(hObj.YNegativeDelta_I)||~isempty(hObj.YPositiveDelta_I)
        valueSources=[valueSources;"Y Delta"];
    end
end