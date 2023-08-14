function expr=impliesAtFallingEdge(left,right,fallingEdgeCondition,duration)

    try
        expr=sltest.assessments.ImpliesAtFallingEdge(left,right,fallingEdgeCondition,duration);
    catch ME
        ME.throwAsCaller();
    end
end

