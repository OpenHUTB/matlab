








classdef(CaseInsensitiveProperties=true,Hidden=true)select<handle
    properties
        ScribeLayer=[];
        AxesStartPoint=[];
        ScribeStartPoint=[];
        Figure=[];
        Axes=[];
        Graphics=[];
        AxesXLim=[];
        AxesYLim=[];
        AxesZLim=[];
        Axes2D=true;
    end

    methods
        function this=select(hostAxes)
            this.Figure=ancestor(hostAxes,'figure');
            this.Axes=hostAxes;
            parentCanvasContainer=ancestor(hostAxes,'matlab.ui.internal.mixin.CanvasHostMixin');
            this.ScribeLayer=matlab.graphics.annotation.internal.findAllScribeLayers(parentCanvasContainer);
            this.AxesStartPoint=get(hostAxes,'CurrentPoint');
            this.ScribeStartPoint=get(this.Figure,'CurrentPoint');
            this.AxesXLim=hostAxes.DataSpace.XLim;
            this.AxesYLim=hostAxes.DataSpace.YLim;
            this.AxesZLim=hostAxes.DataSpace.ZLim;
            this.Axes2D=is2D(hostAxes);
        end
        function reset(this)
            if~isempty(this.Graphics)&&((isobject(this.Graphics)&&...
                isvalid(this.Graphics))||(~isobject(this.Graphics)&&...
                ishandle(this.Graphics)))
                delete(this.Graphics);
            end

            this.Graphics=[];
            this.ScribeLayer=[];
            this.Figure=[];
            this.Axes=[];
        end
    end

    methods(Static=true)

        function pixelLocation=transformCameraToFigCoord(ax,pt)

            pixelLocation=matlab.graphics.chart.internal.convertVertexCoordsToViewerCoords(ax,double(pt));


            ax=ancestor(ax,'axes');
            hPanel=ancestor(ax,'matlab.ui.container.Container','node');
            if~isempty(hPanel)&&~isa(hPanel,'matlab.ui.Figure')
                panelPos=getpixelposition(hPanel,true);
                pixelLocation=pixelLocation+panelPos(1:2)'*ones(1,size(pixelLocation,2));
            end

        end

        function position=translateToContainer(hObj,position)


















            position=matlab.ui.internal.FigurePointToLocal.translateFigurePointToLocal(hObj,position);
        end




        function ind_intersection_test=inpolygon(pixelLocations,points)

            if isempty(pixelLocations)||isempty(points)
                ind_intersection_test=[];
                return
            end


            if size(pixelLocations,2)==4&&pixelLocations(1,1)==pixelLocations(1,4)&&...
                pixelLocations(1,2)==pixelLocations(1,3)&&...
                pixelLocations(2,1)==pixelLocations(2,2)&&...
                pixelLocations(2,3)==pixelLocations(2,4)
                I=points(1,:)>=min(pixelLocations(1,:))&points(1,:)<=max(pixelLocations(1,:))&...
                points(2,:)>=min(pixelLocations(2,:))&points(2,:)<=max(pixelLocations(2,:));
                ind_intersection_test=find(I);
                return
            end



            [~,I]=unique(pixelLocations','rows');
            pixelLocations=pixelLocations(:,sort(I));
            numVertices=size(pixelLocations,2);

            ind_intersection_test=false(1,size(points,2));
            for k=1:size(points,2)
                if~all(isfinite(points(:,k)))

                    continue
                end



                polyLocation=pixelLocations-points(:,k)*ones(1,numVertices);


                vert_with_nonpositive_y=polyLocation(2,:)<=0;


                is_line_segment_spanning_x=abs(diff([vert_with_nonpositive_y,vert_with_nonpositive_y(1)]));
                is_line_segment_spanning_x=is_line_segment_spanning_x|...
                ([polyLocation(2,2:end),polyLocation(2,1)]==0);


                if any(is_line_segment_spanning_x)
                    startPts=polyLocation;
                    endPts=polyLocation(:,[2:end,1]);
                    cross_product_test=-startPts(1,:).*(endPts(2,:)-startPts(2,:))>-startPts(2,:).*(endPts(1,:)-startPts(1,:));
                    crossing_test=(cross_product_test==vert_with_nonpositive_y)&is_line_segment_spanning_x;


                    ind_intersection_test(k)=~(mod(sum(crossing_test),2)==0);
                end




                if~ind_intersection_test(k)
                    I=find(~(polyLocation(1,:)|...
                    [polyLocation(1,2:end),polyLocation(1,1)]));
                    if~isempty(I)
                        if I(1)<size(polyLocation,2)
                            ind_intersection_test(k)=(polyLocation(2,I(1))*...
                            polyLocation(2,I(1)+1)<=0);
                        else
                            ind_intersection_test(k)=(polyLocation(2,1)*...
                            polyLocation(2,end)<=0);
                        end
                    end

                    I=find(~(polyLocation(2,:)|...
                    [polyLocation(2,2:end),polyLocation(2,1)]));
                    if~isempty(I)
                        if I(1)<size(polyLocation,2)
                            ind_intersection_test(k)=(polyLocation(1,I(1))*...
                            polyLocation(1,I(1)+1)<=0);
                        else
                            ind_intersection_test(k)=(polyLocation(1,1)*...
                            polyLocation(1,end)<=0);
                        end
                    end
                end

            end
            ind_intersection_test=find(ind_intersection_test);
        end



        function hitobj=axeshittest(fig)
            hitobj=[];
            allAxes=findall(fig,'type','axes');
            mousePos=get(fig,'CurrentPoint');
            for k=1:length(allAxes)
                axFigPos=hgconvertunits(fig,getpixelposition(allAxes(k)),...
                'pixels',get(fig,'Units'),fig);
                if mousePos(1)>=axFigPos(1)&&mousePos(1)<=axFigPos(1)+...
                    axFigPos(3)&&mousePos(2)>=axFigPos(2)&&...
                    mousePos(2)<=axFigPos(2)+axFigPos(4)
                    hitobj=allAxes(k);
                    break;
                end
            end
        end



        function selectedData=getArraySelection(this)

            selectedData=[];

            ydata=get(this,'YData');
            xdata=get(this,'XData');

            if isprop(this,'ZData')
                zdata=get(this,'ZData');



                if~isempty(zdata)&&~isvector(zdata)
                    if isvector(xdata)
                        xdata=repmat(xdata(:)',[size(zdata,1),1]);
                    end
                    if isvector(ydata)
                        ydata=repmat(ydata(:),[1,size(zdata,2)]);
                    end
                else
                    zdata=zdata(:);
                    ydata=ydata(:);
                    xdata=xdata(:);
                end
            else
                zdata=[];
                ydata=ydata(:);
                xdata=xdata(:);
            end



            if isempty(zdata)||isvector(zdata)
                I=any(this.BrushData>0,1);
                if~isempty(I)
                    if isempty(zdata)
                        if isnumeric(xdata)&&isnumeric(ydata)
                            selectedData=[xdata(I),ydata(I)];
                        else
                            selectedData={xdata(I),ydata(I)};
                        end
                    else
                        if isnumeric(xdata)&&isnumeric(ydata)&&isnumeric(zdata)
                            selectedData=[xdata(I),ydata(I),zdata(I)];
                        else
                            selectedData={xdata(I),ydata(I),zdata(I)};
                        end
                    end
                end



            else
                I=this.BrushData>0;
                Icols=any(I,1);
                Irows=any(I,2);
                xdata=xdata(Irows(:),Icols(:));
                ydata=ydata(Irows(:),Icols(:));
                zdata=zdata(Irows(:),Icols(:));
                if isnumeric(xdata)&&isnumeric(ydata)&&isnumeric(zdata)
                    selectedData=[xdata;ydata;zdata];
                else
                    selectedData={xdata;ydata;zdata};
                end
            end
        end


        function clearBrushing(ax)

            fig=handle(ancestor(ax,'figure'));
            brushMgr=datamanager.BrushManager.getInstance();
            if isprop(fig,'LinkPlot')&&fig.LinkPlot
                [mfile,fcnname]=datamanager.getWorkspace(2);
                brushMgr.clearLinked(fig,ax,mfile,fcnname);
            end
            brushMgr.clearUnlinked(ax);
        end
    end
end
