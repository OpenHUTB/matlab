function updateLeafChildInitCondRange(h,elementIdx,newRange)




    oldRange=h.leafChildInitialConditionRange{elementIdx};

    h.leafChildInitialConditionRange{elementIdx}=...
    [min([oldRange,newRange]),max([oldRange,newRange])];



