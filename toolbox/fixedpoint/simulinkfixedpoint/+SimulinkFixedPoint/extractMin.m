function minVal=extractMin(val)



    if isempty(val)
        minVal=[];
        return;
    end
    minVal=min(SimulinkFixedPoint.extractRange(val));
end
