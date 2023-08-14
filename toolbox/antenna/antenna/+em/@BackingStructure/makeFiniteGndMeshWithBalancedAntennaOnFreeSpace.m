function[Mesh,Parts]=makeFiniteGndMeshWithBalancedAntennaOnFreeSpace(obj,isRemesh)


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







    if isa(obj,'reflectorCylindrical')
        L=obj.GroundPlaneLength;
        d=obj.Depth;
        R=((L/2)^2+d^2)/(2*d);
        preflector(3,:)=-1*(sqrt(R^2-(preflector(1,:).^2)));
        minz=min(min(preflector(3,:)));
        preflector=em.internal.translateshape(preflector,[0,0,-1*minz]);
    end

    [Mesh,Parts]=assembleAndVerifyFiniteGndMesh(obj,preflector,treflector,pexciter,texciter);



    exciterMesh=obj.Exciter.MesherStruct.Mesh;
    if~isempty(treflector)
        Mesh.Tetrahedra=exciterMesh.T+max(max(treflector));
    else

        Mesh.Tetrahedra=exciterMesh.T;
        Hmin=getMinContourEdgeLength(obj.Exciter);
        setMeshMinContourEdgeLength(obj,Hmin);
    end
    Mesh.EpsilonR=exciterMesh.Eps_r;
    Mesh.LossTangent=exciterMesh.tan_delta;
end