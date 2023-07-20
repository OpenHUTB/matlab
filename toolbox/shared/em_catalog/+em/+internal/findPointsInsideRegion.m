function p=findPointsInsideRegion(region,querypoints,r,pt)


    [in,on]=inpolygon(querypoints(:,1),querypoints(:,2),region(:,1),region(:,2));
    if~any(in)&&~any(on)

        region=em.internal.makeBoundingCircle(1.01*r,pt)';
        [in,on]=inpolygon(querypoints(:,1),querypoints(:,2),region(:,1),region(:,2));
    end
    p=[querypoints(in,:);querypoints(on,:)];
    p=unique(p,'rows','stable');