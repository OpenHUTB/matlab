%#codegen

function outSample=prepareVectorOutSampleForActivations(obj,outMiniBatch,sampleIdx,isCellInput)




    coder.allowpcode('plain');



    if coder.isRowMajor
        if coder.const(isCellInput)



            reshapedSample=reshape(outMiniBatch(:,sampleIdx,:),...
            size(outMiniBatch,[1,3]));


            outSample=reshapedSample';
        else


            outSample=outMiniBatch';
        end
    else
        if coder.const(isCellInput)



            outSample=reshape(outMiniBatch(:,sampleIdx,:),...
            size(outMiniBatch,[1,3]));
        else


            outSample=outMiniBatch;
        end
    end
end

