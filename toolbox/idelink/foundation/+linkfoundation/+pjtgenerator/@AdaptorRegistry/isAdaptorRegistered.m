function ret=isAdaptorRegistered(reg,AdaptorFileName)





    ret=1;

    AdaptorIdx=getAdaptorIdx(reg,AdaptorFileName);
    if isempty(AdaptorIdx)
        ret=0;
    end
end
