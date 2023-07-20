function nlfunStruct=compileNonlinearFunction(obj,inputs)






































    visitor=optim.internal.problemdef.visitor.CompileNonlinearFunction(inputs);

    visitForest(visitor,obj);

    nlfunStruct=getOutputs(visitor);

end
