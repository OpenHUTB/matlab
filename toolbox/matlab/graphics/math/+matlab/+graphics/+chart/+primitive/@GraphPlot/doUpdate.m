function doUpdate(hObj,us)



    if hObj.wasReset_
        updateEdgeLineHandles(hObj);
        updateEdgeLabelHandles(hObj)
        updateMarkerHandles(hObj);
        updateNodeLabelHandles(hObj);
        hObj.wasReset_=false;
    end




    set(hObj.EdgeLineHandles_,'Visible','on','ColorBinding','object',...
    'AlignVertexCenters','off');



    [isVisibleEdgeLabel,isVisibleEdgeLine]=determineEdgeVisibility(hObj,us);




    coordToEdge=setEdgeLineCoords(hObj,us,isVisibleEdgeLine);


    hasArrows=hObj.IsDirected_&&strcmp(hObj.ShowArrows,'on')&&numedges(hObj.BasicGraph_)>0;




    if hasArrows
        triToEdge=setArrowCoords(hObj,us,isVisibleEdgeLine);
    else
        triToEdge=[];
        hObj.EdgeArrowHandles_.VertexData=[];
    end


    setEdgeColors(hObj,us,coordToEdge,triToEdge,hasArrows);



    setEdgeLabels(hObj,us,isVisibleEdgeLabel);








    set(hObj.MarkerHandles_,'Visible','on');


    [isVisibleNodeLabel,isVisibleNodeMarker]=determineNodeVisibility(hObj,us);


    markerToNode=setNodeCoords(hObj,us,isVisibleNodeMarker);


    setNodeColors(hObj,us,markerToNode);


    setNodeLabels(hObj,us,isVisibleNodeLabel);





    if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&...
        strcmp(hObj.SelectionHighlight,'on')
        if isempty(hObj.SelectionHandle)
            hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
        end
        hObj.SelectionHandle.VertexData=[hObj.MarkerHandles_.VertexData];
        hObj.SelectionHandle.Visible='on';
    else
        if~isempty(hObj.SelectionHandle)
            hObj.SelectionHandle.VertexData=[];
            hObj.SelectionHandle.Visible='off';
        end
    end


    function[isValidEdge,isVisibleEdge]=determineEdgeVisibility(hObj,us)



        nrEdges=numedges(hObj.BasicGraph_);

        if isa(us.DataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
            xIsInvalid=...
            matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
            us.DataSpace.XScale,us.DataSpace.XLim,hObj.EdgeCoords_(:,1).');
            yIsInvalid=...
            matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
            us.DataSpace.YScale,us.DataSpace.YLim,hObj.EdgeCoords_(:,2).');
            zIsInvalid=...
            matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
            us.DataSpace.ZScale,us.DataSpace.ZLim,hObj.EdgeCoords_(:,3).');
            edgeCoordIsInvalid=xIsInvalid|yIsInvalid|zIsInvalid;
            edgeCoordToEdge=hObj.EdgeCoordsIndex_;
            isValidEdge=accumarray(edgeCoordToEdge(:),edgeCoordIsInvalid(:),[nrEdges,1]).'==0;
        else
            isValidEdge=false(1,nrEdges);
        end



        isVisibleEdge=~strcmp(hObj.LineStyle_I,'none')&isValidEdge;

        if strcmp(hObj.EdgeColor_I,'flat')
            isVisibleEdge(isnan(hObj.EdgeCData_I))=false;
        end


        function coordToEdge=setEdgeLineCoords(hObj,us,isVisibleEdge)

            nrPrimitives=length(hObj.EdgeLineHandles_);

            coordToEdge=cell(1,nrPrimitives);
            piter=matlab.graphics.axis.dataspace.XYZPointsIterator;

            for i=1:nrPrimitives
                isEdgeInPrimitive=hObj.EdgeLineHandlesArrayIndex_==i;
                isPointInPrimitive=isEdgeInPrimitive(hObj.EdgeCoordsIndex_);
                localEdgeCoords=hObj.EdgeCoords_(isPointInPrimitive,:).';
                localEdgeStrip=hObj.EdgeCoordsIndex_(isPointInPrimitive);


                visiblePoints=isVisibleEdge(localEdgeStrip);
                localEdgeStrip(~visiblePoints)=[];
                localEdgeCoords(:,~visiblePoints)=[];


                coordToEdge{i}=localEdgeStrip;


                stripdata=[0,find(diff(localEdgeStrip)).',length(localEdgeStrip)]+1;


                piter.XData=localEdgeCoords(1,:);
                piter.YData=localEdgeCoords(2,:);
                piter.ZData=localEdgeCoords(3,:);

                vd=TransformPoints(us.DataSpace,...
                us.TransformUnderDataSpace,...
                piter);

                set(hObj.EdgeLineHandles_(i),'VertexData',vd,...
                'StripData',uint32(stripdata));

            end

            function setEdgeColors(hObj,us,coordToEdge,triToEdge,hasArrows)

                set(hObj.EdgeLineHandles_,'Visible','on');
                set(hObj.EdgeArrowHandles_,'Visible','on');


                if isnumeric(hObj.EdgeColor_I)
                    if isrow(hObj.EdgeColor_I)

                        edgecolor=uint8(255.*[hObj.EdgeColor_I,double(hObj.EdgeAlpha)].');
                        set(hObj.EdgeLineHandles_,'ColorData',edgecolor,...
                        'ColorType','truecoloralpha');
                        if hasArrows
                            set(hObj.EdgeArrowHandles_,'ColorBinding','object',...
                            'ColorData',edgecolor,'ColorType','truecoloralpha');
                        end
                    else
                        edgecolor=uint8(255.*[hObj.EdgeColor_I,...
                        double(hObj.EdgeAlpha)*ones(size(hObj.EdgeColor_I,1),1)].');
                        for i=1:length(hObj.EdgeLineHandles_)
                            linesegmentcolor=edgecolor(:,coordToEdge{i});
                            set(hObj.EdgeLineHandles_(i),'ColorBinding','interpolated',...
                            'ColorData',linesegmentcolor,'ColorType','truecoloralpha');
                        end
                        if hasArrows
                            set(hObj.EdgeArrowHandles_,'ColorBinding','discrete',...
                            'ColorData',edgecolor(:,triToEdge),'ColorType','truecoloralpha');
                        end
                    end
                elseif strcmp(hObj.EdgeColor_I,'flat')

                    ci=matlab.graphics.axis.colorspace.IndexColorsIterator;
                    ci.Colors=hObj.EdgeCData_I(:);
                    ci.CDataMapping='scaled';
                    cd=TransformColormappedToTrueColor(us.ColorSpace,ci);
                    if~isempty(cd)
                        cd.Data(4,:)=uint8(255)*hObj.EdgeAlpha;
                        for i=1:length(hObj.EdgeLineHandles_)
                            linesegmentcolor=cd.Data(:,coordToEdge{i});
                            set(hObj.EdgeLineHandles_(i),'ColorBinding','interpolated',...
                            'ColorData',linesegmentcolor,'ColorType','truecoloralpha');
                        end
                        if hasArrows
                            set(hObj.EdgeArrowHandles_,'ColorBinding','discrete',...
                            'ColorData',cd.Data(:,triToEdge),'ColorType','truecoloralpha');
                        end
                    else
                        set(hObj.EdgeLineHandles_,'ColorBinding','none','Visible','off');
                        set(hObj.EdgeArrowHandles_,'ColorBinding','none','Visible','off');
                    end
                else
                    set(hObj.EdgeLineHandles_,'ColorBinding','none','Visible','off');
                    set(hObj.EdgeArrowHandles_,'ColorBinding','none','Visible','off');
                end


                function pixel=transformDataToViewer(hObj,data)






                    [hCamera,aboveMatrix,hDataSpace,belowMatrix]=matlab.graphics.internal.getSpatialTransforms(hObj);

                    vertexData=matlab.graphics.internal.transformDataToWorld(hDataSpace,belowMatrix,data);
                    pixel=matlab.graphics.internal.transformWorldToViewer(hCamera,aboveMatrix,hDataSpace,belowMatrix,vertexData,true);


                    function data=transformViewerToData(hObj,pixel)




                        [hCamera,aboveMatrix,hDataSpace,belowMatrix]=matlab.graphics.internal.getSpatialTransforms(hObj);

                        vertexData=matlab.graphics.internal.transformViewerToWorld(hCamera,aboveMatrix,hDataSpace,belowMatrix,pixel);
                        data=matlab.graphics.internal.transformWorldToData(hDataSpace,belowMatrix,vertexData);


                        function[pixelPosition,pixelDir]=midEdgeAnchors(hObj,useEdge)



                            blockOffset=find(diff(hObj.EdgeCoordsIndex_))';
                            firstPoint=[0,blockOffset];
                            lastPoint=[blockOffset,length(hObj.EdgeCoordsIndex_)];
                            indStart=floor((firstPoint+lastPoint)/2);
                            indEnd=indStart+1;


                            indStart=indStart(useEdge);
                            indEnd=indEnd(useEdge);


                            xyzStart=hObj.EdgeCoords_(indStart,:).';
                            xyzEnd=hObj.EdgeCoords_(indEnd,:).';


                            pixelStart=transformDataToViewer(hObj,xyzStart);
                            pixelEnd=transformDataToViewer(hObj,xyzEnd);


                            pixelPosition=(pixelStart+pixelEnd)/2;


                            pixelDir=pixelEnd-pixelStart;

                            function[pixelPosition,pixelDir]=arrowAnchors(hObj,useEdge)




                                useEdgeCoords=useEdge(hObj.EdgeCoordsIndex_);
                                edgecoords=hObj.EdgeCoords_(useEdgeCoords,:);
                                binSize=accumarray(hObj.EdgeCoordsIndex_,1);
                                edgecoordsindex=reshape(repelem(1:nnz(useEdge),binSize(useEdge)),[],1);


                                pixelCoords=transformDataToViewer(hObj,edgecoords.');


                                segLengths=vecnorm(pixelCoords(:,2:end)-pixelCoords(:,1:end-1),2,1);
                                segLengths(diff(edgecoordsindex)~=0)=0;
                                segLengths(end+1)=0;
                                edgeLengths=accumarray(edgecoordsindex,segLengths);
                                anchorLength=hObj.ArrowPosition(:).*edgeLengths;

                                blockOffset=find(diff(edgecoordsindex))';
                                firstPoint=[0,blockOffset]+1;
                                lastPoint=[blockOffset,length(edgecoordsindex)];

                                indStart=zeros(size(firstPoint));
                                ratioInSegment=zeros(size(firstPoint));

                                for ii=1:length(firstPoint)
                                    iS=firstPoint(ii);
                                    iE=lastPoint(ii)-1;

                                    if iS==iE
                                        indStart(ii)=iS;
                                        if isscalar(hObj.ArrowPosition)
                                            ratioInSegment(ii)=hObj.ArrowPosition;
                                        else
                                            ratioInSegment(ii)=hObj.ArrowPosition(ii);
                                        end
                                    else
                                        cumLen=0;
                                        aL=anchorLength(ii);
                                        for ind=iS:iE-1
                                            cumLenNext=segLengths(ind)+cumLen;
                                            if cumLen<=aL&&aL<=cumLenNext
                                                break;
                                            end
                                            cumLen=cumLenNext;
                                        end
                                        if cumLenNext<anchorLength(ii)
                                            ind=iE;
                                        end

                                        indStart(ii)=ind;
                                        ratioInSegment(ii)=(anchorLength(ii)-cumLen)/segLengths(ind);
                                    end
                                end

                                pixelStart=pixelCoords(:,indStart);
                                pixelEnd=pixelCoords(:,indStart+1);


                                pixelPosition=pixelStart+ratioInSegment.*(pixelEnd-pixelStart);


                                pixelDir=pixelEnd-pixelStart;


                                function triToEdge=setArrowCoords(hObj,us,isVisibleEdge)

                                    if~any(isVisibleEdge)
                                        hObj.EdgeArrowHandles_.VertexData=[];
                                        triToEdge=[];
                                        return;
                                    end

                                    [pixelPosition,pixelDir]=arrowAnchors(hObj,isVisibleEdge);
                                    angle=atan2d(pixelDir(2,:),pixelDir(1,:));



                                    narrowfrx=.75;
                                    depth=0.35;
                                    x=[-1,0;0,-1;-1+depth,-1+depth];
                                    y=narrowfrx.*[0.5,0;0,-0.5;0,0];



                                    x=(4/3)*x;
                                    y=(4/3)*y;



                                    if isscalar(hObj.ArrowSize_I)
                                        x=repmat(hObj.ArrowSize_I*x(:),1,numel(angle));
                                        y=repmat(hObj.ArrowSize_I*y(:),1,numel(angle));
                                    else
                                        x=x(:).*hObj.ArrowSize_I;
                                        y=y(:).*hObj.ArrowSize_I;
                                    end

                                    xmid=pixelPosition(1,:);
                                    ymid=pixelPosition(2,:);
                                    zmid=pixelPosition(3,:);

                                    angle=repmat(angle,6,1);
                                    xmid=repmat(xmid,6,1);
                                    ymid=repmat(ymid,6,1);
                                    zmid=repmat(zmid,6,1);

                                    xx=x.*cosd(angle)-y.*sind(angle);
                                    yy=x.*sind(angle)+y.*cosd(angle);
                                    zz=zeros(size(xx));

                                    xx=xmid+xx;
                                    yy=ymid+yy;
                                    zz=zmid+zz;

                                    pixelArrowPoints=[xx(:),yy(:),zz(:)]';

                                    arrowPoints=transformViewerToData(hObj,pixelArrowPoints);

                                    xx=reshape(arrowPoints(1,:),size(xx));
                                    yy=reshape(arrowPoints(2,:),size(yy));
                                    zz=reshape(arrowPoints(3,:),size(zz));

                                    piter=matlab.graphics.axis.dataspace.XYZPointsIterator;
                                    piter.XData=xx;
                                    piter.YData=yy;
                                    piter.ZData=zz;

                                    vd=TransformPoints(us.DataSpace,...
                                    us.TransformUnderDataSpace,...
                                    piter);
                                    hObj.EdgeArrowHandles_.VertexData=vd;

                                    triToEdge=repelem(find(isVisibleEdge),1,2);

                                    function setEdgeLabels(hObj,us,isValidEdge)

                                        hasLabel=~cellfun(@isempty,hObj.EdgeLabel_I);
                                        nrLabels=sum(hasLabel);

                                        if nrLabels==0||~any(isValidEdge)
                                            set(hObj.EdgeLabelHandles_,'Visible','off');
                                            return;
                                        end
                                        set(hObj.EdgeLabelHandles_,'Visible','on');

                                        [pixelPosition,pixelDir]=midEdgeAnchors(hObj,isValidEdge);


                                        pos=transformViewerToData(hObj,pixelPosition);
                                        piter=matlab.graphics.axis.dataspace.XYZPointsIterator;
                                        piter.XData=pos(1,:);
                                        piter.YData=pos(2,:);
                                        piter.ZData=pos(3,:);
                                        vd=TransformPoints(us.DataSpace,...
                                        us.TransformUnderDataSpace,...
                                        piter);


                                        angle=atand(pixelDir(2,:)./pixelDir(1,:));
                                        angle(isnan(angle))=0;

                                        elhs=hObj.EdgeLabelHandles_;
                                        labelList=find(hasLabel);

                                        validedge(isValidEdge)=1:nnz(isValidEdge);
                                        set(elhs,'HorizontalAlignment','center',...
                                        'VerticalAlignment','bottom',...
                                        'Interpreter',hObj.Interpreter_I);
                                        for labelind=1:nrLabels
                                            m=labelList(labelind);
                                            if isValidEdge(m)
                                                set(elhs(labelind),'String',hObj.EdgeLabel_I(m),...
                                                'VertexData',vd(:,validedge(m)),'Rotation',angle(validedge(m)));

                                                elhs(labelind).Font.Name=hObj.EdgeFontName;
                                                if isrow(hObj.EdgeLabelColor)
                                                    col=hObj.EdgeLabelColor;
                                                else
                                                    col=hObj.EdgeLabelColor(m,:);
                                                end
                                                set(elhs(labelind),'Color',uint8([255*col,255]'));
                                                if isscalar(hObj.EdgeFontSize)
                                                    elhs(labelind).Font.Size=hObj.EdgeFontSize;
                                                else
                                                    elhs(labelind).Font.Size=hObj.EdgeFontSize(m);
                                                end
                                                isitalic=hObj.isEdgeFontItalic_I;
                                                if(isscalar(isitalic)&&isitalic)||(~isscalar(isitalic)&&isitalic(m))
                                                    elhs(labelind).Font.Angle='italic';
                                                else
                                                    elhs(labelind).Font.Angle='normal';
                                                end
                                                isbold=hObj.isEdgeFontBold_I;
                                                if(isscalar(isbold)&&isbold)||(~isscalar(isbold)&&isbold(m))
                                                    elhs(labelind).Font.Weight='bold';
                                                else
                                                    elhs(labelind).Font.Weight='normal';
                                                end

                                            else
                                                set(elhs(labelind),'Visible','off');
                                            end
                                        end



                                        function[isVisibleNodeLabel,isVisibleNodeMarker]=determineNodeVisibility(hObj,us)



                                            if isa(us.DataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
                                                xIsInvalid=...
                                                matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
                                                us.DataSpace.XScale,us.DataSpace.XLim,hObj.XData_I);
                                                yIsInvalid=...
                                                matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
                                                us.DataSpace.YScale,us.DataSpace.YLim,hObj.YData_I);
                                                zIsInvalid=...
                                                matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
                                                us.DataSpace.ZScale,us.DataSpace.ZLim,hObj.ZData_I);
                                                isVisibleNodeLabel=(~xIsInvalid&~yIsInvalid&~zIsInvalid);
                                            else
                                                isVisibleNodeLabel=false(size(hObj.XData_I));
                                            end



                                            isVisibleNodeMarker=~strcmp(hObj.Marker_I,'none')&isVisibleNodeLabel;

                                            if strcmp(hObj.NodeColor_I,'flat')
                                                isVisibleNodeMarker(isnan(hObj.NodeCData_I))=false;
                                            end


                                            function markerToNode=setNodeCoords(hObj,us,isVisibleNode)

                                                piter=matlab.graphics.axis.dataspace.XYZPointsIterator;
                                                piter.XData=hObj.XData_I(isVisibleNode);
                                                piter.YData=hObj.YData_I(isVisibleNode);
                                                piter.ZData=hObj.ZData_I(isVisibleNode);
                                                vd=TransformPoints(us.DataSpace,...
                                                us.TransformUnderDataSpace,...
                                                piter);

                                                nodeToPrimitive=reshape(hObj.MarkerHandlesArrayIndex_,1,[]);
                                                nrPrimitives=numel(hObj.MarkerHandles_);

                                                markerToNode=cell(1,nrPrimitives);
                                                visiblenode=zeros(size(isVisibleNode));
                                                visiblenode(isVisibleNode)=1:nnz(isVisibleNode);

                                                for i=1:nrPrimitives
                                                    index=visiblenode(nodeToPrimitive==i);
                                                    index=index(index~=0);
                                                    hObj.MarkerHandles_(i).VertexData=vd(:,index);
                                                    markerToNode{i}=find(nodeToPrimitive==i&isVisibleNode);
                                                end

                                                function setNodeColors(hObj,us,markerToNode)

                                                    if isnumeric(hObj.NodeColor_I)
                                                        if isrow(hObj.NodeColor_I)

                                                            nc=uint8(255.*[hObj.NodeColor_I(:);1]);
                                                            set(hObj.MarkerHandles_,'FaceColorData',nc,'EdgeColorData',nc,...
                                                            'FaceColorBinding','object','EdgeColorBinding','object');
                                                        else
                                                            nc=uint8(255.*[hObj.NodeColor_I,ones(size(hObj.NodeColor_I,1),1)].');

                                                            for i=1:numel(hObj.MarkerHandles_)
                                                                locNC=nc(:,markerToNode{i});
                                                                set(hObj.MarkerHandles_(i),'FaceColorData',locNC,'EdgeColorData',locNC,...
                                                                'FaceColorBinding','discrete','EdgeColorBinding','discrete');
                                                            end
                                                        end
                                                    elseif strcmp(hObj.NodeColor_I,'flat')

                                                        ci=matlab.graphics.axis.colorspace.IndexColorsIterator;
                                                        ci.Colors=hObj.NodeCData_I(:);
                                                        ci.CDataMapping='scaled';
                                                        cd=TransformColormappedToTrueColor(us.ColorSpace,ci);
                                                        if~isempty(cd)
                                                            for i=1:numel(hObj.MarkerHandles_)
                                                                locNC=cd.Data(:,markerToNode{i});
                                                                set(hObj.MarkerHandles_(i),'FaceColorData',locNC,'EdgeColorData',locNC,...
                                                                'FaceColorBinding','discrete','EdgeColorBinding','discrete');
                                                            end
                                                        else
                                                            set(hObj.MarkerHandles_,'FaceColorBinding','none',...
                                                            'EdgeColorBinding','none','Visible','off');
                                                        end
                                                    else
                                                        set(hObj.MarkerHandles_,'FaceColorBinding','none',...
                                                        'EdgeColorBinding','none','Visible','off');
                                                    end

                                                    function setNodeLabels(hObj,us,isVisibleNodeLabel)

                                                        nlhs=hObj.NodeLabelHandles_;

                                                        if isempty(hObj.NodeLabel_I)
                                                            set(nlhs,'Visible','off');
                                                            return
                                                        end

                                                        set(nlhs,'Visible','on','VerticalAlignment','middle','Interpreter',hObj.Interpreter_I);

                                                        isVisibleNodeLabel=isVisibleNodeLabel&~cellfun(@isempty,hObj.NodeLabel_I);
                                                        visiblenodes=zeros(size(isVisibleNodeLabel));
                                                        visiblenodes(isVisibleNodeLabel)=1:nnz(isVisibleNodeLabel);
                                                        nrLabels=numel(hObj.NodeLabelHandles_);


                                                        if strcmp(hObj.Layout_,'circle')
                                                            doCenter=~isempty(hObj.CirclePerm_);

                                                            angles=[0,360];
                                                            xreverse=strcmp(us.DataSpace.XDir,'reverse');
                                                            yreverse=strcmp(us.DataSpace.YDir,'reverse');
                                                            if xreverse
                                                                angles=angles-180;
                                                            end
                                                            if doCenter
                                                                nn=numnodes(hObj.BasicGraph_);
                                                                center=hObj.CirclePerm_(1);
                                                                ncids=1:nn;
                                                                ncids(center)=[];
                                                                permnc=hObj.CirclePerm_(2:end);


                                                                theta=linspace(angles(1),angles(2),nn);
                                                                theta(ncids)=theta(1:nn-1);
                                                                theta(center)=0;


                                                                theta(ncids(permnc))=theta(ncids);
                                                            else
                                                                theta=linspace(angles(1),angles(2),numnodes(hObj.BasicGraph_)+1);
                                                                theta=theta(1:end-1);
                                                            end
                                                            if xor(xreverse,yreverse)
                                                                theta=-theta;
                                                            end
                                                            theta=mod(theta,360);


                                                            leftHalfPlane=(theta>=90)&(theta<270);
                                                            thetaUpwards=theta;
                                                            thetaUpwards(leftHalfPlane)=theta(leftHalfPlane)+180;

                                                            set(nlhs(isVisibleNodeLabel&leftHalfPlane),'HorizontalAlignment','right');
                                                            set(nlhs(isVisibleNodeLabel&~leftHalfPlane),'HorizontalAlignment','left');
                                                        else
                                                            thetaUpwards=0;
                                                            if strcmp(hObj.Layout_,'layered')
                                                                thetaUpwards=-20;
                                                            end
                                                            theta=repmat(thetaUpwards,1,numel(isVisibleNodeLabel));
                                                            set(nlhs,'HorizontalAlignment','left');
                                                        end


                                                        xyz=[hObj.XData_I;hObj.YData_I;hObj.ZData_I];
                                                        xyz=xyz(:,isVisibleNodeLabel);



                                                        offset=6;
                                                        pixelCoords=transformDataToViewer(hObj,xyz);
                                                        pixelCoords(1,:)=pixelCoords(1,:)+offset*cosd(theta(isVisibleNodeLabel));
                                                        pixelCoords(2,:)=pixelCoords(2,:)+offset*sind(theta(isVisibleNodeLabel));
                                                        xyz=single(transformViewerToData(hObj,pixelCoords));

                                                        piter=matlab.graphics.axis.dataspace.XYZPointsIterator;
                                                        piter.XData=xyz(1,:);
                                                        piter.YData=xyz(2,:);
                                                        piter.ZData=xyz(3,:);
                                                        vd=TransformPoints(us.DataSpace,us.TransformUnderDataSpace,piter);

                                                        if strcmp(hObj.Layout_,'circle')
                                                            for labelind=1:nrLabels
                                                                if isVisibleNodeLabel(labelind)
                                                                    set(nlhs(labelind),'String',hObj.NodeLabel_I(labelind)',...
                                                                    'VertexData',vd(:,visiblenodes(labelind)),...
                                                                    'Rotation',thetaUpwards(labelind));
                                                                else
                                                                    set(nlhs(labelind),'Visible','off');
                                                                end
                                                            end
                                                        else
                                                            for labelind=1:nrLabels
                                                                i=hObj.NodeLabelHandlesArrayIndex_(:)==labelind(:)&isVisibleNodeLabel(:);
                                                                if any(i)
                                                                    set(nlhs(labelind),'String',hObj.NodeLabel_I(i)','VertexData',vd(:,visiblenodes(i)),...
                                                                    'Rotation',thetaUpwards);
                                                                else
                                                                    set(nlhs(labelind),'Visible','off');
                                                                end
                                                            end
                                                        end



                                                        for labelind=1:nrLabels
                                                            nlhs(labelind).Font.Name=hObj.NodeFontName;
                                                        end
