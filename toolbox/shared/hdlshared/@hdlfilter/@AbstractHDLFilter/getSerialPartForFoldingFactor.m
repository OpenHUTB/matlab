function serialpart=getSerialPartForFoldingFactor(this,fl,FoldingFactor)






    serialpart=[FoldingFactor*(ones(1,floor(fl/FoldingFactor))),rem(fl,FoldingFactor)];
    serialpart=serialpart(find(serialpart));%#ok<FNDSB>




