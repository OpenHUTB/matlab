function checkNpufun(this,callee,node)




    if~this.FrameToSampleConversion

        this.addMessage(...
        node.Left,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:DisabledFrameToSampleConversion',...
        node.tree2str);
        return;
    end






    useAggregate=true;
    objInfo=internal.mtree.utils.npufun.Info(node,this.functionTypeInfo,this.functionInfoRegistry,useAggregate);



    fcnArg=node.Right;
    fcnArgDesc=this.getVarDesc(fcnArg);
    fcnArgType=fcnArgDesc.type;
    assert(fcnArgDesc.isConst&&fcnArgType.isFunctionHandle)



    kernelSize=objInfo.KernelSize;
    assert(numel(kernelSize)==2);


    imgSize=objInfo.ImageSize;
    assert(numel(imgSize)==2);

    if imgSize(1)<kernelSize(1)
        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:NpufunKernelTooManyRows',...
        node.tree2str,...
        num2str(kernelSize(1)),...
        num2str(imgSize(1)));
    end

    if imgSize(2)<=this.SamplesPerCycle
        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:streamingmatrix:PortError_MatrixColsLessThanSampleNum',...
        node.tree2str,...
        num2str(kernelSize(2)),...
        num2str(this.SamplesPerCycle));
    elseif rem(imgSize(2),this.SamplesPerCycle)~=0
        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:streamingmatrix:PortError_DivisibleBySampleNum',...
        node.tree2str,...
        num2str(imgSize(2)),...
        num2str(this.SamplesPerCycle));
    end




    maxKernelCols=getMaxKernelCols(imgSize(2),this.SamplesPerCycle);

    if kernelSize(2)>maxKernelCols
        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:NpufunKernelTooManyCols',...
        node.tree2str,...
        num2str(kernelSize(2)),...
        num2str(this.SamplesPerCycle),...
        num2str(imgSize(2)),...
        num2str(maxKernelCols));
    end

    calledFcnTypeInfos=objInfo.CalleeFcnInfo;
    assert(~isempty(calledFcnTypeInfos));




    firstArg=node.Right.Next.Next;
    numIns=count(firstArg.List);

    currArg=firstArg;
    while~isempty(currArg)
        if strcmp(currArg.kind,'CHARVECTOR')
            if strcmp(currArg.tree2str,'''NonSampleInput''')

                numIns=numIns-1;
            end
            if strcmp(currArg.tree2str,'''BoundaryConstant''')

                numIns=numIns-2;
            end
        end
        currArg=currArg.Next;
    end

    for i=1:numel(calledFcnTypeInfos)
        numFcnIns=count(calledFcnTypeInfos(i).tree.Ins.List);
        if numIns~=numFcnIns
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:NpufunArgCountDoesNotMatch',...
            calledFcnTypeInfos(i).functionName,...
            node.tree2str,...
            num2str(numFcnIns),...
            num2str(numIns));
        end

        checkKernelFunctions(this,callee,node,calledFcnTypeInfos(i));
    end
end


function maxKernelCols=getMaxKernelCols(imgCols,numSamples)
    if mod(imgCols,numSamples)==0


        spareCols=double(imgCols-numSamples);
        spareSamples=spareCols/numSamples;



        spareLhsSamples=floor(spareSamples/2);
        spareRhsSamples=spareSamples-spareLhsSamples;

        evenAdjustment=0;

        if spareRhsSamples>spareLhsSamples


            evenAdjustment=1;
            spareRhsSamples=spareRhsSamples-1;
        end

        assert(spareRhsSamples==spareLhsSamples);

        maxKernelCols=1...
        +spareLhsSamples*2*numSamples...
        +evenAdjustment;
    else




        maxKernelCols=Inf;
    end
end



