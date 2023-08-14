function[Aout,bout]=extractLinearCoefficientsForTimes(ALeft,ARight,bLeft,bRight)












    zeroALeft=nnz(ALeft)<1;
    zeroARight=nnz(ARight)<1;

    if zeroALeft

        bin=bRight;
        coeff=bLeft;
        if zeroARight

            Ain=zeros(0,1);
        else

            Ain=ARight;
        end
    else

        Ain=ALeft;
        bin=bLeft;
        coeff=bRight;
    end




    Aout=Ain.*coeff';
    bout=bin.*coeff;

end

