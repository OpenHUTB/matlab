function[iQsign,xOffset]=convertToConventionalParkTransform_private(parksType,nPolePairs)%#codegen




    coder.allowpcode('plain');

    if parksType==1
        iQsign=1;
        xOffset=0;
    elseif parksType==2
        iQsign=1;
        xOffset=pi/2/nPolePairs;
    elseif parksType==3
        iQsign=-1;
        xOffset=0;
    else
        iQsign=-1;
        xOffset=-pi/2/nPolePairs;
    end

end