function newobj=createSubset(newobj,oldobj,sub)











    oldSz=size(oldobj);
    oldIdxNames=oldobj.IndexNames;


    [outSize,linIdx,outIdxNames]=optim.internal.problemdef.indexing.getSubsrefOutputs(sub,oldSz,oldIdxNames);







    newobj.VariableImpl=oldobj.VariableImpl;

    createSubsref(newobj.OptimExprImpl,oldobj.OptimExprImpl,linIdx,outSize);


    newobj.IsSubsref=true;




    newobj.IndexNamesStore=optim.internal.problemdef.makeValidIndexNames(outIdxNames,outSize);


