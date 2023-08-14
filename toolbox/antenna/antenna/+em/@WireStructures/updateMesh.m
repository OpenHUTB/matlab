function updateMesh(obj,varargin)

































    if nargin==1



        if checkHasStructureChanged(obj)
            meshGenerator(obj);
        end

    else





        if nargin==2
            meshControlOptions=varargin{1};
            Hmax=meshControlOptions.Hmax;
            Hgrad=meshControlOptions.Grate;
        elseif nargin==3
            Hmax=varargin{1};
            Hgrad=varargin{2};
        end
        if~isequal(obj.MesherStruct.Mesh.MaxEdgeLength,Hmax)||...
            ~isequal(obj.MesherStruct.Mesh.MeshGrowthRate,Hgrad)||...
            checkHasStructureChanged(obj)
            setMeshEdgeLength(obj,Hmax);
            setMeshGrowthRate(obj,Hgrad);
            meshGenerator(obj);
        end
    end
end

