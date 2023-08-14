function[Mesh,Parts]=makeFiniteGndMeshWithBalancedAntennaOnDielectric(obj,isRemesh,numLayers)

    if isRemesh


        createGeometry(obj);
        meshExciter(obj);
        [pexciter,texciter]=getExciterMesh(obj);
        [preflector,treflector]=getReflectorMesh(obj,false);

    else

        [pexciter,texciter]=getExciterMesh(obj);
        [preflector,treflector]=getPartMesh(obj,'Gnd');
        preflector=cell2mat(preflector);
        treflector=cell2mat(treflector);

    end




    if~all(abs(pexciter(3,:)-obj.Spacing)<=1e-12)
        error(message('antenna:antennaerrors:RadiatorNotConformalOnSubstrate'));
    end

    if~isempty(preflector)&&~isempty(treflector)

        Mi=em.internal.meshprinting.imprintMesh(pexciter',texciter(1:3,:)',...
        preflector',treflector(1:3,:)');
    else

        [pSub,tSub]=meshSubstrateBase(obj);


        meshReflector=em.internal.makeMeshStructure(pSub,tSub,[],[],[]);
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
    end




    Mi.FeedVertex1=[];
    Mi.FeedVertex2=[];
    Mi.NumLayers=numLayers;

    if~isempty(preflector)&&~isempty(treflector)
        Parts=em.internal.makeMeshPartsStructure('Gnd',[{Mi.P'},{Mi.t'}],...
        'Rad',[{pexciter},{texciter}]);
    else
        Parts=em.internal.makeMeshPartsStructure('Gnd',[{preflector},{treflector}],...
        'Rad',[{pexciter},{texciter}]);
    end


    [Mesh,~]=makeDielectricMesh(obj.Substrate,obj,Mi);


    p=orientGeom(obj,Mesh.Points);


    Mesh.Points=p;

end
