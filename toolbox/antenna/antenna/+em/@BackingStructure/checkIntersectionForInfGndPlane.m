function checkIntersectionForInfGndPlane(obj)

    if~strcmpi(class(getParent(obj)),'infiniteArray')
        Z=obj.MesherStruct.Geometry.BorderVertices(:,3);
        if any(Z<=0)
            error(message('antenna:antennaerrors:StructureBelowIGP'));
        end
    end