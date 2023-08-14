function rel=getCurrentReleaseInternal()















    rel=['R',version('-release')];
    if(contains(version('-description'),'Prerelease'))
        rel=[rel,' Prerelease'];
    end
    rel=['(',rel,')'];
