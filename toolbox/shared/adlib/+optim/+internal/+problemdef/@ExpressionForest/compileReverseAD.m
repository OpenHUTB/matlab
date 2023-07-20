function[nlfunStruct,jacStruct]=compileReverseAD(obj,inputs)





























    visitorFwd=optim.internal.problemdef.visitor.CompileReverseADForwardPass(inputs);

    visitForest(visitorFwd,obj);

    nlfunStruct=getOutputs(visitorFwd);


    visitorRev=optim.internal.problemdef.visitor.CompileReverseADReversePass(visitorFwd,obj.Variables,numel(obj),inputs);

    visitForest(visitorRev,obj);

    jacStruct=getOutputs(visitorRev);