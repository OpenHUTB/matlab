function[hatchStartingVertexData,bins]=calculateHatchStartingVertexData(hObj,vertexData,numHatches)




    if hObj.HatchSpacingMode_I=="auto"
        linearizedSpacing=linspace(0,1,numHatches);
    else
        linearizedSpacing=0:1/(numHatches-1):1;
    end



    linearizedSpacing(end)=linearizedSpacing(end)-eps('single');


    chordLength=sqrt(sum(diff(vertexData,1,2).^2));



    chordLength=chordLength./sum(chordLength);
    cumulativeArcLength=[0,cumsum(chordLength)];




    bins=matlab.internal.math.discretize(linearizedSpacing,cumulativeArcLength,false);


    scale=(linearizedSpacing-cumulativeArcLength(bins))./chordLength(bins);
    hatchStartingVertexData=vertexData(:,bins)+(vertexData(:,bins+1)-vertexData(:,bins)).*scale;

end