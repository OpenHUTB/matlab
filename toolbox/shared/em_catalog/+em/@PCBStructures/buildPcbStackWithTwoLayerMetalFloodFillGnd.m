function[Mesh]=buildPcbStackWithTwoLayerMetalFloodFillGnd(obj,p_tempV,t_tempV,via_pt1,via_pt2,numLayers,varargin)


    pP=p_tempV{1};
    tP=t_tempV{1};
    pGP=p_tempV{2};
    tGP=t_tempV{2};


    Mi=em.internal.meshprinting.imprintMesh(pP',tP(1:3,:)',pGP',tGP(1:3,:)');
    if~isempty(via_pt1)
        Mi.FeedVertex1=[via_pt1{2}(:,1:2),zeros(size(via_pt1{2},1),1)];
        Mi.FeedVertex2=[via_pt2{2}(:,1:2),zeros(size(via_pt2{2},1),1)];
    else
        Mi.FeedVertex1=[];
        Mi.FeedVertex2=[];
    end
    Mi.NumLayers=numLayers;
    if nargin>6
        connIndex=varargin{1};
        mapObj=varargin{2};
        for i=1:size(connIndex,1)
            Mi.LayerMap(i,:)=[mapObj(connIndex(i,1)),mapObj(connIndex(i,2))];
        end
    end
    Mi.NumConnEdges=obj.NumFeedViaModelSides;
    P=Mi.P;
    t=Mi.t;
    pGP=P';
    tGP=t';
    tGP(4,:)=1;



    [T,B]=calculateTopandBottomDielectricCoverThickness(obj);
    Mi.TopSubThickness=T;
    Mi.BottomSubThickness=B;
    Mi.BottomMetalLayerOffset=0;

    [Mesh,Parts]=makeDielectricMesh(obj.Substrate,obj,Mi);
    savePartMesh(obj,Parts);


    Mesh.Points=orientGeom(obj,Mesh.Points);

end