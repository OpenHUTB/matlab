function boundingbox=fillBoundingBoxLimits(boundingbox,testvalue,xlim,ylim)





    boundaryXData=boundingbox(:,1);
    boundaryYData=boundingbox(:,2);

    hitTopEdge=(boundaryYData==testvalue);
    hitBottomEdge=(boundaryYData==-testvalue);

    hitRightEdge=(boundaryXData==testvalue);
    hitLeftEdge=(boundaryXData==-testvalue);

    boundingbox(hitLeftEdge,1)=xlim(1);
    boundingbox(hitRightEdge,1)=xlim(2);

    boundingbox(hitBottomEdge,2)=ylim(1);
    boundingbox(hitTopEdge,2)=ylim(2);

end