classdef(ConstructOnLoad,Sealed)BoxChart<matlab.graphics.primitive.Data...
    &matlab.graphics.mixin.Legendable&matlab.graphics.mixin.AxesParentable...
    &matlab.graphics.mixin.Pickable&matlab.graphics.mixin.ColorOrderUser...
    &matlab.graphics.chart.interaction.DataAnnotatable...
    &matlab.graphics.internal.GraphicsBaseFunctions







    properties(Dependent)

XData



YData
    end


    properties(Hidden,AffectsObject,AffectsDataLimits)
XData_I

YData_I
    end

    properties(Access=protected,AffectsObject,Transient,NonCopyable)
XDataCache

XDataCacheCategories
    end


    properties(Dependent)

        BoxWidth matlab.internal.datatype.matlab.graphics.datatype.Positive


        BoxFaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor


        BoxEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor


        BoxMedianLineColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor


        BoxFaceAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne


        WhiskerLineColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor


        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive


        WhiskerLineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle


        MarkerColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor


        MarkerSize matlab.internal.datatype.matlab.graphics.datatype.Positive


        MarkerStyle matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle
    end


    properties(Hidden,AffectsObject,AffectsLegend)
        BoxWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5

        BoxFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='#0072BD';

        BoxEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='#0072BD';

        BoxMedianLineColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='#0072BD';

        BoxFaceAlpha_I matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=0.2;

        WhiskerLineColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='#242424';

        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=1

        WhiskerLineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'

        MarkerColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='#0072BD';

        MarkerSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=6

        MarkerStyle_I matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='o'
    end


    properties(Dependent,AbortSet)

        Orientation matlab.internal.datatype.matlab.graphics.datatype.HorizontalVertical


        Notch matlab.internal.datatype.matlab.graphics.datatype.on_off


        JitterOutliers matlab.internal.datatype.matlab.graphics.datatype.on_off
    end

    properties(Hidden,AffectsObject)
        Orientation_I matlab.internal.datatype.matlab.graphics.datatype.HorizontalVertical='vertical';
        Notch_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
        JitterOutliers_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    properties(Transient,NonCopyable,Access={?ChartTestFriend})


GroupStatistics



VertexData
OutlierVertexData
    end


    properties(Hidden,Transient,NonCopyable,Access={?ChartTestFriend})
BoxFace

BoxLineLoop

WhiskerLines

MedianLine

MarkerHandle
    end



    properties(Transient,NonCopyable,Access='private')
        UpdateGroupStats(1,1)logical=true
    end



    properties(Access='protected')
XGroupNames

XGroupIndex

XNumGroups

        IsYMatrix(1,1)logical=false
    end

    properties(AbortSet,AffectsObject)

        BoxFaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        BoxEdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        BoxMedianLineColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        MarkerColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Hidden,AbortSet,NeverAmbiguous)

        BoxWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        BoxFaceAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        WhiskerLineColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        LineWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        WhiskerLineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        MarkerSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        MarkerStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        OrientationMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        NotchMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        JitterOutliersMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        XDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Hidden)


        GroupByColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';


        NumColorGroups matlab.internal.datatype.matlab.graphics.datatype.Positive=1;


        PeerID matlab.internal.datatype.matlab.graphics.datatype.Positive=1


        BoxPeers(:,1)matlab.graphics.chart.primitive.BoxChart


        IsRulerSwap(1,1)logical=true
    end


    methods
        function hObj=BoxChart(varargin)

            hObj.addDependencyConsumed({'colororder_linestyleorder'});


            hObj.initializeGraphicsObjects();


            hObj.initializeGroupStatistics();


            hObj.HitTest='on';
            hObj.HitTestMode='auto';


            hObj.Type='boxchart';


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end


    methods
        function xdata=get.XData(hObj)
            xdata=hObj.XData_I;
        end

        function set.XData(hObj,xdata)
            validateattributes(xdata,{'numeric','categorical'},{'vector','real'},'','XData');
            if hObj.IsYMatrix

                error(message('MATLAB:graphics:boxchart:NoXDataWhenYData2D'));
            end


            [hObj.XGroupIndex,hObj.XGroupNames]=findgroups(xdata);
            hObj.XNumGroups=numel(hObj.XGroupNames);

            hObj.XData_I=xdata;
            hObj.XDataCache=[];
            hObj.XDataMode='manual';
            hObj.UpdateGroupStats=true;
        end

        function ydata=get.YData(hObj)
            ydata=hObj.YData_I;
        end

        function set.YData(hObj,ydata)
            validateattributes(ydata,{'numeric'},{'2d','real'},'','YData');
            if~isvector(ydata)
                hObj.IsYMatrix=true;
            end
            hObj.YData_I=ydata;
            hObj.UpdateGroupStats=true;
        end

        function clr=get.BoxFaceColor(hObj)
            if strcmpi(hObj.BoxFaceColorMode,'auto')
                forceFullUpdate(hObj,'all','BoxFaceColor');
            end
            clr=hObj.BoxFaceColor_I;
        end

        function set.BoxFaceColor(hObj,clr)
            hObj.BoxFaceColor_I=clr;
            hObj.BoxFaceColorMode='manual';
        end

        function clr=get.BoxEdgeColor(hObj)
            if strcmpi(hObj.BoxEdgeColorMode,'auto')
                forceFullUpdate(hObj,'all','BoxFaceColor');
            end
            clr=hObj.BoxEdgeColor_I;
        end

        function set.BoxEdgeColor(hObj,clr)
            hObj.BoxEdgeColor_I=clr;
            hObj.BoxEdgeColorMode='manual';
        end

        function clr=get.BoxMedianLineColor(hObj)
            if strcmpi(hObj.BoxMedianLineColorMode,'auto')
                forceFullUpdate(hObj,'all','BoxEdgeColor');
            end
            clr=hObj.BoxMedianLineColor_I;
        end

        function set.BoxMedianLineColor(hObj,clr)
            hObj.BoxMedianLineColor_I=clr;
            hObj.BoxMedianLineColorMode='manual';
        end

        function fa=get.BoxFaceAlpha(hObj)
            fa=hObj.BoxFaceAlpha_I;
        end

        function set.BoxFaceAlpha(hObj,fa)
            hObj.BoxFaceAlpha_I=fa;
            hObj.BoxFaceAlphaMode='manual';
        end

        function outsize=get.MarkerSize(hObj)
            outsize=hObj.MarkerSize_I;
        end

        function set.MarkerSize(hObj,ms)
            hObj.MarkerSize_I=ms;
            hObj.MarkerSizeMode='manual';
        end

        function outmarker=get.MarkerStyle(hObj)
            outmarker=hObj.MarkerStyle_I;
        end

        function set.MarkerStyle(hObj,ms)
            hObj.MarkerStyle_I=ms;
            hObj.MarkerStyleMode='manual';
        end

        function mc=get.MarkerColor(hObj)
            if strcmpi(hObj.MarkerColorMode,'auto')
                forceFullUpdate(hObj,'all','MarkerColor');
            end
            mc=hObj.MarkerColor_I;
        end

        function set.MarkerColor(hObj,mc)
            hObj.MarkerColor_I=mc;
            hObj.MarkerColorMode='manual';
        end

        function boxwidth=get.BoxWidth(hObj)
            boxwidth=hObj.BoxWidth_I;
        end

        function set.BoxWidth(hObj,bw)
            hObj.BoxWidth_I=bw;
            hObj.BoxWidthMode='manual';
        end

        function linewidth=get.LineWidth(hObj)
            linewidth=hObj.LineWidth_I;
        end

        function set.LineWidth(hObj,lw)
            hObj.LineWidth_I=lw;
            hObj.LineWidthMode='manual';
        end

        function linestyle=get.WhiskerLineStyle(hObj)
            linestyle=hObj.WhiskerLineStyle_I;
        end

        function set.WhiskerLineStyle(hObj,ls)
            hObj.WhiskerLineStyle_I=ls;
            hObj.WhiskerLineStyleMode='manual';
        end

        function lc=get.WhiskerLineColor(hObj)
            lc=hObj.WhiskerLineColor_I;
        end

        function set.WhiskerLineColor(hObj,lc)
            hObj.WhiskerLineColor_I=lc;
            hObj.WhiskerLineColorMode='manual';
        end

        function or=get.Orientation(hObj)
            or=hObj.Orientation_I;
        end

        function set.Orientation(hObj,or)
            if hObj.IsRulerSwap
                [~,err]=matlab.graphics.internal.swapNonNumericXYRulers(hObj);
                if~isempty(err)
                    if strcmp(err,'Type')
                        error(message('MATLAB:graphics:boxchart:OrientationMixedType'));
                    elseif strcmp(err,'YYAxis')
                        error(message('MATLAB:graphics:boxchart:OrientationYYAxis'));
                    end
                end
            end

            hObj.IsRulerSwap=true;
            hObj.Orientation_I=or;
            hObj.OrientationMode='manual';
            hObj.UpdateGroupStats=true;


            valid=isvalid(hObj.BoxPeers);
            set(hObj.BoxPeers(valid),...
            'Orientation_I',hObj.Orientation_I,...
            'OrientationMode',hObj.OrientationMode,...
            'UpdateGroupStats',true,...
            'IsRulerSwap',true);
        end

        function notch=get.Notch(hObj)
            notch=hObj.Notch_I;
        end

        function set.Notch(hObj,notch)
            hObj.Notch_I=notch;
            hObj.NotchMode='manual';
            hObj.UpdateGroupStats=true;
        end

        function jo=get.JitterOutliers(hObj)
            jo=hObj.JitterOutliers_I;
        end

        function set.JitterOutliers(hObj,jo)
            hObj.JitterOutliers_I=jo;
            hObj.JitterOutliersMode='manual';
        end
    end


    methods(Hidden)
        function doUpdate(hObj,updateState)


            if(isvector(hObj.YData)&&numel(hObj.YData)~=numel(hObj.XData))
                error(message('MATLAB:graphics:boxchart:BadXDataVectorYData'));
            end

            if isempty(hObj.XDataCache)&&~isempty(hObj.XData_I)
                recomputeXDataCache(hObj);
            end


            if hObj.UpdateGroupStats
                computeGroupStatistics(hObj)
                hObj.UpdateGroupStats=false;
            end


            plotBoxes(hObj,updateState);


            color=hObj.getColor(updateState);
            if isequal(hObj.BoxFaceColorMode,'auto')&&~isempty(color)
                hObj.BoxFaceColor_I=color;
            else
                color=hObj.BoxFaceColor_I;
            end


            edgeColor=color;
            if isequal(hObj.BoxEdgeColorMode,'auto')&&~isempty(edgeColor)
                hObj.BoxEdgeColor_I=edgeColor;
            else
                edgeColor=hObj.BoxEdgeColor_I;
            end


            medianColor=edgeColor;
            if isequal(hObj.BoxMedianLineColorMode,'auto')&&~isempty(medianColor)
                hObj.BoxMedianLineColor_I=medianColor;
            else
                medianColor=hObj.BoxMedianLineColor_I;
            end


            boxface=hObj.BoxFace;
            hgfilter('RGBAColorToGeometryPrimitive',boxface,[color,hObj.BoxFaceAlpha_I]);


            boxloop=hObj.BoxLineLoop;
            boxloop.LineWidth=hObj.LineWidth_I;
            hgfilter('RGBAColorToGeometryPrimitive',boxloop,edgeColor);


            whisker=hObj.WhiskerLines;
            whisker.LineWidth=hObj.LineWidth_I;
            hgfilter('LineStyleToPrimLineStyle',whisker,hObj.WhiskerLineStyle_I);
            hgfilter('RGBAColorToGeometryPrimitive',whisker,hObj.WhiskerLineColor_I);


            med=hObj.MedianLine;
            med.LineWidth=hObj.LineWidth_I;
            hgfilter('RGBAColorToGeometryPrimitive',med,medianColor);


            outmarker=hObj.MarkerHandle;
            outmarker.Size=hObj.MarkerSize_I;
            hgfilter('MarkerStyleToPrimMarkerStyle',outmarker,hObj.MarkerStyle_I);
            color=hObj.getColor(updateState);
            if isequal(hObj.MarkerColorMode,'auto')&&~isempty(color)
                hObj.MarkerColor_I=color;
            else
                color=hObj.MarkerColor_I;
            end
            hgfilter('EdgeColorToMarkerPrimitive',outmarker,color);
        end

        function graphic=getLegendGraphic(hObj)

            graphic=matlab.graphics.primitive.world.Group;

            face=matlab.graphics.primitive.world.Quadrilateral;
            face.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
            face.VertexIndices=[];
            face.StripData=[];
            hgfilter('RGBAColorToGeometryPrimitive',face,hObj.BoxFace.ColorData);
            face.Visible=hObj.BoxFace.Visible;
            face.Parent=graphic;

            edge=matlab.graphics.primitive.world.LineLoop('LineJoin',...
            'miter','AlignVertexCenters','on');
            edge.LineWidth=hObj.BoxLineLoop.LineWidth;
            edge.LineStyle=hObj.BoxLineLoop.LineStyle;

            edge.VertexData=face.VertexData;
            edge.VertexIndices=[];
            edge.StripData=uint32([1,5]);
            hgfilter('RGBAColorToGeometryPrimitive',edge,hObj.BoxLineLoop.ColorData);
            edge.Visible=hObj.BoxLineLoop.Visible;
            edge.Parent=graphic;
        end

        function ex=getXYZDataExtents(hObj)


            if isempty(hObj.XDataCache)&&~isempty(hObj.XData_I)
                recomputeXDataCache(hObj);
            end
            x=hObj.XDataCache;
            x=x(isfinite(x));

            x=[min(x)-0.5,max(x)+0.5];
            x=matlab.graphics.chart.primitive.utilities.arraytolimits(x);
            y=hObj.YData_I;
            y=matlab.graphics.chart.primitive.utilities.arraytolimits(y(isfinite(y)));
            z=[0,NaN,NaN,0];
            if strcmpi(hObj.Orientation_I,'vertical')
                ex=[x;y;z];
            else
                ex=[y;x;z];
            end
        end
    end

    methods(Access='protected',Hidden)
        function initializeGroupStatistics(hObj)

            hObj.GroupStatistics.Median=[];
            hObj.GroupStatistics.BoxLower=[];
            hObj.GroupStatistics.BoxUpper=[];
            hObj.GroupStatistics.WhiskerLower=[];
            hObj.GroupStatistics.WhiskerUpper=[];
            hObj.GroupStatistics.Outliers={};
            hObj.GroupStatistics.Notch=[];
            hObj.GroupStatistics.NumOutliers=[];
            hObj.GroupStatistics.NumPoints=[];
        end

        function computeGroupStatistics(hObj)

            ngrp=hObj.XNumGroups;


            hObj.GroupStatistics.Median=zeros(1,ngrp);
            hObj.GroupStatistics.BoxLower=zeros(1,ngrp);
            hObj.GroupStatistics.BoxUpper=zeros(1,ngrp);
            hObj.GroupStatistics.WhiskerLower=zeros(1,ngrp);
            hObj.GroupStatistics.WhiskerUpper=zeros(1,ngrp);
            hObj.GroupStatistics.Outliers=cell(1,ngrp);
            hObj.GroupStatistics.Notch=zeros(2,ngrp);
            hObj.GroupStatistics.NumOutliers=zeros(1,ngrp);
            hObj.GroupStatistics.NumPoints=zeros(1,ngrp);

            for idx=1:ngrp

                xind=hObj.XGroupIndex==idx;
                if isvector(hObj.YData_I)
                    ydata=hObj.YData_I(xind);
                else
                    ydata=hObj.YData_I(:,xind);

                end
                ydata=ydata(:);


                dmed=median(ydata,1,'omitnan');
                if isempty(dmed)
                    dmed=nan;
                end


                q=matlab.graphics.chart.primitive.BoxChart.quartile(ydata);
                q(~isfinite(q))=nan;
                ddown=q(1);
                dup=q(2);


                w=1.5;
                q3q1=dup-ddown;
                odown=ddown-w.*q3q1;
                oup=dup+w.*q3q1;


                minval=min(ydata(ydata>=odown));
                if isempty(minval)
                    minval=min(ydata,[],'omitnan');
                end
                if isempty(minval)||~isfinite(minval)
                    minval=nan;
                end
                dmin=min(minval,ddown);

                maxval=max(ydata(ydata<=oup));
                if isempty(maxval)
                    maxval=max(ydata,[],'omitnan');
                end
                if isempty(maxval)||~isfinite(maxval)
                    maxval=nan;
                end
                dmax=max(maxval,dup);


                out=ydata(ydata>oup|ydata<odown);
                outnum=0;
                if isempty(out)
                    out=nan;
                else
                    outnum=numel(out);
                end

                notch=[nan;nan];
                numpts=numel(ydata(~isnan(ydata)));
                if strcmpi(hObj.Notch_I,'on')&&numpts>0
                    notch=[dmed-1.57*q3q1/sqrt(numpts);
                    dmed+1.57*q3q1/sqrt(numpts)];
                end


                hObj.GroupStatistics.Median(idx)=dmed;
                hObj.GroupStatistics.BoxLower(idx)=ddown;
                hObj.GroupStatistics.BoxUpper(idx)=dup;
                hObj.GroupStatistics.WhiskerLower(idx)=dmin;
                hObj.GroupStatistics.WhiskerUpper(idx)=dmax;
                hObj.GroupStatistics.Outliers{idx}=out';
                hObj.GroupStatistics.Notch(:,idx)=notch;
                hObj.GroupStatistics.NumOutliers(idx)=outnum;
                hObj.GroupStatistics.NumPoints(idx)=numpts;
            end
        end

        function recomputeXDataCache(hObj)
            hObj.XDataCache=matlab.graphics.internal.makeNumeric(hObj.Parent,...
            hObj.XData_I,hObj.YData_I);
            hObj.XDataCacheCategories=matlab.graphics.internal.makeNumeric(hObj.Parent,...
            hObj.XGroupNames,hObj.YData_I);
        end
    end

    methods(Access='protected',Hidden)
        function initializeGraphicsObjects(hObj)




            hFace=matlab.graphics.primitive.world.Quadrilateral;
            hFace.Internal=true;
            hFace.Description_I='Box Face';
            hFace.Clipping_I='on';
            hObj.addNode(hFace);
            hObj.BoxFace=hFace;


            whisklines=matlab.graphics.primitive.world.LineStrip;
            whisklines.Internal=true;
            whisklines.Description_I='Whisker Line';
            whisklines.Clipping_I='on';
            whisklines.AlignVertexCenters='on';
            whisklines.Visible='on';
            hgfilter('LineStyleToPrimLineStyle',whisklines,hObj.WhiskerLineStyle_I);
            whisklines.LineWidth=hObj.LineWidth_I;
            hObj.addNode(whisklines);
            hObj.WhiskerLines=whisklines;


            medianline=matlab.graphics.primitive.world.LineStrip;
            medianline.Internal=true;
            medianline.Description_I='Median Line';
            medianline.Clipping_I='on';
            medianline.AlignVertexCenters='on';
            medianline.Visible='on';
            hgfilter('LineStyleToPrimLineStyle',medianline,hObj.WhiskerLineStyle_I);
            medianline.LineWidth=hObj.LineWidth_I;
            hObj.addNode(medianline);
            hObj.MedianLine=medianline;


            boxloop=matlab.graphics.primitive.world.LineStrip;
            boxloop.Internal=true;
            boxloop.Description_I='Box Edge Loop';
            boxloop.Clipping_I='on';
            boxloop.AlignVertexCenters='on';
            boxloop.LineWidth=hObj.LineWidth_I;
            hObj.addNode(boxloop);
            hObj.BoxLineLoop=boxloop;


            outmarker=matlab.graphics.primitive.world.Marker;
            outmarker.Description_I='Scatter Marker';
            outmarker.Internal=true;
            hObj.addNode(outmarker);
            hObj.MarkerHandle=outmarker;
        end

        function plotBoxes(hObj,updateState)




            hPointsIter=matlab.graphics.axis.dataspace.IndexPointsIterator;


            ngrp=hObj.XNumGroups;


            isvert=strcmpi(hObj.Orientation_I,'vertical');
            donotch=strcmpi(hObj.Notch_I,'on');



            if donotch
                nfacevert=8;
                nloopvert=20;
            else
                nfacevert=4;
                nloopvert=8;
            end
            faceVertexData=zeros(nfacevert*ngrp,3);
            loopVertexData=zeros(nloopvert*ngrp,2);
            lineVertexData=zeros(8*ngrp,3);
            medlineVertexData=zeros(2*ngrp,3);
            outX=zeros(1,0);
            outY=zeros(1,0);

            xcategories=hObj.XDataCacheCategories;
            for idx=1:ngrp

                pos=xcategories(idx);


                [pos,width]=getGroupPositionAndWidth(hObj,pos);


                grpStats=hObj.GroupStatistics;


                bleft=pos-width/2;
                bright=pos+width/2;
                bup=grpStats.BoxUpper(idx);
                bdown=grpStats.BoxLower(idx);

                bmed=grpStats.Median(idx);
                bmax=grpStats.WhiskerUpper(idx);
                bmin=grpStats.WhiskerLower(idx);
                bl=bleft+width/4;
                br=bright-width/4;
                blmed=bleft+width/8;
                brmed=bright-width/8;


                strtindf=nfacevert*(idx-1)+1;
                endindf=nfacevert*idx;
                if donotch


                    bnotchd=grpStats.Notch(1,idx);
                    bnotchu=grpStats.Notch(2,idx);
                    xdataf=[bleft,bright,brmed,blmed,...
                    blmed,brmed,bright,bleft];
                    ydataf=[bnotchd,bnotchd,bmed,bmed,...
                    bmed,bmed,bnotchu,bnotchu];
                else
                    xdataf=[bleft,bright,bright,bleft];
                    ydataf=[bdown,bdown,bup,bup];
                end


                strtindl=nloopvert*(idx-1)+1;
                endindl=nloopvert*idx;
                if donotch
                    xdatal=[bleft,bright,bright,bright,bright,brmed,brmed,...
                    bright,bright,bright,bright,bleft,bleft,bleft,bleft,...
                    blmed,blmed,bleft,bleft,bleft];
                    ydatal=[bdown,bdown,bdown,bnotchd,bnotchd,bmed,bmed,...
                    bnotchu,bnotchu,bup,bup,bup,bup,bnotchu,bnotchu,...
                    bmed,bmed,bnotchd,bnotchd,bdown];
                else
                    xdatal=[bleft,bright,bright,bright,bright,...
                    bleft,bleft,bleft];
                    ydatal=[bdown,bdown,bdown,bup,bup,...
                    bup,bup,bdown];
                end


                strtindw=8*(idx-1)+1;
                endindw=8*idx;
                xdataw=[pos;pos;pos;pos;bl;br;bl;br];
                ydataw=[bmin;bdown;bup;bmax;bmin;bmin;bmax;bmax];


                strtindm=2*(idx-1)+1;
                endindm=2*idx;
                if donotch
                    xdatam=[blmed;brmed];
                else
                    xdatam=[bleft;bright];
                end
                ydatam=[bmed;bmed];


                out=grpStats.Outliers{idx};

                jitterAmount=0;
                if strcmpi(hObj.JitterOutliers_I,'on')

                    jitterAmount=width/2;
                end


                randState=rng;

                if isvert

                    faceVertexData(strtindf:endindf,1:2)=[xdataf(:),ydataf(:)];


                    loopVertexData(strtindl:endindl,:)=[xdatal(:),ydatal(:)];


                    lineVertexData(strtindw:endindw,1:2)=[xdataw,ydataw];


                    medlineVertexData(strtindm:endindm,1:2)=[xdatam,ydatam];


                    x=pos*ones(size(out));
                    x=x+(rand(size(x))-0.5)*jitterAmount;
                    outX=[outX,x];%#ok<AGROW> 
                    outY=[outY,out];%#ok<AGROW> 
                else

                    faceVertexData(strtindf:endindf,1:2)=[ydataf(:),xdataf(:)];


                    loopVertexData(strtindl:endindl,:)=[ydatal(:),xdatal(:)];


                    lineVertexData(strtindw:endindw,1:2)=[ydataw,xdataw];


                    medlineVertexData(strtindm:endindm,1:2)=[ydatam,xdatam];


                    y=pos*ones(size(out));
                    y=y+(rand(size(y))-0.5)*jitterAmount;
                    outX=[outX,out];%#ok<AGROW> 
                    outY=[outY,y];%#ok<AGROW> 
                end
                faceVertexData(strtindf:endindf,3)=idx;
                lineVertexData(strtindw:endindw,3)=idx;
                medlineVertexData(strtindm:endindm,3)=idx;


                rng(randState);
            end






            nOutliers=numel(outX);
            outlierData=[outX',outY',ngrp+(1:nOutliers)'];
            hObj.OutlierVertexData=outlierData(:,1:2);
            hObj.VertexData=[faceVertexData;lineVertexData;...
            medlineVertexData;outlierData];


            faceVertexData(:,1:2)=matlab.graphics.chart.primitive.BoxChart...
            .checkInfsInVertexData(faceVertexData(:,1:2),nfacevert);
            hPointsIter.Vertices=faceVertexData(:,1:2);
            hBFace=hObj.BoxFace;
            hBFace.VertexData=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,hPointsIter);
            hBFace.VertexIndices=uint32(1:(nfacevert*ngrp));
            hBFace.StripData=[];


            loopVertexData=matlab.graphics.chart.primitive.BoxChart...
            .checkInfsInVertexData(loopVertexData,nloopvert);
            hPointsIter.Vertices=loopVertexData;
            hBLoop=hObj.BoxLineLoop;
            hBLoop.VertexData=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,hPointsIter);
            hBLoop.VertexIndices=uint32(1:nloopvert*ngrp);
            hBLoop.StripData=uint32(1:nloopvert:(nloopvert*ngrp)+1);
            hBLoop.LineJoin='miter';
            if donotch
                hBLoop.AlignVertexCenters='off';
            else
                hBLoop.AlignVertexCenters='on';
            end


            hPointsIter.Vertices=lineVertexData(:,1:2);
            hWhisk=hObj.WhiskerLines;
            hWhisk.VertexData=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,hPointsIter);


            hPointsIter.Vertices=medlineVertexData(:,1:2);
            hMed=hObj.MedianLine;
            hMed.VertexData=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,hPointsIter);


            outmarker=hObj.MarkerHandle;
            iter=matlab.graphics.axis.dataspace.XYZPointsIterator;
            outlierNaN=isnan(outX)|isnan(outY);
            outX(outlierNaN)=[];
            outY(outlierNaN)=[];
            iter.XData=outX;
            iter.YData=outY;
            vd=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,iter);
            outmarker.VertexData=vd;
            outmarker.Visible='on';
            outmarker.Size=hObj.MarkerSize_I;
            outmarker.SizeBinding='object';
            outmarker.EdgeColorType_I='truecolor';
            hgfilter('FaceColorToMarkerPrimitive',outmarker,'none');
            hgfilter('MarkerStyleToPrimMarkerStyle',outmarker,hObj.MarkerStyle_I);
        end

        function[pos,width]=getGroupPositionAndWidth(hObj,pos)






            width=hObj.BoxWidth_I;
            if strcmp(hObj.GroupByColorMode,'manual')
                ngrp=hObj.NumColorGroups;
                idx=hObj.PeerID;
                div=1/(ngrp);


                width=width*div;


                pos=pos-0.5+div/2+(idx-1)*div;
            end
        end
    end


    methods(Access='protected',Hidden)
        function groups=getPropertyGroups(~)
            groups=matlab.mixin.util.PropertyGroup(...
            {'XData','YData'});
        end
    end


    methods(Hidden,Access=protected)
        index=doGetNearestPoint(hObj,position)
        [index,interp]=doGetInterpolatedPoint(hObj,position)
        [index,interp]=doGetInterpolatedPointInDataUnits(hObj,position)
        index=doGetNearestIndex(hObj,index)
        [index,interp]=doIncrementIndex(hObj,index,direction,~)
        point=doGetReportedPosition(hObj,index,~)
        point=doGetDisplayAnchorPoint(hObj,index,~)
        descriptors=doGetDataDescriptors(hObj,index,~)

        function indices=doGetEnclosedPoints(~,~)

            indices=[];
        end
    end

    methods(Hidden,Access=public)
        dataTipRows=createDefaultDataTipRows(hObj)
        coordinateData=createCoordinateData(hObj,valueSource,index,~)
        valueSources=getAllValidValueSources(hObj)
    end

    methods(Access='public',Hidden=true)
        function reactToXYRulerSwap(hObj)
            hObj.MarkDirty('limits');
        end

        function resetDataCacheProperties(hObj)
            hObj.XDataCache=[];
        end
    end

    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,hCode)
    end


    methods(Static,Hidden)
        function[y]=quartile(x)


            if isempty(x)
                y=[nan,nan];
                return
            end

            x=sort(x,1);
            n=sum(~isnan(x));
            p=[25;75];


            n(n==0)=1;



            r=(p/100)*n;
            k=floor(r+0.5);
            kp1=k+1;
            r=r-k;


            k(k<1|isnan(k))=1;
            kp1=bsxfun(@min,kp1,n);


            y=(0.5+r).*x(kp1)+(0.5-r).*x(k);


            exact=(r==-0.5);
            if any(exact)
                y(exact)=x(k(exact));
            end


            same=(x(k)==x(kp1));
            if any(same(:))
                x=x(k);
                y(same)=x(same);
            end
        end

        function vData=checkInfsInVertexData(vData,nStep)




            for idx=1:nStep:size(vData,1)
                v=vData(idx:idx+(nStep-1),:);
                if any(~isfinite(v),'all')
                    vData(idx:idx+(nStep-1),:)=Inf;
                end
            end
        end
    end
end