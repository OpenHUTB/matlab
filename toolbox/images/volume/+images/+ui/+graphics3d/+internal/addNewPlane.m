function planes=addNewPlane(planes,bbox)











    normals=getDefaultPlaneNormals();
    centroid=bbox(1,:)+((bbox(2,:)-bbox(1,:))/2);

    if isempty(planes)

        newNormal=normals(1,:);
        planes=[newNormal,-dot(newNormal,centroid)];
    else
        planeNormals=planes(:,1:3);
        planeNormals=planeNormals./vecnorm(planeNormals,2,2);





        for idx=1:size(normals,1)
            dotProd=dot(planeNormals,repmat(normals(idx,:),[size(planeNormals,1),1]),2);
            if~any(abs(dotProd)>0.7)
                break;
            end
        end

        newNormal=normals(idx,:);
        planes=[planes;[newNormal,-dot(newNormal,centroid)]];
    end

end

function normals=getDefaultPlaneNormals()

    normals=[-1,0,0;
    0,-1,0;
    0,0,-1;
    -0.5774,-0.5774,-0.5774;
    0.5774,-0.5774,-0.5774;
    0.5774,0.5774,-0.5774];

end