function isVectorOut=isDspMinmaxVectorOut(this,slbh,hCInSignal,blockType)






    if strcmp(blockType,'dsp')&&hCInSignal.Type.isArrayType

        [operateOver,specifyDim]=this.getBlockInfoDSP(slbh);

        if hCInSignal.Type.isRowVector&&...
            ((strcmpi(operateOver,'column'))||...
            (strcmpi(operateOver,'dim')&&specifyDim==1))

            isVectorOut=true;

        elseif hCInSignal.Type.isColumnVector&&...
            (strcmpi(operateOver,'row')||...
            (strcmpi(operateOver,'dim')&&specifyDim==2))

            isVectorOut=true;

        else
            isVectorOut=false;
        end
    else
        isVectorOut=false;
    end
