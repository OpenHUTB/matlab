function[Mesh,Parts]=makeInfiniteGndMeshWithUnBalancedAntennaOnDielectric(obj,isRemesh,numLayers)




    if isRemesh


        createGeometry(obj);
        meshExciter(obj);
    end


    [pexciter,texciter]=getExciterMesh(obj);


    Wfeed=getFeedWidth(obj.Exciter);
    numSections=ceil(obj.Spacing/getMeshEdgeLength(obj));
    translateVector=[obj.FeedLocation(1,1:2),-(-obj.Spacing)*0.5];



    [axispt1,axispt2,ang]=getAxisPoints(obj);
    [pFeed,tFeed,feed_pt1,feed_pt2]=getStripMesh(obj,obj.Spacing,Wfeed,...
    numSections,ang,axispt1,axispt2,translateVector);


    texciter(4,:)=3;
    tFeed(4,:)=2;


    [p,t]=em.internal.joinmesh(pFeed,tFeed,pexciter,texciter);




    if~all(abs(pexciter(3,:)-obj.Spacing)<=1e-12)
        error(message('antenna:antennaerrors:RadiatorNotConformalOnSubstrate'));
    end


    [pSub,tSub]=meshSubstrateBase(obj);


    T=[];
    EpsilonR=[];
    LossTangent=[];
    meshReflector=em.internal.makeMeshStructure(pSub,tSub,...
    T,EpsilonR,LossTangent);
    Hmax=getMeshEdgeLength(obj);
    Hmin=getMinContourEdgeLength(obj);
    if isempty(Hmin)
        Hmin=0.75*Hmax;
    end
    mR=remesh(obj,meshReflector,Hmin,Hmax);
    pSub=mR.Points;
    tSub=mR.Triangles;


    Mi=em.internal.meshprinting.imprintMesh(pexciter',texciter(1:3,:)',...
    pSub',tSub(1:3,:)');




    Mi.FeedVertex1=feed_pt1';
    Mi.FeedVertex2=feed_pt2';
    Mi.NumLayers=numLayers;




    [Mesh,Parts]=makeDielectricMesh(obj.Substrate,obj,Mi);
    p=Mesh.Points;
    p=em.internal.translateshape(p,[0,0,-obj.Spacing]);


    p=orientGeom(obj,p);


    Mesh.Points=p;
end
