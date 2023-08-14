function layer_contours=makeContourArray(obj,gd,tempMetalLayers,viapolys,contourChoice)

    numLayers=numel(obj.MetalLayers);
    switch contourChoice
    case 'rawContour'
        for i=1:size(gd,2)
            temp_contour=gd(3:end,i);
            numpoints=gd(2,i);
            xp=temp_contour(1:numpoints);
            yp=temp_contour(numpoints+1:2*numpoints);
            layer_contours{i}=[xp,yp];
        end
    case 'contourFromMesh'


        temp_contour=gd(3:end,1);
        numpoints=gd(2,1);
        xp=temp_contour(1:numpoints);
        yp=temp_contour(numpoints+1:2*numpoints);
        layer_contours{1}=[xp,yp];

        [p,t]=cellfun(@getMesh,tempMetalLayers,'UniformOutput',false);
        for i=1:numel(tempMetalLayers)
            [~,~,~,G]=em.internal.extractGeometryFromMesh(p{i},t{i});
            [tempContourFill,tempContourHole]=em.internal.cleanUpFillsAndHoles(G);


            nonEmptyFillCells=cellfun(@(x)~isempty(x),(tempContourFill));
            nonEmptyHoleCells=cellfun(@(x)~isempty(x),(tempContourHole));
            j=sum(double(nonEmptyFillCells));
            k=sum(double(nonEmptyHoleCells));
            layer_contours=[layer_contours,tempContourFill(nonEmptyFillCells)];
            if nonEmptyHoleCells>0
                layer_contours=[layer_contours,tempContourHole(nonEmptyHoleCells)];
            end
        end


        via_contours=viapolys(cellfun(@(x)~isempty(x),viapolys));
        for i=1:numel(via_contours)
            tempContour=via_contours{i}{1}.ShapeVertices;
            layer_contours=[layer_contours,{tempContour(:,1:2)}];
        end
    end

end