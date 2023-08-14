function retVal=isFunctionOnPath(srcLocation)






    pat="matlab"+wildcardPattern+"toolbox"+wildcardPattern+(".m"|".p");
    retVal=contains(srcLocation,pat);
end
