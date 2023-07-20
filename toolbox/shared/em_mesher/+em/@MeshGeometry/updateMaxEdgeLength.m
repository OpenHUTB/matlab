function flag=updateMaxEdgeLength(obj)
    if obj.MesherStruct.HasStructureChanged==1
        flag=true;
    else
        flag=false;
    end
end