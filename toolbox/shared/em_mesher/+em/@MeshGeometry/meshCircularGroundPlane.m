function[pGP,tGP]=meshCircularGroundPlane(obj,varargin)





    if nargin<=4


        gp_R=obj.GroundPlaneRadius;
        isGround=1;
        if nargin==4
            feed=varargin{3};
        else
            feed_x=obj.FeedOffset(1);
            feed_y=obj.FeedOffset(2);
            feed_z=0;
            feed=[feed_x,feed_y,feed_z];
        end
        translate_x=0;
        translate_y=0;
    end

    if nargin>=7


        feed=varargin{3};
        gp_R=varargin{4};
        isGround=varargin{6};
        if~isempty(feed)&&isprop(obj,'FeedOffset')
            translate_x=obj.FeedOffset(1);
            translate_y=obj.FeedOffset(2);
        else
            translate_x=0;translate_y=0;
        end
    end

    growthRate=max(getMeshGrowthRate(obj),[],"all");
    edgeLength=max(getMeshEdgeLength(obj),[],"all");

    if~isempty(feed)

        circGP=antenna.Circle('Radius',gp_R,'Center',[translate_x,translate_y]);
        [~]=mesh(circGP,'MaxEdgeLength',edgeLength,'GrowthRate',growthRate,...
        'MinEdgeLength',0.01*edgeLength);
        [pGP,tGP]=exportMesh(circGP);
        if numel(feed)==3&&iscolumn(feed)
            feed=feed.';
        end
        offset=0;
        feedtri=[];feedtripoints={};
        for m=1:size(feed,1)
            feedval=em.Antenna.buildConnection(varargin{1},...
            feed(m,:),'Edge-Y');
            feedtripoints=[feedtripoints,feedval{1},feedval{2}];
            feedPatchVer(offset+1:offset+4,:)=unique([feedval{1},feedval{2}]','rows','stable');
            feedtri=[feedtri;[1,2,3;2,3,4]+offset];
            offset=max(feedtri,[],"all");
        end


        Mi=em.internal.meshprinting.imprintMesh(feedPatchVer,...
        feedtri,pGP,tGP(:,1:3));
        pGP=Mi.P';
        tGP=Mi.t';

    else
        domains=varargin{1};
        poly=antenna.Polygon('Vertices',domains{1}');

        if nargin==8
            [~]=mesh(poly,'MaxEdgeLength',edgeLength,'GrowthRate',growthRate,...
            'MinEdgeLength',varargin{7});
        else
            [~]=mesh(poly,'MaxEdgeLength',edgeLength,'GrowthRate',growthRate);
        end
        [pGP,tGP]=exportMesh(poly);
        pGP=pGP';tGP=tGP';
    end

    if isGround

        saveGroundConnection(obj,feedtripoints,[]);
    else

        saveGroundConnection(obj,[],[]);
    end


    pGP(3,:)=0;


    tGP=sortrows(tGP(1:3,:)');
    tGP(:,4)=varargin{2};
    tGP=tGP';
end
