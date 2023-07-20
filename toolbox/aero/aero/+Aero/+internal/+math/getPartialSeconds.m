function[secondsOut,partialSeconds]=getPartialSeconds(secondsIn)





    partialSeconds=mod(secondsIn,1);
    secondsOut=floor(secondsIn);

end