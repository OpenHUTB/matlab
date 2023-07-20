function expr=sldvRelBoundayObjForRelOp(blockH,cvgPtForRelBound)


    coder.inline('never');
    coder.allowpcode('plain');


    outportDims=blockOutportSize(blockH);
    outputExpr=true(prod(outportDims),1);

    coverageType='relboundary';
    numOfCvgPoints=-1;






    outcome=-1;


    expr=sldv.getObjective(outputExpr,...
    coder.const(outputExpr),...
    coder.const(coverageType),...
    coder.const(numOfCvgPoints),coder.const(cvgPtForRelBound),coder.const(outcome));
end
