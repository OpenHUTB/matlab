classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Sealed)DensityPlot<matlab.graphics.chart.primitive.Data2D...
    &matlab.graphics.mixin.GeographicAxesParentable&matlab.graphics.mixin.AxesParentable...
    &matlab.graphics.mixin.Legendable&matlab.graphics.mixin.Selectable...
    &matlab.graphics.internal.GraphicsUIProperties&matlab.graphics.mixin.ColorOrderUser


















    properties(AffectsObject,AffectsLegend)
        FaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBInterpColor=[0,0,0];
        FaceAlpha='interp'
    end

    properties(Dependent,AffectsObject)
        Radius matlab.internal.datatype.matlab.graphics.datatype.Positive
        WeightData matlab.internal.datatype.matlab.graphics.datatype.VectorData
    end

    properties(Dependent,AffectsObject,NeverAmbiguous)
        RadiusMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Dependent,SetObservable)
        WeightDataSource{matlab.internal.validation.mustBeASCIICharRowVector(WeightDataSource,'WeightDataSource')}=''
    end

    properties(Access=private)
        Radius_I=1
        RadiusMode_I='auto'
        WeightData_I=[]
        WeightDataSource_I=''
    end

    properties(Hidden)
        FaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBInterpColor=[0,0,0];
        WeightDataSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Hidden,Transient,NonCopyable)
        SelectionHandle matlab.graphics.interactor.ListOfPointsHighlight
    end

    properties(AffectsObject,AbortSet,SetAccess='public',GetAccess='public',NeverAmbiguous)
        FaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Hidden,Access={?tDensityPlot,?tgeodensityplot},Transient,NonCopyable)
        Face matlab.graphics.primitive.world.TriangleStrip


Data

OldXDataCache
OldYDataCache
OldXLimits
OldYLimits
        DataExtents=[]
ReportedDataExtents
XYZExtentsCache
        DataChanged=true
        RadiusChanged=true
        WeightDataChanged=true

        GridPosts=150
XGridPoints
YGridPoints
    end

    methods
        function hObj=DensityPlot(varargin)


            ts=matlab.graphics.primitive.world.TriangleStrip;
            ts.Internal=true;
            hObj.addNode(ts);
            hObj.Face=ts;


            hObj.XDataMode='manual';

            hObj.Type='densityplot';
            hObj.addDependencyConsumed({'dataspace','hgtransform_under_dataspace',...
            'view','xyzdatalimits','ref_frame','figurecolormap','colorspace',...
            'colororder_linestyleorder'});

            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);

        end


        function set.Radius(hObj,searchRadius)
            hObj.RadiusMode='manual';
            hObj.Radius_I=searchRadius;
            hObj.RadiusChanged=true;
        end


        function searchRadius=get.Radius(hObj)
            forceFullUpdate(hObj,'all','Radius');
            searchRadius=hObj.Radius_I;
        end


        function set.RadiusMode(hObj,rmode)
            hObj.RadiusMode_I=rmode;
            hObj.RadiusChanged=true;
        end


        function rmode=get.RadiusMode(hObj)
            rmode=hObj.RadiusMode_I;
        end


        function set.WeightData(hObj,w)
            hObj.WeightData_I=w;
            hObj.WeightDataChanged=true;
        end


        function w=get.WeightData(hObj)
            w=hObj.WeightData_I;
        end


        function set.WeightDataSource(hObj,w)
            w=matlab.internal.validation.makeCharRowVector(w);
            hObj.WeightDataSourceMode='manual';
            hObj.WeightDataSource_I=w;
        end


        function w=get.WeightDataSource(hObj)
            w=hObj.WeightDataSource_I;
        end


        function set.FaceAlpha(hObj,a)
            if ischar(a)||isstring(a)

                a=validatestring(a,{'interp'});
            else

                validateattributes(a,{'numeric'},{'nonnegative','scalar','<=',1})
            end
            hObj.FaceAlpha=a;
        end

        function set.FaceColor(hObj,color)
            hObj.FaceColor_I=color;
            hObj.FaceColorMode='manual';
        end

        function val=get.FaceColor(hObj)
            val=hObj.FaceColor_I;
        end
        function datavalues=get.Data(hObj)
            x=double(hObj.XDataCache(:));
            y=double(hObj.YDataCache(:));



            dataUnchanged=...
            isequaln(x,hObj.OldXDataCache)&&...
            isequaln(y,hObj.OldYDataCache);
            if~dataUnchanged

                hObj.OldXDataCache=x;
                hObj.OldYDataCache=y;
                validateGeographicLongitude(hObj,y)
            end

            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');
            xlimits=ax.DataSpace.XLim;
            ylimits=ax.DataSpace.YLim;
            limitsUnchanged=...
            isequaln(xlimits,hObj.OldXLimits)&&...
            isequaln(ylimits,hObj.OldYLimits);
            if~limitsUnchanged

                hObj.OldXLimits=xlimits;
                hObj.OldYLimits=ylimits;
            end

            if dataUnchanged&&limitsUnchanged&&...
                ~hObj.RadiusChanged&&~hObj.WeightDataChanged



                datavalues=hObj.Data;
                hObj.DataChanged=false;
            else


                w=double(hObj.WeightData(:));
                if isempty(w)
                    w=ones(size(x));
                elseif length(w)==1
                    w=repmat(w,length(x),1);
                end

                nani=isfinite(x(:))&isfinite(y(:))&isfinite(w(:));
                x=x(nani);
                y=y(nani);
                w=w(nani);

                if isempty(x)||isempty(y)
                    datavalues=[];
                    hObj.DataChanged=false;
                else

                    r=hObj.Radius_I;

                    datavalues=gridAndApplyKernel(hObj,...
                    xlimits,ylimits,x,y,w,r);


                    hObj.Data=datavalues;

                    hObj.RadiusChanged=false;
                    hObj.WeightDataChanged=false;
                    hObj.DataChanged=true;
                end
            end
        end
    end

    methods(Access=protected,Hidden)
        function groups=getPropertyGroups(hObj)
            dnames=cellfun(@(a)sprintf('%sData',a),...
            hObj.DimensionNames,'UniformOutput',false);
            groups=matlab.mixin.util.PropertyGroup(...
            [{'FaceColor','FaceAlpha'},dnames(1:2),{'WeightData','Radius'}]);
        end
    end

    methods(Access=public,Hidden)
        function doUpdate(hObj,updateState)


            updatedColor=hObj.getColor(updateState);
            if strcmp(hObj.FaceColorMode,'auto')&&~isempty(updatedColor)
                hObj.FaceColor_I=updatedColor;
            end
            if~strcmp(hObj.FaceColor_I,'interp')&&~strcmp(hObj.FaceAlpha,'interp')
                error(message('MATLAB:graphics:densityplot:FaceMustUseInterp'))
            end
            validateGeographicLongitude(hObj)
            if hObj.Visible
                dv=hObj.Data;
                ts=hObj.Face;
                if hObj.DataChanged
                    gridposts=hObj.GridPosts;
                    xp=hObj.XGridPoints;
                    yp=hObj.YGridPoints;

                    ts.StripData=uint32(1:4:(((gridposts-1)^2)*4+1));
                    columnvertices=[...
                    (1:gridposts-1)'...
                    ,(2:gridposts)'...
                    ,(1+gridposts:gridposts+gridposts-1)'...
                    ,(2+gridposts:gridposts+gridposts)'];
                    columnvertices=columnvertices';
                    columnvertices=columnvertices(:);
                    vertices=columnvertices+gridposts*(0:gridposts-2);
                    tvi=uint32(vertices(:)');
                    ts.VertexIndices=tvi;
                    ts.Visible=hObj.Visible;

                    iter=matlab.graphics.axis.dataspace.XYZPointsIterator;
                    iter.XData=xp;
                    iter.YData=yp;
                    iter.ZData=zeros(size(xp));
                    vertexData=TransformPoints(updateState.DataSpace,...
                    updateState.TransformUnderDataSpace,iter);
                    ts.VertexData=vertexData;
                end

                if isempty(dv)
                    ts.ColorBinding_I='none';
                else
                    ci=matlab.graphics.axis.colorspace.IndexColorsIterator;
                    colorMapped=strcmp(hObj.FaceColor,'interp');
                    ci.Colors=dv;
                    ci.CDataMapping='scaled';
                    alphaMapped=strcmp(hObj.FaceAlpha,'interp');
                    if alphaMapped
                        ci.AlphaData=dv;
                        ci.AlphaDataMapping='scaled';
                    end
                    cdata=TransformColormappedToTrueColor(updateState.ColorSpace,ci);
                    if isempty(cdata.Data)
                        ts.ColorBinding_I='none';
                    else
                        set(ts,...
                        'ColorData_I',cdata.Data,...
                        'ColorBinding_I','interpolated',...
                        'ColorType_I','truecoloralpha');
                        if~colorMapped
                            numElements=size(cdata.Data,2);
                            ts.ColorData(1:3,:)=...
                            hObj.FaceColor'*255*ones(1,numElements);
                        end
                        if~alphaMapped
                            ts.ColorData(4,:)=255*hObj.FaceAlpha;
                        end
                    end
                end
            end
            drawSelectionHandle(hObj)
        end

        function actualValue=setParentImpl(~,proposedParent)
            if isa(proposedParent,'matlab.graphics.axis.GeographicAxes')
                actualValue=proposedParent;
            elseif isa(proposedParent,'matlab.graphics.axis.AbstractAxes')...
                &&~isprop(proposedParent,'UserData')


                actualValue=proposedParent;
            elseif isa(proposedParent,'matlab.graphics.axis.AbstractAxes')
                throwAsCaller(MException(message('MATLAB:graphics:geoplot:AxesInput')))
            else





                actualValue=proposedParent;
            end

        end

        graphic=getLegendGraphic(hObj)

        extents=getXYZDataExtents(hObj,transform,constraints)

        function extents=getColorAlphaDataExtents(hObj)
            x=double(hObj.XDataCache(:));
            y=double(hObj.YDataCache(:));
            dataUnchanged=...
            isequaln(x,hObj.OldXDataCache)&&...
            isequaln(y,hObj.OldYDataCache);
            if hObj.RadiusChanged||hObj.WeightDataChanged||...
                ~dataUnchanged||isempty(hObj.ReportedDataExtents)

                w=double(hObj.WeightData(:));
                if isempty(w)
                    w=ones(size(x));
                elseif length(w)==1
                    w=repmat(w,length(x),1);
                end

                nani=isfinite(x(:))&isfinite(y(:))&isfinite(w(:));
                x=x(nani);
                y=y(nani);
                w=w(nani);
                xlimits=[min(x),max(x)];
                ylimits=[min(y),max(y)];

                if hObj.RadiusMode=="auto"
                    r=pickRadius(hObj,xlimits,ylimits,x,y);
                    hObj.Radius_I=r;
                else
                    r=hObj.Radius_I;
                end

                data=gridAndApplyKernel(hObj,xlimits,ylimits,x,y,w,r);
                dataExtents=matlab.graphics.chart.primitive.utilities.arraytolimits(data);
                hObj.DataExtents=dataExtents;
            end
            extents=NaN(2,4);
            if strcmp(hObj.FaceColor,'interp')
                extents(1,:)=hObj.DataExtents;
            end
            if strcmp(hObj.FaceAlpha,'interp')
                extents(2,:)=hObj.DataExtents;
            end
            hObj.ReportedDataExtents=extents;
        end
    end

    methods(Hidden,Access={?tgeodensityplot,?tDensityPlot})
        function r=pickRadius(hObj,xlimits,ylimits,x,y)

            if~isempty(x)&&~isempty(y)



                w(5)=warning('off','MATLAB:triangulation:EmptyTri2DWarnId');
                w(4)=warning('off','MATLAB:delaunayTriangulation:DupPtsWarnId');
                w(3)=warning('off','MATLAB:delaunayTriangulation:ConsSplitPtWarnId');
                w(2)=warning('off','MATLAB:delaunayTriangulation:DupPtsConsUpdatedWarnId');
                w(1)=warning('off','MATLAB:delaunayTriangulation:ConsConsSplitWarnId');
                c=onCleanup(@()warning(w));
                dt=delaunayTriangulation(x,y);



                E=edges(dt);

                ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes');
                isGeographic=isa(ax,'matlab.graphics.axis.GeographicAxes');
                if isGeographic
                    ds=ax.DataSpace;
                    d=greatCircleDistance(ds.Projection,...
                    dt.Points(E(:,1),1),dt.Points(E(:,1),2),...
                    dt.Points(E(:,2),1),dt.Points(E(:,2),2));
                else
                    dE=dt.Points(E(:,1),:)-dt.Points(E(:,2),:);
                    d=hypot(dE(:,1),dE(:,2));
                end
                dmedian=median(d);
                n=numel(d);
                dstd=sqrt(sum(d)/n);
                r=0.9*min(dstd,sqrt(dmedian/log(2)))*n^(-0.2);




                if isGeographic
                    gridThreshold=greatCircleDistance(ds.Projection,...
                    xlimits(1),ylimits(1),xlimits(2),ylimits(2))...
                    /hObj.GridPosts*2;
                    if gridThreshold==0



                        gridThreshold=1/ds.Projection.ScaleFactor;
                    end
                    if r<gridThreshold||~isfinite(r)
                        r=gridThreshold;
                    end
                else
                    xGridThreshold=diff(xlimits)/hObj.GridPosts;
                    yGridThreshold=diff(ylimits)/hObj.GridPosts;
                    if r<xGridThreshold||r<yGridThreshold||~isfinite(r)
                        r=max(xGridThreshold,yGridThreshold);
                    end
                end



                if isempty(r)||~isfinite(r)||r<=0
                    r=1;
                end
            else


                r=1;
            end
        end


        function datavalues=gridAndApplyKernel(hObj,xlimits,ylimits,x,y,w,r)
            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes');
            isGeographic=isa(ax,'matlab.graphics.axis.GeographicAxes');

            if isGeographic
                ds=ax.DataSpace;
                redge=rad2deg(r/ds.Projection.EquatorialRadius);


                redgeY=min(redge/cosd(max(abs(xlimits))),diff(ylimits));
                upperXLimit=90;
                lowerXLimit=-90;
            else
                redge=r;
                redgeY=r;
                upperXLimit=Inf;
                lowerXLimit=-Inf;
            end


            gridposts=hObj.GridPosts;
            xmin=max(max(min(x),xlimits(1))-redge,lowerXLimit);
            xmax=min(min(max(x),xlimits(2))+redge,upperXLimit);
            ymin=max(min(y),ylimits(1))-redgeY;
            ymax=min(max(y),ylimits(2))+redgeY;
            xc=linspace(xmin,xmax,gridposts);
            yc=linspace(ymin,ymax,gridposts);
            [X,Y]=meshgrid(xc,yc);
            xp=reshape(X,numel(X),1);
            yp=reshape(Y,numel(Y),1);

            hObj.XGridPoints=xp;
            hObj.YGridPoints=yp;

            outsidePlotbox=x<xmin|x>xmax|y<ymin|y>ymax;
            x(outsidePlotbox)=[];
            y(outsidePlotbox)=[];
            w(outsidePlotbox)=[];

            if isGeographic


                datavalues=ds.densityHelper(...
                x,y,w,xp,yp,r,ds.Projection.EquatorialRadius);

            else
                datavalues=applyKernel(x,y,w,xp,yp,r);
            end
        end


        function validateGeographicLongitude(hObj,y)
            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes');
            isGeographic=isa(ax,'matlab.graphics.axis.GeographicAxes');
            if isGeographic
                if nargin<2
                    y=hObj.LongitudeData;
                end
                if~isempty(y)
                    ymax=max(y);
                    ymin=min(y);
                    if diff([ymin,ymax])>360
                        error(message('MATLAB:graphics:geoplot:LongitudeSpans360'))
                    end
                end
            end
        end


        function drawSelectionHandle(hObj)

            if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&...
                strcmp(hObj.SelectionHighlight,'on')
                if isempty(hObj.SelectionHandle)
                    sh=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
                    sh.HandleVisibility='off';
                    hObj.SelectionHandle=sh;
                    hObj.addNode(hObj.SelectionHandle);
                end

                hObj.SelectionHandle.VertexData=hObj.Face.VertexData;
                hObj.SelectionHandle.Visible='on';
            else
                if~isempty(hObj.SelectionHandle)
                    hObj.SelectionHandle.VertexData=[];
                    hObj.SelectionHandle.Visible='off';
                end
            end
        end
    end
end

function densityvals=applyKernel(x,y,w,xp,yp,r)


    lhs=3/pi/r^2;
    D=zeros(size(xp));
    for i=1:length(x)



        xyfilter=abs(xp-x(i))<r&abs(yp-y(i))<r;
        xi=abs(xp(xyfilter)-x(i));
        yi=abs(yp(xyfilter)-y(i));

        di=sqrt(xi.^2+yi.^2);
        rhs=(1-(di.^2)/(r^2)).^2;
        rhs(di>r)=0;
        D(xyfilter)=D(xyfilter)+w(i).*rhs;
    end
    densityvals=lhs.*D;
end
