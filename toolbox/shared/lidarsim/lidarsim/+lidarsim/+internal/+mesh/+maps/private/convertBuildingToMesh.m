function mesh=convertBuildingToMesh(building)

    tri=building.triangulation;


    mesh=convertTriToMesh(tri);

end

function mesh=convertTriToMesh(tri)

    mesh=extendedObjectMesh(zeros(0,3),zeros(0,3));

    if isa(tri,'triangulation')
        mesh=extendedObjectMesh(tri.Points,tri.ConnectivityList);
        return;
    elseif iscell(tri)
        for i=1:numel(tri)
            thisTri=tri{i};
            if iscell(thisTri)
                thisMesh=convertTriToMesh(thisTri);
            else
                thisMesh=extendedObjectMesh(thisTri.Points,thisTri.ConnectivityList);
            end
            mesh=join(mesh,thisMesh);
        end
    end
end
