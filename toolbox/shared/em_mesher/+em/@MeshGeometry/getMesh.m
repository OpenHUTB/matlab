function[p,t,T]=getMesh(obj,varargin)



    if nargin==2
        vp=em.MeshGeometry.speedOfLight(1,1);

        fmeshing=varargin{1};
        lambdameshing=vp/fmeshing;
        obj.MesherStruct.MeshingFrequency=fmeshing;
        if isa(obj,'em.PrintedAntenna')&&~isequal(obj.MesherStruct.MeshingLambda,lambdameshing)
            meshControlOptions.flag=1;
        else
            meshControlOptions.flag=0;
        end
        setMeshingLambda(obj,lambdameshing);



        [s,gr]=calculateMeshParams(obj,lambdameshing);




        meshControlOptions.Hmax=s;
        meshControlOptions.Grate=gr;
        meshControlOptions.Cmin=getMinContourEdgeLength(obj);
        if isa(obj,'pcbStack')||isa(obj,'pcbComponent')
            updateMeshForPcbStack(obj,meshControlOptions);
        else
            updateMesh(obj,meshControlOptions);
        end
    else
        updateMesh(obj);
    end

    if~isfield(obj.MesherStruct.Mesh,'p')
        error(message('antenna:antennaerrors:NoMeshParams'));
    end

    p=obj.MesherStruct.Mesh.p;
    t=obj.MesherStruct.Mesh.t;
    T=obj.MesherStruct.Mesh.T;

end