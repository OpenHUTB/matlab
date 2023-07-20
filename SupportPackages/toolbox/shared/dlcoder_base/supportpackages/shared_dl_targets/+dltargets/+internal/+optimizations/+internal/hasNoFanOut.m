function nofanOut=hasNoFanOut(diG,layerName)
    nofanOut=true;
    if(numel(successors(diG,layerName))>1)
        nofanOut=false;
    end

end