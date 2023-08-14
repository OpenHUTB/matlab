function updateSelectionHandle(hObj)









    if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
        if strcmp(hObj.Is3D,'on')&&hasBothContourLinesAndFill(hObj)
            [vertexData,numPrimitives]=selectionHandleVerticesFromPrimitives(combinedPrimitives(hObj));
        elseif~isempty(hObj.FacePrims)
            [vertexData,numPrimitives]=selectionHandleVerticesFromPrimitives(hObj.FacePrims);
        elseif~isempty(hObj.EdgePrims)||~isempty(hObj.EdgeLoopPrims)
            [vertexData,numPrimitives]=selectionHandleVerticesFromPrimitives([hObj.EdgePrims;hObj.EdgeLoopPrims]);
        else
            vertexData=zeros(3,0,'single');
            numPrimitives=0;
        end
        hObj.SelectionHandle.VertexData=vertexData;
        hObj.SelectionHandle.Visible='on';
        hObj.SelectionHandle.MaxNumPoints=max(200,6*numPrimitives);
    else
        hObj.SelectionHandle.Visible='off';
    end
end

function tf=hasBothContourLinesAndFill(hObj)
    tf=(~isempty(hObj.EdgePrims)||~isempty(hObj.EdgeLoopPrims))&&~isempty(hObj.FacePrims);
end

function handles=combinedPrimitives(hObj)
    handles=[hObj.FacePrims;hObj.EdgePrims;hObj.EdgeLoopPrims];
end

function[vertexData,numPrimitives]=selectionHandleVerticesFromPrimitives(primitives)
    numPrimitives=numel(primitives);
    xExtrema=zeros(1,0);
    yExtrema=zeros(1,0);
    zExtrema=zeros(1,0);
    for k=1:numPrimitives
        vertexData=primitives(k).VertexData;
        x=vertexData(1,:);
        y=vertexData(2,:);
        z=vertexData(3,:);
        [xExtrema,yExtrema,zExtrema]...
        =add_extrema(xExtrema,yExtrema,zExtrema,x,y,z);
    end
    vertexData=[xExtrema;yExtrema;zExtrema];
end

function[xExtrema,yExtrema,zExtrema]...
    =add_extrema(xExtrema,yExtrema,zExtrema,xp,yp,zp)

    [~,xmini]=min(xp);
    [~,xmaxi]=max(xp);
    [~,ymini]=min(yp);
    [~,ymaxi]=max(yp);
    [zmin,zmini]=min(zp);
    [zmax,zmaxi]=max(zp);
    verticesAreCoplanar=(zmin==zmax);
    if verticesAreCoplanar
        indices=unique([xmini,ymini,xmaxi,ymaxi]);
        xExtrema=[xExtrema,xp(indices)];
        yExtrema=[yExtrema,yp(indices)];
        zExtrema=[zExtrema,zmin+zeros(size(indices),'like',zmin)];
    else
        indices=unique([xmini,ymini,zmini,xmaxi,ymaxi,zmaxi]);
        xExtrema=[xExtrema,xp(indices)];
        yExtrema=[yExtrema,yp(indices)];
        zExtrema=[zExtrema,zp(indices)];
    end
end
