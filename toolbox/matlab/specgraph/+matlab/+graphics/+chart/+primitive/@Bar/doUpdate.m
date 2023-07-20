function doUpdate(hObj,updateState)



    import matlab.graphics.chart.primitive.utilities.parseCData
    import matlab.graphics.chart.primitive.bar.internal.validateBarRectangleData
    import matlab.graphics.chart.primitive.bar.internal.setPrimitiveColors


    [cdatashape,cdata]=parseCData(hObj.CData,numel(hObj.XData));
    cdataused=(strcmp(hObj.FaceColor_I,'flat')||strcmp(hObj.EdgeColor,'flat'));


    if cdataused&&(isempty(cdatashape)||...
        ~(cdatashape.isColorMapped||...
        cdatashape.isTrueColor||...
        cdatashape.isConstantColor||...
        cdatashape.isColorMappedScalar))
        error(message('MATLAB:bar:InvalidCData'));
    end


    if numel(hObj.XDataCache)~=numel(hObj.YDataCache)
        hObj.PrepWasAlreadyRun=false;
        error(message('MATLAB:bar:XDataSizeMismatch'));
    end

    [xData,xDataLeft,xDataRight,yDataBottom,yDataTop,order]=calculateBarRectangleData(hObj,updateState.BaseValues);
    isNonFinite=validateBarRectangleData(updateState.DataSpace,hObj.Horizontal,xData,xDataLeft,xDataRight,yDataBottom,yDataTop);


    xDataLeft=xDataLeft(~isNonFinite);
    xData=xData(~isNonFinite);
    xDataRight=xDataRight(~isNonFinite);
    yDataBottom=yDataBottom(~isNonFinite);
    yDataTop=yDataTop(~isNonFinite);
    barOrder=order(~isNonFinite);

    if cdataused&&(cdatashape.isColorMapped||cdatashape.isTrueColor)
        cdata=cdata(~isNonFinite,:);
    end

    [verts,faceIndices]=createBarVertexData(hObj,xData,xDataLeft,xDataRight,yDataBottom,yDataTop);
    numBars=numel(xData);

    iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
    iter.Vertices=verts;
    iter.Indices=faceIndices;

    vd=TransformPoints(updateState.DataSpace,...
    updateState.TransformUnderDataSpace,iter);
    hFace=hObj.Face;
    hFace.StripData=[];
    hFace.VertexData=vd;


    updatedColor=hObj.getColor(updateState);
    if isequal(hObj.FaceColorMode,'auto')&&~isempty(updatedColor)
        hObj.FaceColor_I=updatedColor;
    end

    setPrimitiveColors(updateState,hFace,numBars,hObj.FaceColor_I,cdata,cdatashape,hObj.FaceAlpha);

    hEdge=hObj.Edge;
    hEdge.VertexData=vd;
    hEdge.StripData=uint32(1:4:4*numBars+1);
    hEdge.LineJoin='miter';


    setPrimitiveColors(updateState,hEdge,numBars,hObj.EdgeColor,cdata,cdatashape,hObj.EdgeAlpha);


    hEdge.AlignVertexCenters='on';







    hObj.BarOrder=barOrder;


    if~isempty(hObj.BrushHandles)
        hObj.BrushHandles.MarkDirty('all');
    end




    if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')






        if numBars>150

            selectedBars=false(numBars,1);
            keep=round(linspace(1,numBars,150));
            selectedBars(keep)=true;
        else
            selectedBars=true(numBars,1);
        end


        sxx=[xData(selectedBars);xData(selectedBars)];
        syy=[yDataBottom(selectedBars);yDataTop(selectedBars)];

        if strcmpi(hObj.Horizontal,'off')
            selectionVerts=[sxx(:),syy(:)];
        else
            selectionVerts=[syy(:),sxx(:)];
        end


        if isempty(hObj.SelectionHandle)
            createSelectionHandle(hObj);
        end

        iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
        iter.Vertices=selectionVerts;
        svd=TransformPoints(updateState.DataSpace,...
        updateState.TransformUnderDataSpace,iter);

        hObj.SelectionHandle.VertexData=svd;
        hObj.SelectionHandle.MaxNumPoints=max(1,size(svd,2));
        hObj.SelectionHandle.Visible='on';
    elseif~isempty(hObj.SelectionHandle)
        hObj.SelectionHandle.VertexData=[];
        hObj.SelectionHandle.Visible='off';
    end



    hObj.PrepWasAlreadyRun=false;

end

function createSelectionHandle(hObj)

    hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
    hObj.addNode(hObj.SelectionHandle);


    hObj.SelectionHandle.Description='Bar SelectionHandle';


    hObj.SelectionHandle.Clipping=hObj.Clipping;

end
