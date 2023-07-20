function[Mesh,Parts]=assembleAndVerifyFiniteGndMesh(obj,preflector,treflector,pexciter,texciter)

    if(~isequal(obj.GroundPlaneLength,0))&&...
        ~isequal(obj.GroundPlaneWidth,0)
        [p,t]=em.MeshGeometry.assembleMesh({preflector,pexciter},...
        {treflector,texciter});

    else
        p=pexciter;
        t=texciter;
    end


    T=[];
    EpsilonR=[];
    LossTangent=[];
    Mesh=em.internal.makeMeshStructure(p,t,T,EpsilonR,LossTangent);
    Parts=em.internal.makeMeshPartsStructure('Gnd',[{preflector},{treflector}],...
    'Rad',[{pexciter},{texciter}]);


    p=orientGeom(obj,Mesh.Points);


    Mesh.Points=p;


