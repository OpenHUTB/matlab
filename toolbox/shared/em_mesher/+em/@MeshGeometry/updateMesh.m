function updateMesh(obj,meshControlOptions)




    if nargin==1



        if checkHasStructureChanged(obj)
            meshGenerator(obj);
        end

    else
        Hmax=meshControlOptions.Hmax;
        Hmin=meshControlOptions.Cmin;
        Hgrad=meshControlOptions.Grate;

        if~isfield(meshControlOptions,'flag')
            meshControlOptions.flag=0;
        end
        flag=meshControlOptions.flag;


        areNotSame=~isequal(obj.MesherStruct.Mesh.MaxEdgeLength,Hmax)||...
        ~isequal(obj.MesherStruct.Mesh.MeshGrowthRate,Hgrad)||...
        (~isempty(Hmin)&&all(Hmin>0)&&~isequal(obj.MesherStruct.Mesh.MinContourEdgeLength,Hmin));

        if strcmpi(getMeshMode(obj),'manual')&&~isHminUserSpecified(obj)


            Hmin=[];
        end

        if areNotSame||checkHasStructureChanged(obj)||flag
            setMeshEdgeLength(obj,Hmax);
            setMeshGrowthRate(obj,Hgrad);
            setMeshMinContourEdgeLength(obj,Hmin);
            meshGenerator(obj);
        end
    end
end
