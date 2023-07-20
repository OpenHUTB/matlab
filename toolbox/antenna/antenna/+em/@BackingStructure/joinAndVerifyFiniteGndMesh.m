function[Mesh,Parts]=joinAndVerifyFiniteGndMesh(obj,pGP,tGP,pFeed,tFeed,pexciter,texciter)


    [preflector,treflector]=em.internal.joinmesh(pGP,tGP,pFeed,tFeed);

    [p,t]=em.internal.joinmesh(preflector,treflector,pexciter,texciter);


    T=[];
    EpsilonR=[];
    LossTangent=[];
    Mesh=em.internal.makeMeshStructure(p,t,T,EpsilonR,LossTangent);
    Parts=em.internal.makeMeshPartsStructure('Gnd',[{pGP},{tGP}],...
    'Feed',[{pFeed},{tFeed}],...
    'Rad',[{pexciter},{texciter}]);


    p=orientGeom(obj,Mesh.Points);


    Mesh.Points=p;

end