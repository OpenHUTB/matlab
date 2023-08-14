function[maskEnables,offIdx]=turnOffSelectedEnables(maskNames,maskEnables,whichOff)











    offIdx=logical(zeros(size(maskNames)));
    for anOffParam=whichOff
        offIdx=offIdx|strcmp(anOffParam,maskNames);
    end

    maskEnables(offIdx)={'off'};



