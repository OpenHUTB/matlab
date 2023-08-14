function newLoc=getNewLocation(~,currentAnchor,currentSize,finalSize)

    centerPoints=currentAnchor+currentSize/2;
    newLoc=centerPoints-finalSize/2;