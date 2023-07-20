function meshnewstructure(obj)

    if(obj.MesherStruct.HasStructureChanged==1&&...
        ~isempty(obj.MesherStruct.Mesh.p))
        if strcmp(obj.MesherStruct.MeshingChoice,'auto')
            [s,gr]=calculateMeshParams(obj,obj.MesherStruct.MeshingLambda);
            meshControlOptions.Hmax=s;
            meshControlOptions.Cmin=getMinContourEdgeLength(obj);
            meshControlOptions.Grate=gr;
            if isa(obj,'pcbStack')||isa(obj,'pcbComponent')
                updateMeshForPcbStack(obj,meshControlOptions);
            else
                meshControlOptions.flag=0;
                updateMesh(obj,meshControlOptions);
            end
        else
            updateMesh(obj);
        end
    end



    if isa(obj,'em.Antenna')




        [tf,parentChk,hasHandle]=checkHasMeshChanged(obj);











        if tf&&parentChk&&hasHandle&&~isempty(obj.MesherStruct.Mesh.p)
            meshGenerator(obj,true);
        end
    end
end