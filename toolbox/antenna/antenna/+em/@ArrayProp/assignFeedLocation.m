function feedloc=assignFeedLocation(obj,feedlocation)


    obj.DefaultFeedLocation=feedlocation;

    feedloc=orientGeom(obj,feedlocation')';