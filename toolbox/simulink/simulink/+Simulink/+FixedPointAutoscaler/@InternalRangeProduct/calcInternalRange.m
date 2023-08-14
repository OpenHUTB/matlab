

function calcInternalRange(obj)
    numInputs=size(obj.blockObject.portHandles.Inport,2);
    inputOps=obj.preprocessInputOperations(obj.blockObject.inputs);
    inDims=obj.getInputConnectedDims();
    inComplexity=obj.getInputConnectedComplexity();

    if~shouldCalcInternalRange(obj,numInputs,inDims,inComplexity,inputOps)
        return;
    end

    inRanges=obj.getInputConnectedRanges();



    state=struct('outRange',[],'prevRange',[],'prevDim',[],'prevComplexity',false,'hasDiv',false);

    if numInputs==1
        assert(obj.isElementWise());
        dim=inDims{1};
        n=prod(dim(2:end));
        state.outRange=inRanges{1};
        for nidx=2:n
            state.outRange=obj.unionRange(state.outRange,...
            obj.calcMultiplyRange(state.outRange,inRanges{1},inComplexity{1}));
        end
    else
        for idx=1:numInputs
            complexity=state.prevComplexity||inComplexity{idx};
            state=processInput(obj,state,inRanges{idx},inDims{idx,:},...
            complexity,inputOps(idx));
            state.prevComplexity=complexity;
        end

        if state.hasDiv
            state.outRange=obj.unionRange(state.outRange,[0,0]);
        end
    end

    obj.putRange(state.outRange);
end

function ret=shouldCalcInternalRange(obj,numInputs,inDims,inComplexity,inOps)
    nonScalar=false;
    for dimIdx=1:numel(inDims)
        nonScalar=nonScalar||~obj.isScalar(inDims{dimIdx});
    end
    isMatrixMul=~obj.isElementWise&&nonScalar;
    ret=numInputs>2||...
    (numInputs==1&&obj.isElementWise())||...
    (numInputs==2&&...
    (any([inComplexity{:}])||inOps(1)==obj.OP_DIV||isMatrixMul));
end

function outState=processInput(obj,state,inRange,inDim,isComplex,inOp)
    sameAsInput=false;
    if isempty(state.prevRange)
        [calcRange,sameAsInput]=getFirstInputRange(obj,inRange,inDim,isComplex,inOp);
    else
        [calcRange,inDim]=getInputRange(obj,state.prevRange,state.prevDim,inRange,inDim,isComplex,inOp);
    end

    if~sameAsInput
        state.outRange=obj.unionRange(state.outRange,calcRange);
    end

    if inOp==obj.OP_DIV
        state.hasDiv=true;
    end

    state.prevRange=calcRange;
    state.prevDim=inDim;

    outState=state;
end

function[range,sameAsInput]=getFirstInputRange(obj,inRange,inDim,isComplex,inOp)




    switch inOp
    case obj.OP_DIV
        range=obj.calcInverseRange(inRange,inDim,isComplex);
        sameAsInput=false;
    otherwise
        assert(inOp==obj.OP_MUL)
        range=inRange;
        sameAsInput=true;
    end
end

function[range,dim]=getInputRange(obj,prevRange,prevDim,curRange,curDim,isComplex,inOp)
    switch inOp
    case obj.OP_MUL
        if(obj.isElementWise())
            if obj.isScalar(prevDim)
                dim=curDim;
            else
                dim=prevDim;
            end
            range=obj.calcMultiplyRange(prevRange,curRange,isComplex);
        else
            [range,dim]=obj.calcMxMulRange(obj,prevRange,prevDim,curRange,curDim,isComplex);
        end
    otherwise
        assert(inOp==obj.OP_DIV);
        if(obj.isElementWise())
            if obj.isScalar(prevDim)
                dim=curDim;
            else
                dim=prevDim;
            end
            if~isComplex
                range=obj.calcDivideRange(prevRange,curRange,isComplex);
            else
                range=[-Inf,Inf];
            end
        else
            invRange=obj.calcInverseRange(curRange,curDim,isComplex);
            [range,dim]=obj.calcMxMulRange(obj,prevRange,prevDim,invRange,curDim,isComplex);
        end
    end
end


