function checkIteratorfun(this,callee,node)




    if~this.FrameToSampleConversion

        this.addMessage(...
        node.Left,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:DisabledFrameToSampleConversion',...
        node.tree2str);
        return;
    end

    if this.SamplesPerCycle>1

        this.addMessage(...
        node.Left,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:IteratorfunSamplesPerCycleMoreThanOne');
        return;
    end

    fcnArg=node.Right;
    streamInputArg=fcnArg.Next;



    fcnArgDesc=this.getVarDesc(fcnArg);
    fcnArgType=fcnArgDesc.type;
    assert(fcnArgDesc.isConst&&fcnArgType.isFunctionHandle)


    in2Size=this.getType(streamInputArg).Dimensions;
    if prod(in2Size)==1
        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:IteratorfunFirstInputScalar',...
        node.tree2str);
    end






    useAggregate=true;
    calledFcnTypeInfos=internal.mtree.utils.iteratorfun.Info.getCalledFcnTypeInfo(...
    node,this.functionTypeInfo,this.functionInfoRegistry,useAggregate);
    assert(numel(calledFcnTypeInfos)==1);

    numIns=count(fcnArg.List);
    for i=1:numel(calledFcnTypeInfos)
        numFcnIns=count(calledFcnTypeInfos(i).tree.Ins.List);
        if numIns~=numFcnIns



            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:IteratorfunArgCountDoesNotMatch',...
            calledFcnTypeInfos(1).functionName,...
            node.tree2str,...
            num2str(numFcnIns),...
            num2str(numIns));
        end

        checkKernelFunctions(this,callee,node,calledFcnTypeInfos(i));
    end

end


