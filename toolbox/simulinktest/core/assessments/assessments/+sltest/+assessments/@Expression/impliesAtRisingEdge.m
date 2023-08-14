function expr=impliesAtRisingEdge(left,right)

    try
        expr=sltest.assessments.ImpliesAtRisingEdge(left,right);
    catch ME
        ME.throwAsCaller();
    end
end

