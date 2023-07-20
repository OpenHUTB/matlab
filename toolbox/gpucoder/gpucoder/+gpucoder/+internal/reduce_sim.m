function varargout=reduce_sim(inputArray,funcArray,redDim,preProcessingFcn)




%#codegen
    coder.allowpcode('plain');
    coder.inline('always');

    ONE=coder.internal.indexInt(1);
    TWO=coder.internal.indexInt(2);
    numFunctions=coder.const(coder.internal.indexInt(length(funcArray)));

    if~isempty(preProcessingFcn)
        preprocessedInputArray=arrayfun(preProcessingFcn,inputArray);
    else
        preprocessedInputArray=inputArray;
    end


    if isempty(preprocessedInputArray)
        varargout{ONE}=zeros(0,'like',preprocessedInputArray);
    else
        if isempty(redDim)

            nelem=coder.internal.indexInt(numel(preprocessedInputArray));
            varargout{ONE}=coder.nullcopy(zeros(1,numFunctions,'like',preprocessedInputArray));

            varargout{ONE}(:)=preprocessedInputArray(1);
            if~isscalar(preprocessedInputArray)
                for f=1:numFunctions
                    for i=2:nelem
                        varargout{ONE}(f)=funcArray{f}(varargout{ONE}(f),preprocessedInputArray(i));
                    end
                end
            end
        else

            ndim=coder.internal.indexInt(coder.internal.ndims(preprocessedInputArray));
            perm=coder.const(@getPermVec,ndim,redDim);
            inMod=permute(preprocessedInputArray,perm);

            inDim=coder.internal.indexInt(size(inMod));
            nelem=inDim(ONE);
            nblock=ONE;
            for k=TWO:coder.internal.ndims(inMod)
                nblock=nblock*inDim(k);
            end


            inr=reshape(inMod,nelem,nblock);
            outDimr=[ONE,nblock];
            outr=cell(ONE,numFunctions);
            out=cell(ONE,numFunctions);

            coder.unroll
            for l=ONE:numFunctions
                outr{l}=coder.nullcopy(zeros(outDimr,'like',preprocessedInputArray));
            end


            for i=ONE:nblock

                for l=ONE:numFunctions
                    outr{l}(ONE,i)=inr(ONE,i);
                end

                for j=TWO:nelem
                    for l=ONE:numFunctions
                        outr{l}(ONE,i)=funcArray{l}(outr{l}(ONE,i),inr(j,i));
                    end
                end
            end


            outDim=getOutDim(inDim);
            coder.unroll
            for l=ONE:numFunctions
                out{l}=reshape(outr{l},outDim);
                varargout{l}=ipermute(out{l},perm);
            end
        end
    end

end

function perm=getPermVec(ndim,redDim)
    coder.inline('always');
    ONE=coder.internal.indexInt(1);
    perm=ONE:ndim;
    perm(redDim)=ONE;
    perm(ONE)=redDim;
end

function outDim=getOutDim(inDim)
    coder.inline('always');
    coder.internal.prefer_const(inDim);

    ONE=coder.internal.indexInt(1);
    outDim=inDim;
    outDim(ONE)=ONE;
end
