










function[outLoc,outCol,outNorm,outIntensity,outRangeData]=getSubsetPoints(location,color,normal,intensity,rangeData,indices,isOrganized,outType)
%#codegen
    coder.allowpcode('plain');


    coder.varsize('outIntensity',[inf,inf]);

    if strcmp(outType,"full")&&isnumeric(indices)


        numElements=numel(location)/3;
        finalIndices=false(numElements,1);
        for itr=1:numel(indices)
            index=indices(itr);
            finalIndices(index)=true;
        end
    else
        finalIndices=indices;
    end


    if strcmp(outType,"full")

        selectFcn=@(property,indices,defaultValue,dim)(...
        fullWithLogicalIndices(property,indices,defaultValue,dim,isOrganized));
    else

        if islogical(finalIndices)

            selectFcn=@(property,indices,defaultValue,dim)(...
            validWithLogicalIndices(property,indices,dim));
        else

            selectFcn=@(property,indices,defaultValue,dim)(...
            validWithNumericalIndices(property,indices,dim));
        end
    end


    outLoc=selectFcn(location,finalIndices,nan,3);
    outCol=selectFcn(color,finalIndices,zeros("like",color),3);
    outNorm=selectFcn(normal,finalIndices,nan,3);
    if isfloat(intensity)
        intensityDefault=nan;
    else
        intensityDefault=zeros("like",intensity);
    end
    outIntensity=selectFcn(intensity,finalIndices,intensityDefault,1);
    outRangeData=selectFcn(rangeData,finalIndices,nan,3);
end

function outProperty=fullWithLogicalIndices(inProperty,indices,defaultValue,numDims,isOrganized)%#codegen




    coder.inline('always')


    if isempty(inProperty)
        if isOrganized
            outProperty=zeros(0,0,numDims,'like',inProperty);
        else
            outProperty=zeros(0,numDims,'like',inProperty);
        end
        return
    end

    outProperty=coder.nullcopy(inProperty);
    numElements=numel(inProperty)/numDims;



    coder.gpu.kernel
    for col=0:numDims-1
        coder.gpu.kernel
        for idx=1:numel(indices)
            coder.gpu.constantMemory(indices)
            if indices(idx)
                outProperty(idx+col*numElements)=inProperty(idx+col*numElements);
            else
                outProperty(idx+col*numElements)=defaultValue;
            end
        end
    end
end

function outProperty=validWithLogicalIndices(inProperty,indices,numDims)%#codegen



    coder.inline('always')


    if isempty(inProperty)
        outProperty=zeros(0,numDims,'like',inProperty);
        return
    end

    numElements=numel(inProperty)/numDims;

    outIndex=cumsum(indices(:));


    coder.gpu.kernel
    for i=1:2
        outSize=outIndex(end);
    end

    outProperty=coder.nullcopy(zeros(outSize,numDims,'like',inProperty));

    coder.gpu.kernel
    for col=0:numDims-1
        coder.gpu.kernel
        for itr=1:numel(indices)
            coder.gpu.constantMemory(indices)
            if indices(itr)
                inpIdx=itr;
                outIdx=outIndex(itr);
                outProperty(outIdx+col*outSize)=inProperty(inpIdx+col*numElements);
            end
        end
    end
end

function outProperty=validWithNumericalIndices(inProperty,indices,numDims)%#codegen



    coder.inline('always')


    if isempty(inProperty)
        outProperty=zeros(0,numDims,'like',inProperty);
        return
    end

    numElements=numel(inProperty)/numDims;

    outSize=numel(indices);

    outProperty=coder.nullcopy(zeros(outSize,numDims,'like',inProperty));

    coder.gpu.kernel
    for col=0:numDims-1
        coder.gpu.kernel
        for itr=1:numel(indices)
            coder.gpu.constantMemory(indices)
            inpIdx=indices(itr);
            outIdx=itr;
            if inpIdx<numElements
                outProperty(outIdx+col*outSize)=inProperty(inpIdx+col*numElements);
            end
        end
    end
end