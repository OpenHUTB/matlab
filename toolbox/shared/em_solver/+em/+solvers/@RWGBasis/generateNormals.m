function generateNormals(obj)


    warnState=warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
    TR=triangulation(obj.Mesh.t(:,1:3),obj.Mesh.P);
    obj.Normals=faceNormal(TR);
    warning(warnState);
end

