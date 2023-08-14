function[rApprox,continuedFractions,rError]=ratApproxInBounds(rOrig,rLowerBound,rUpperBound)











































    s.rU=rOrig;
    s.lower=rLowerBound;
    s.upper=rUpperBound;

    s.resid=s.rU;

    [integerPart,s.resid]=intFracRecip(s.resid);

    continuedFractions={
integerPart
    };

    rApprox=fixed.internal.fiRepeatFracToRatPlus(continuedFractions);

    while(~s.resid.iszero())&&~toleranceMet(s,rApprox)

        [integerPart,s.resid]=intFracRecip(s.resid);

        continuedFractions{end+1}=integerPart;%#ok<AGROW>

        rApprox=fixed.internal.fiRepeatFracToRatPlus(continuedFractions);
    end





    rError=computeError(s,rApprox);

end

function[integerPart,residNew]=intFracRecip(resid)


    [integerPart,remainder]=fixed.internal.ratRoundToInt(resid);


    if remainder.iszero()
        residNew=remainder;
    else
        residNew=remainder.inv();
    end



end


function b=toleranceMet(s,rApprox)

    b=(s.lower<rApprox)&&(rApprox<s.upper);
end

function rError=computeError(s,rApprox)

    rError=rApprox-s.rU;
end


