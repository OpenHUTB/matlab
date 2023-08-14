function spmatrix=getSerialPartMatrix(this,fl)






    spmatrix=cell(fl,3);

    for n=1:fl
        serialpart=getSerialPartForFoldingFactor(this,fl,n);
        spmatrix(n,:)={num2str(n),...
        num2str(length(serialpart)),...
        convSerialPart2String(this,serialpart)};
    end


