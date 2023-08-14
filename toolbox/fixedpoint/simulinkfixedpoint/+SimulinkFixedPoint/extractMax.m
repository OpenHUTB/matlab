function maxVal=extractMax(val)



    if isempty(val)
        maxVal=[];
        return;
    end
    maxVal=max(SimulinkFixedPoint.extractRange(val));
end
