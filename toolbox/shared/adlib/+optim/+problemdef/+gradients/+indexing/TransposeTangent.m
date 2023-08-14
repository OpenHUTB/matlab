function rightTan=TransposeTangent(currTangent,outSize)













    if any(outSize==1)


        rightTan=currTangent;
    else

        N=outSize(1);
        M=outSize(2);
        idx=(1:M:N*M)'+(0:M-1);
        idx=idx(:);

        rightTan=currTangent(:,idx);
    end