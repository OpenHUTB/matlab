function isInRange=checkIfWithinEps(curVal,compareVal,dataType)





    diff=abs(curVal-compareVal);
    fiObj=fi([],dataType);

    epsDblVal=double(eps(fiObj));


    if diff<(epsDblVal/2)
        isInRange=true;
    else
        isInRange=false;
    end
end
