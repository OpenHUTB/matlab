function strideSize=resolveStrideMode(strideMode)



    if(strideMode==0)
        assert(false);
    else
        strideW=strideMode;
    end
    strideSize=[strideW;strideW;1];
end
