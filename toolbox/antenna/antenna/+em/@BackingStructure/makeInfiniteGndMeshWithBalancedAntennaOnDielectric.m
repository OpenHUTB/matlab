function[Mesh,Parts]=makeInfiniteGndMeshWithBalancedAntennaOnDielectric(...
    obj,isRemesh,numLayers)

    if isRemesh


        createGeometry(obj);
        meshExciter(obj);
        [pexciter,texciter]=getExciterMesh(obj);
    else

        [pexciter,texciter]=getExciterMesh(obj);
    end




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




    Mi.FeedVertex1=[];
    Mi.FeedVertex2=[];
    Mi.NumLayers=numLayers;




    [Mesh,Parts]=makeDielectricMesh(obj.Substrate,obj,Mi);
    p=Mesh.Points;
    p=em.internal.translateshape(p,[0,0,-obj.Spacing]);


    p=orientGeom(obj,p);


    Mesh.Points=p;
end