function[minVal,maxVal]=extractMinMax(val)

















    minVal=[];
    maxVal=[];

    if isempty(val)
        return;
    end

    range=SimulinkFixedPoint.extractRange(val);
    minVal=min(range);
    maxVal=max(range);
end

