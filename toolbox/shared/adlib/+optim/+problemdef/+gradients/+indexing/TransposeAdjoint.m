function leftJac=TransposeAdjoint(currAdjoint,outSize)













    if any(outSize==1)


        leftJac=currAdjoint;
    else

        N=outSize(1);
        M=outSize(2);
        idx=(1:N:N*M)'+(0:N-1);
        idx=idx(:);

        leftJac=currAdjoint(idx,:);
    end