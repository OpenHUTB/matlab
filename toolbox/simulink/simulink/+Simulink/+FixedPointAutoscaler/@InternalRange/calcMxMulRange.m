

function[range,dim]=calcMxMulRange(obj,range1,dim1,range2,dim2,isComplex)





    if obj.isScalar(dim1)
        range=obj.calcMultiplyRange(range1,range2,isComplex);
        dim=dim2;
    elseif obj.isScalar(dim2)
        range=obj.calcMultiplyRange(range1,range2,isComplex);
        dim=dim1;
    else
        assert((dim1(1)<=2)&&(dim2(1)<=2),'Expected a matrix with less than three dimensions in Simulink.FixedPointAutoscaler.InternalRange.calcMxMulRange');
        [range,dim]=calcMxMulMxFast(obj,range1,dim1,range2,dim2,isComplex);
    end
end



function[range,dim]=calcMxMulMxFast(obj,range1,dim1,range2,dim2,isComplex)
    dim1=fixVectorDim(obj,dim1,true);
    dim2=fixVectorDim(obj,dim2,false);

    elementRange=obj.calcMultiplyRange(range1,range2,isComplex);
    range=elementRange;

    numRepeats=dim1(3);
    for idx=1:(numRepeats-1)
        range=obj.mergeRange(range,obj.calcAddRange(range,elementRange));
    end
    dim=[2,dim1(2),dim2(3)];
end





function outDim=fixVectorDim(obj,inDim,isFirst)
    if obj.isVector(inDim)
        len=obj.vectorLength(inDim);
        if isFirst
            outDim=[2,1,len];
        else
            outDim=[2,len,1];
        end
    else
        outDim=inDim;
    end
end