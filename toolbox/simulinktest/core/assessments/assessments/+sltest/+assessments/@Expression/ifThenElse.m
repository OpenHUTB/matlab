


function expr=ifThenElse(condition,thenExpr,elseExpr)
    try
        expr=sltest.assessments.IfThenElse(condition,thenExpr,elseExpr);
    catch ME
        ME.throwAsCaller();
    end
end
