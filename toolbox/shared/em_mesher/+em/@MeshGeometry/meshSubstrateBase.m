function[pSub,tSub]=meshSubstrateBase(obj)




    subShape=obj.Substrate.Shape;
    switch subShape
    case 'box'
        gp_L=obj.Substrate.Length;
        gp_W=obj.Substrate.Width;

        gp=antenna.Rectangle('Length',gp_L,'Width',gp_W);
    case 'cylinder'
        gp_R=obj.Substrate.Radius;

        gp=antenna.Circle('Radius',gp_R,'NumPoints',30);
    end
    isGround=1;
    if isprop(obj,'FeedOffset')
        feed_x=obj.FeedOffset(1);
        feed_y=obj.FeedOffset(2);
        feed_z=0;
        feed=[feed_x,feed_y,feed_z];
    else
        feed=[];
    end

    growthRate=max(getMeshGrowthRate(obj),[],"all");
    W_maxlim=max(getMeshEdgeLength(obj),[],"all");
    if~isempty(feed)
        if numel(feed)==3&&iscolumn(feed)
            feed=feed.';
        end
        offset=0;
        feedtri=[];feedtripoints={};
        for m=1:size(feed,1)
            feedval=em.Antenna.buildConnection(obj.FeedWidth,...
            feed(m,:),'Edge-Y');
            feedtripoints=[feedtripoints,feedval{1},feedval{2}];
            feedPatchVer(offset+1:offset+4,:)=unique([feedval{1}...
            ,feedval{2}]','rows','stable');
            feedtri=[feedtri;[1,2,3;2,3,4]+offset];
            offset=max(feedtri,[],"all");
        end


        [~]=mesh(gp,'MaxEdgeLength',W_maxlim,'GrowthRate',growthRate);
        [pGP,tGP]=exportMesh(gp);


        Mi=em.internal.meshprinting.imprintMesh(feedPatchVer,...
        feedtri,pGP,tGP(:,1:3));
        pSub=Mi.P';
        tSub=Mi.t';
    else
        [~]=mesh(gp,'MaxEdgeLength',W_maxlim,'GrowthRate',growthRate);
        [pSub,tSub]=exportMesh(gp);
        pSub=pSub';tSub=tSub';
        feedtripoints=[];
    end

    if isGround

        saveGroundConnection(obj,feedtripoints,[])
    end

    pSub(3,:)=0;


    tSub=sortrows(tSub(1:3,:)');
    tSub(:,4)=1;
    tSub=tSub';
end
