function feedloc=translateAndCalculateFeedLoc(obj,arraysize,rowspacing,colspacing,lattice,skew)


    translateVector=calculateTranslateVector(obj);


    unitelementloc=obj.Element.FeedLocation;
    startpoint=em.internal.translateshape(unitelementloc',...
    translateVector);
    startpoint=startpoint';
    [element,exciter]=em.internal.dipoleCrossedLocation(obj.Element);
    if element||exciter
        spacing=obj.Element.FeedLocation(1,1);
    else
        spacing=[];
    end
    feedloc=em.ArrayProp.calculatefeedloc(arraysize,...
    rowspacing,colspacing,startpoint,lattice,skew,spacing);