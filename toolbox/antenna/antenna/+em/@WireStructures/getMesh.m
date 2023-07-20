function[wires,vol,mPts]=getMesh(obj,varargin)

    if nargin==2
        vp=em.MeshGeometry.speedOfLight(1,1);

        fmeshing=varargin{1};
        lambdameshing=vp/fmeshing;
        obj.MesherStruct.MeshingFrequency=fmeshing;

        setMeshingLambda(obj,lambdameshing);
        [s,gr]=obj.Source.calculateWireMeshParams(lambdameshing);



        updateMesh(obj,s,gr);
    else
        updateMesh(obj);
    end

    if~isfield(obj.MesherStruct.Mesh,'wiresSeg')
        error(message('antenna:antennaerrors:NoMeshParams'));
    end

    wires=obj.MesherStruct.Mesh.wiresSeg;
    vol=obj.MesherStruct.Mesh.volDataSeg;
    mPts=obj.MesherStruct.Mesh.matchPts;

end