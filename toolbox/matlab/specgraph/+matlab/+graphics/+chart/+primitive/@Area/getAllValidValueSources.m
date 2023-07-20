function valueSources=getAllValidValueSources(hObj)




    dimensionNames=hObj.DimensionNames;
    if hObj.NumPeers>1
        valueSources=[strcat(dimensionNames{1},"Data");"Y (Stacked)";"Y (Segment)"];
    else
        valueSources=[strcat(dimensionNames{1},"Data");strcat(dimensionNames{2},"Data")];
    end