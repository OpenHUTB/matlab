function[Mesh,Parts]=assembleAndVerifyInfiniteGndMesh(obj,pexciter,texciter,pimage,timage)


    [p,t]=em.MeshGeometry.assembleMesh({pexciter,pimage},...
    {texciter,timage});


    T=[];
    EpsilonR=[];
    LossTangent=[];
    Mesh=em.internal.makeMeshStructure(p,t,T,EpsilonR,LossTangent);
    Parts=em.internal.makeMeshPartsStructure('Rad',[{pimage},{timage}],...
    'Rad',[{pexciter},{texciter}]);