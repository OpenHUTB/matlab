function retval=isHminUserSpecified(obj)



    if strcmpi(getMeshMode(obj),'manual')&&isfield(obj.MesherStruct.Mesh,'isHminUserSpecified')
        retval=obj.MesherStruct.Mesh.isHminUserSpecified;
    else
        retval=0;
    end



    if retval==0
        while~isempty(obj.MesherStruct.Parent)
            parent=obj.MesherStruct.Parent;
            obj=parent;
            if strcmpi(getMeshMode(obj),'manual')&&isfield(obj.MesherStruct.Mesh,'isHminUserSpecified')
                retval=obj.MesherStruct.Mesh.isHminUserSpecified;


            end
        end
    end