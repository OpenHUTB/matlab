function plotGeometryFromMesh(f,v,p,boundarypoints)

    antennaColor=[223,185,58]/255;


    figure;
    patch('Faces',f,'Vertices',v,'FaceColor',antennaColor,...
    'EdgeColor','none');
    for m=1:numel(boundarypoints)
        patch('Faces',boundarypoints{m},'Vertices',p,'FaceColor','none',...
        'EdgeColor','k');
    end
    axis off
    axis equal