classdef(ConstructOnLoad,Sealed)Line<matlab.graphics.primitive.Data...
    &matlab.graphics.mixin.Legendable&matlab.graphics.chart.interaction.DataAnnotatable...
    &matlab.graphics.mixin.Selectable&matlab.graphics.mixin.AxesParentable...
    &matlab.graphics.internal.Legacy




























    properties(Dependent,AffectsObject)





XData




YData
    end

    properties





        SlowAxesLimitsChange matlab.internal.datatype.matlab.graphics.datatype.on_off='off'
    end

    properties(AffectsObject)





        AlignVertexCenters matlab.internal.datatype.matlab.graphics.datatype.on_off='off'




        MarkerSize matlab.internal.datatype.matlab.graphics.datatype.Positive=6;
    end

    properties(AffectsObject,AffectsLegend)



        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0.447,0.741]




        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5



        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'



        LineJoin matlab.internal.datatype.matlab.graphics.datatype.LineJoin='round'






        MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none'







        MarkerEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto'



        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='none';
    end

    properties(AffectsObject,SetObservable)


        Clipping matlab.internal.datatype.matlab.graphics.datatype.on_off='on'
    end

    properties(Hidden)
        XData_I=[]
        YData_I tall=tall.empty
    end

    properties(Access=private)
Values
XBinEdges
YBinEdges
PartitionXMax
    end

    properties(Access=?matlab.graphics.chart.primitive.tall.internal.RestartManager)
        RestartManager matlab.graphics.chart.primitive.tall.internal.RestartManager
    end

    properties(Access=private,AffectsObject)





        Alpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1






        MarkerFaceAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1






        MarkerEdgeAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1

XLocation
YLocation
    end

    properties(Transient,Access=private)
        LineHandle matlab.graphics.primitive.world.LineStrip
        MarkerHandle{matlab.internal.validation.mustBeValidGraphicsObject(MarkerHandle,'matlab.graphics.primitive.world.Marker')}=matlab.graphics.primitive.world.Marker.empty

        InDoPlotLoop(1,1)logical=false
        Restart(1,1)logical=true
        PauseState matlab.graphics.chart.primitive.tall.internal.PauseState=...
        matlab.graphics.chart.primitive.tall.internal.PauseState.running
        XYDataChanged(1,1)logical=false
        CompletedPartitions logical{matlab.internal.validation.mustBeVector(CompletedPartitions)}=false
        OutOfRangePartitions logical{matlab.internal.validation.mustBeVector(OutOfRangePartitions)}=false

XMaxPrevious
    end

    properties(Transient,Access=private,AffectsObject)

        MarkerFaceAlphaCurrent matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1

        MarkerEdgeAlphaCurrent matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1

        AlphaCurrent matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1
    end

    properties(Access=private,Constant)
        AlphaFactor=0.5

        FrameRate=60
    end

    properties(Transient,DeepCopy,Access=private)
        ProgressBar matlab.graphics.shape.internal.ProgressMeter
        SelectionHandle{mustBe_matlab_mixin_Heterogeneous};
    end

    methods

        function hObj=Line(varargin)

            hObj.LineHandle=matlab.graphics.primitive.world.LineStrip(...
            'LineCap','square','LineWidth',0.5,'Internal',true);
            hObj.MarkerHandle=matlab.graphics.primitive.world.Marker('Style','none',...
            'Internal',true);



            varargin=extractInputNameValue(hObj,varargin,'Parent');

            varargin=extractInputNameValue(hObj,varargin,'XData','XData_I');
            varargin=extractInputNameValue(hObj,varargin,'YData','YData_I');

            hObj.addDependencyConsumed({'dataspace','hgtransform_under_dataspace',...
            'view','xyzdatalimits','ref_frame'});
            lh=addlistener(hObj,'MarkedClean',@(~,~)markedCleanCallback(hObj));
            lh.Recursive=true;


            if~isempty(varargin)
                set(hObj,varargin{:});
            end

            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');

            hObj.ProgressBar=matlab.graphics.shape.internal.ProgressMeter(...
            'Progress',0,'Visible','off','ButtonType','pause','Internal',true);


            import matlab.graphics.chart.primitive.tall.internal.linspaceOnAxis;
            validaxes=~isempty(ax);
            if validaxes&&strcmp(ax.XLimMode,'manual')
                axxlim=ax.ActiveDataSpace.XLim;
                hObj.XBinEdges=linspaceOnAxis(axxlim(1),axxlim(2),...
                hObj.RestartManager.XNpixels+1,ax.XScale,1);
            end
            if validaxes&&strcmp(ax.YLimMode,'manual')
                axylim=ax.ActiveDataSpace.YLim;
                hObj.YBinEdges=linspaceOnAxis(axylim(1),axylim(2),...
                hObj.RestartManager.YNpixels+1,ax.YScale,1);
            end
            if~isempty(hObj.XBinEdges)&&~isempty(hObj.YBinEdges)
                hObj.Values=zeros(length(hObj.XBinEdges)-1,...
                length(hObj.YBinEdges)-1);
            end

            doPlot(hObj);
        end

        function xdata=get.XData(hObj)
            xdata=hObj.XData_I;
        end

        function set.XData(hObj,xdata)
            if istall(xdata)
                xdata=tall.validateType(xdata,'set.XData',...
                {'numeric','logical','datetime','duration'},1);
                xdata=lazyValidate(xdata,{@(x)iscolumn(x)&&(~isnumeric(x)||isreal(x)),...
                'MATLAB:plot:InvalidTallData'});
                xdata=lazyValidate(xdata,{@matlab.graphics.chart.primitive.tall.internal.isMonotonicIncreasing,'MATLAB:plot:XNotMonotonicIncreasing'});
            else
                validateattributes(xdata,{'numeric'},{'size',[0,0]},...
                class(hObj),'XData')
            end
            hObj.XData_I=xdata;
            if~isempty(hObj.RestartManager)
                hObj.RestartManager.DataLimitsCache(1:2)=NaN;
                hObj.RestartManager.XYDataChanged=true;
            end
            hObj.XLocation=[];
            hObj.YLocation=[];
            hObj.Values=[];
            hObj.PartitionXMax=[];
            hObj.CompletedPartitions=false;
        end

        function ydata=get.YData(hObj)
            ydata=hObj.YData_I;
        end

        function set.YData(hObj,ydata)
            if~istall(ydata)
                error(message("MATLAB:class:RequireClass","tall"));
            end
            ydata=tall.validateType(ydata,'set.YData',...
            {'numeric','logical','datetime','duration'},1);
            ydata=lazyValidate(ydata,{@(y)iscolumn(y)&&(~isnumeric(y)||isreal(y)),...
            'MATLAB:plot:InvalidTallData'});
            hObj.YData_I=ydata;
            if~isempty(hObj.RestartManager)
                hObj.RestartManager.DataLimitsCache(3:4)=NaN;
                hObj.RestartManager.XYDataChanged=true;
            end
            hObj.XLocation=[];
            hObj.YLocation=[];
            hObj.Values=[];
        end

        function set.Alpha(hObj,alpha)
            hObj.Alpha=alpha;
            hObj.AlphaCurrent=alpha;%#ok<MCSUP>
        end

        function set.MarkerFaceAlpha(hObj,alpha)
            hObj.MarkerFaceAlpha=alpha;
            hObj.MarkerFaceAlphaCurrent=alpha;%#ok<MCSUP>
        end

        function set.MarkerEdgeAlpha(hObj,alpha)
            hObj.MarkerEdgeAlpha=alpha;
            hObj.MarkerEdgeAlphaCurrent=alpha;%#ok<MCSUP>
        end

        function set.XLocation(hObj,xloc)
            hObj.XLocation=xloc;
            hObj.sendDataChangedEvent();
        end

        function set.YLocation(hObj,yloc)
            hObj.YLocation=yloc;
            hObj.sendDataChangedEvent();
        end

        function set.LineHandle(hObj,line)

            if~isempty(hObj.LineHandle)
                delete(hObj.LineHandle);
            end

            if isempty(line.Parent)
                hObj.LineHandle=line;
            else

                hObj.LineHandle=copy(line);
            end
            hObj.addNode(hObj.LineHandle);
        end

        function set.MarkerHandle(hObj,marker)
            if isa(marker,'double')
                marker=handle(marker);
            end

            if~isempty(hObj.MarkerHandle)
                delete(hObj.MarkerHandle);
            end

            if isempty(marker.Parent)
                hObj.MarkerHandle=marker;
            else

                hObj.MarkerHandle=copy(marker);
            end
            hObj.addNode(hObj.MarkerHandle);
        end

        function set.SelectionHandle(hObj,hsel)
            hObj.SelectionHandle=hsel;
            if~isempty(hObj.SelectionHandle)
                hObj.addNode(hObj.SelectionHandle);


                hObj.SelectionHandle.Description='Tall Line SelectionHandle';
            end
        end

        function set.ProgressBar(hObj,hpb)
            hObj.ProgressBar=hpb;
            if~isempty(hObj.ProgressBar)
                hObj.addNode(hObj.ProgressBar);
                lh=addlistener(hObj.ProgressBar,'Action',@(~,~)pauseButtonListener(hObj));



                lh.Recursive=true;
            end
        end
    end

    methods(Hidden)
        function ex=getXYZDataExtents(hObj)
            if isempty(hObj.XBinEdges)
                x=hObj.XLocation;
            else
                x=[hObj.XBinEdges(1);hObj.XLocation;hObj.XBinEdges(end)];
            end
            x=matlab.graphics.chart.primitive.utilities.arraytolimits(x(isfinite(x)));

            if isempty(hObj.YBinEdges)
                y=hObj.YLocation;
            else
                y=[hObj.YBinEdges(1);hObj.YLocation;hObj.YBinEdges(end)];
            end
            y=matlab.graphics.chart.primitive.utilities.arraytolimits(y(isfinite(y)));

            z=[0,NaN,NaN,0];
            ex=[x;y;z];
        end

        function doUpdate(hObj,us)

            x=hObj.XLocation;
            y=hObj.YLocation;
            z=zeros(1,length(x));

            import matlab.graphics.chart.primitive.utilities.isInvalidInLogScale;
            xIsInvalid=isInvalidInLogScale(...
            us.DataSpace.XScale,us.DataSpace.XLim,x);
            yIsInvalid=isInvalidInLogScale(...
            us.DataSpace.YScale,us.DataSpace.YLim,y);
            xyIsInvalid=xIsInvalid|yIsInvalid;
            x(xyIsInvalid)=[];
            y(xyIsInvalid)=[];
            z(xyIsInvalid)=[];


            ynonfinite=find(~isfinite(y(:)))';
            y(ynonfinite)=[];
            x(ynonfinite)=[];
            z(ynonfinite)=[];
            ynonfinite=ynonfinite-(0:length(ynonfinite)-1);

            piter=matlab.graphics.axis.dataspace.XYZPointsIterator;

            piter.XData=x;
            piter.YData=y;
            piter.ZData=z;

            vd=TransformPoints(us.DataSpace,...
            us.TransformUnderDataSpace,...
            piter);


            if iscolumn(vd)
                vdl=vd(:,[]);
            else
                vdl=vd;
            end

            s=uint32([1,ynonfinite,size(vdl,2)+1]);

            if strcmp(hObj.Color,'none')
                colorbinding='none';
                color=uint8([1;1;1;1]);
            else
                colorbinding='object';
                color=uint8(255*[hObj.Color';hObj.AlphaCurrent]);
            end

            set(hObj.LineHandle,'VertexData',vdl,'StripData',s,'ColorData',color,...
            'ColorType','truecoloralpha',...
            'ColorBinding',colorbinding,...
            'LineWidth',hObj.LineWidth,'LineJoin',hObj.LineJoin,...
            'AlignVertexCenters',hObj.AlignVertexCenters,...
            'Clipping',hObj.Clipping);
            hgfilter('LineStyleToPrimLineStyle',hObj.LineHandle,...
            hObj.LineStyle);


            if strcmp(hObj.MarkerFaceColor,'none')
                facecolorbinding='none';
                facecolor=uint8([1;1;1;1]);
            else
                facecolorbinding='object';
                if strcmp(hObj.MarkerFaceColor,'auto')
                    markerfacecolor=us.BackgroundColor;
                else
                    markerfacecolor=hObj.MarkerFaceColor;
                end
                facecolor=uint8(255*[markerfacecolor';hObj.MarkerFaceAlphaCurrent]);
            end
            if strcmp(hObj.MarkerEdgeColor,'none')
                edgecolorbinding='none';
                edgecolor=uint8([1;1;1;1]);
            elseif strcmp(hObj.MarkerEdgeColor,'auto')

                edgecolorbinding=colorbinding;
                edgecolor=color;
            else
                edgecolorbinding='object';
                edgecolor=uint8(255*[hObj.MarkerEdgeColor';hObj.MarkerEdgeAlphaCurrent]);
            end

            hgfilter('MarkerStyleToPrimMarkerStyle',...
            hObj.MarkerHandle,hObj.Marker);
            set(hObj.MarkerHandle,'VertexData',vd,'FaceColorData',facecolor,...
            'EdgeColorData',edgecolor,'FaceColorType','truecoloralpha',...
            'EdgeColorType','truecoloralpha','Size',hObj.MarkerSize,...
            'FaceColorBinding',facecolorbinding,'EdgeColorBinding',edgecolorbinding,...
            'LineWidth',hObj.LineWidth,'Clipping',hObj.Clipping);


            if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&...
                strcmp(hObj.SelectionHighlight,'on')
                if isempty(hObj.SelectionHandle)
                    hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
                end
                hObj.SelectionHandle.VertexData=[hObj.LineHandle.VertexData];
                hObj.SelectionHandle.Clipping=hObj.Clipping;
                hObj.SelectionHandle.Visible='on';
            else
                if~isempty(hObj.SelectionHandle)
                    hObj.SelectionHandle.VertexData=[];
                    hObj.SelectionHandle.Visible='off';
                end
            end
        end

        function actualValue=setParentImpl(hObj,proposedValue)



            proposedAxesParent=ancestor(proposedValue,'Axes','node');
            if~isempty(proposedAxesParent)
                if isempty(hObj.RestartManager)
                    hObj.RestartManager=...
                    matlab.graphics.chart.primitive.tall.internal.RestartManager(proposedAxesParent);
                else
                    initialize(hObj.RestartManager,proposedAxesParent);
                end
            end
            actualValue=proposedValue;
        end

        function graphic=getLegendGraphic(hObj)
            graphic=matlab.graphics.primitive.world.Group;



            line=matlab.graphics.primitive.world.LineStrip;

            line.VertexData=single([0,1;0.5,0.5;0,0]);
            line.ColorData=hObj.LineHandle.ColorData;
            line.ColorBinding=hObj.LineHandle.ColorBinding;
            line.ColorType=hObj.LineHandle.ColorType;
            line.LineStyle=hObj.LineHandle.LineStyle;
            line.LineWidth=hObj.LineHandle.LineWidth;
            line.LineCap=hObj.LineHandle.LineCap;
            line.LineJoin=hObj.LineHandle.LineJoin;
            line.StripData=[];
            line.Parent=graphic;

            marker=matlab.graphics.primitive.world.Marker;

            marker.VertexData=single([0.5;0.5;0]);
            marker.FaceColorData=hObj.MarkerHandle.FaceColorData;
            marker.FaceColorType=hObj.MarkerHandle.FaceColorType;
            marker.FaceColorBinding=hObj.MarkerHandle.FaceColorBinding;
            marker.EdgeColorData=hObj.MarkerHandle.EdgeColorData;
            marker.EdgeColorType=hObj.MarkerHandle.EdgeColorType;
            marker.EdgeColorBinding=hObj.MarkerHandle.EdgeColorBinding;
            marker.Style=hObj.MarkerHandle.Style;
            marker.LineWidth=hObj.MarkerHandle.LineWidth;
            marker.Visible=hObj.MarkerHandle.Visible;
            marker.Parent=graphic;
        end

        function mcodeConstructor(hObj,code)


            propsToIgnore={'XData','YData'};

            if istall(hObj.XData)
                arg1=codegen.codeargument('Name','xdata',...
                'IsParameter',true,'comment','X values');
                addConstructorArgin(code,arg1);
            end
            arg2=codegen.codeargument('Name','ydata',...
            'IsParameter',true,'comment','Y values');
            addConstructorArgin(code,arg2);

            setConstructorName(code,'plot');

            ignoreProperty(code,propsToIgnore);


            generateDefaultPropValueSyntax(code);
        end
    end

    methods(Access=protected,Hidden)
        function group=getPropertyGroups(~)


            group=matlab.mixin.util.PropertyGroup({...
            'Color','LineStyle','LineWidth','Marker','MarkerSize',...
            'MarkerFaceColor'});
        end


        function descriptors=doGetDataDescriptors(hObj,index,~)
            if~isempty(hObj.XLocation)&&~isempty(hObj.YLocation)
                [x,y]=matlab.graphics.internal.makeNonNumeric(hObj,hObj.XLocation(index),hObj.YLocation(index));
            else


                x=NaN;
                y=NaN;
            end

            descriptors=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('X',x);
            descriptors=[descriptors...
            ,matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Y',y)];
        end

        function index=doGetNearestIndex(hObj,index)
            index=max(1,min(index,length(hObj.XLocation)));
        end

        function index=doGetNearestPoint(hObj,position)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();

            index=pickUtils.nearestPoint(hObj,position,true,...
            hObj.XLocation,hObj.YLocation);
        end

        function[index,interpolationFactor]=doGetInterpolatedPoint(hObj,position)
            index=doGetNearestPoint(hObj,position);
            interpolationFactor=0;
        end

        function points=doGetEnclosedPoints(~,~)
            points=[];
        end

        function[index,interpolationFactor]=doIncrementIndex(hObj,index,direction,~)
            switch direction
            case{'left','down'}
                index=max(index-1,1);
            case{'right','up'}
                index=min(index+1,length(hObj.XLocation));
            end
            interpolationFactor=0;
        end

        function point=doGetDisplayAnchorPoint(hObj,index,~)
            if~isempty(hObj.XLocation)&&~isempty(hObj.YLocation)
                point=matlab.graphics.shape.internal.util.SimplePoint(...
                [hObj.XLocation(index),hObj.YLocation(index),0]);
            else


                point=matlab.graphics.shape.internal.util.SimplePoint(...
                [NaN,NaN,0]);
            end

        end

        function point=doGetReportedPosition(hObj,index,interpolationFactor)
            point=doGetDisplayAnchorPoint(hObj,index,interpolationFactor);
        end
    end

    methods(Access=private)


        function[inputs,propval,found]=extractInputNameValue(hObj,inputs,propname,assignname)
            if nargin<4
                assignname=propname;
            end
            if nargout>1
                returnval=true;
                propval=[];
                found=false;
            else
                returnval=false;
            end
            index=(find(strcmp(inputs(1:2:end),propname))-1)*2+1;
            for i=1:length(index)


                if returnval
                    propval=inputs{index(i)+1};
                    found=true;
                else
                    set(hObj,assignname,inputs{index(i)+1});
                end
            end
            inputs([index,index+1])=[];
        end



        function trimDataPoints(hObj)
            if~isempty(hObj.XLocation)



                binx=discretize(hObj.XLocation,hObj.XBinEdges);
                binxg=findgroups(binx);

                [left,top,bottom,right]=splitapply(@extractminmax,hObj.XLocation,hObj.YLocation,binxg);
                [~,locb]=ismember([left;top;bottom;right],[hObj.XLocation,hObj.YLocation],'rows');



                biny=discretize(hObj.YLocation,hObj.YBinEdges);

                subs=[binx(:),biny(:)];
                subs(any(isnan(subs),2),:)=[];
                hObj.Values=accumarray(subs,ones(size(subs,1),1),[length(hObj.XBinEdges)-1,length(hObj.YBinEdges)-1]);


                trimindices=any([binx,biny]==0,2);

                trimindices(locb(locb>0))=false;
                hObj.XLocation=hObj.XLocation(~trimindices);
                hObj.YLocation=hObj.YLocation(~trimindices);
            else
                hObj.Values=zeros(length(hObj.XBinEdges)-1,length(hObj.YBinEdges)-1);
            end
        end



        function doCleanup(hObj)
            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');
            if~isempty(ax)&&isvalid(ax)

                hObj.InDoPlotLoop=false;
                if~isPaused(hObj.PauseState)
                    hObj.ProgressBar.Visible='off';


                    hObj.ProgressBar.Progress=0;
                    hObj.CompletedPartitions=false;


                    hObj.AlphaCurrent=hObj.Alpha;
                    hObj.MarkerEdgeAlphaCurrent=hObj.MarkerEdgeAlpha;
                    hObj.MarkerFaceAlphaCurrent=hObj.MarkerFaceAlpha;
                end
            end
        end

        function stretchAxes(hObj,xmaxchanged,xminchanged,ymaxchanged,yminchanged)
            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');
            [axxlim,axylim]=matlab.graphics.internal.makeNumeric(...
            hObj,ax.XLim,ax.YLim);





            xmaxstretch=xmaxchanged&&hObj.XBinEdges(end)>axxlim(2);
            xminstretch=xminchanged&&hObj.XBinEdges(1)<axxlim(1);
            xstretch=xmaxstretch||xminstretch;
            ymaxstretch=ymaxchanged&&hObj.YBinEdges(end)>axylim(2);
            yminstretch=yminchanged&&hObj.YBinEdges(1)<axylim(1);
            ystretch=ymaxstretch||yminstretch;
            if strcmp(hObj.SlowAxesLimitsChange,'on')&&...
                (xstretch||ystretch)
                framerate=hObj.FrameRate;
                if xminstretch
                    tempxmin=flip(matlab.graphics.chart.primitive.tall.internal.linspaceOnAxis(...
                    hObj.XBinEdges(1),axxlim(1),framerate,ax.XScale,0));
                else
                    tempxmin=repmat(axxlim(1),1,framerate);
                end
                if xmaxstretch
                    tempxmax=matlab.graphics.chart.primitive.tall.internal.linspaceOnAxis(...
                    axxlim(2),hObj.XBinEdges(end),framerate,ax.XScale,0);
                else
                    tempxmax=repmat(axxlim(2),1,framerate);
                end
                tempxlim=[tempxmin.',tempxmax.'];
                if yminstretch
                    tempymin=flip(matlab.graphics.chart.primitive.tall.internal.linspaceOnAxis(...
                    hObj.YBinEdges(1),axylim(1),framerate,ax.YScale,0));
                else
                    tempymin=repmat(axylim(1),1,framerate);
                end
                if ymaxstretch
                    tempymax=matlab.graphics.chart.primitive.tall.internal.linspaceOnAxis(...
                    axylim(2),hObj.YBinEdges(end),framerate,ax.YScale,0);
                else
                    tempymax=repmat(axylim(2),1,framerate);
                end
                tempylim=[tempymin.',tempymax.'];
                [tempxlim,tempylim]=matlab.graphics.internal.makeNonNumeric(...
                hObj,tempxlim,tempylim);


                hObj.RestartManager.InSlowAxesLimitsChange=true;
                for i=1:framerate
                    if xstretch
                        ax.XLim=tempxlim(i,:);
                    end
                    if ystretch
                        ax.YLim=tempylim(i,:);
                    end
                    hObj.MarkDirty('all');
                    drawnow nocallbacks;
                end
                hObj.RestartManager.InSlowAxesLimitsChange=false;

                if xstretch
                    ax.XLimMode='auto';
                end
                if ystretch
                    ax.YLimMode='auto';
                end
            end
        end

        function shouldStopTheCalculation=parallelBinningClient(hObj,info,eventForClient)


            if~isempty(eventForClient)&&~hObj.Restart







                if~isempty(eventForClient.XMin)
                    if eventForClient.XMin<hObj.XMaxPrevious
                        error(message('MATLAB:plot:XNotMonotonicIncreasing'));
                    end
                    hObj.XMaxPrevious=eventForClient.XMax;
                end


                if isempty(hObj.PartitionXMax)
                    hObj.PartitionXMax=nan(size(info.CompletedPartitions));
                end
                if info.IsLastChunk
                    if isempty(eventForClient.XMax)

                        if info.PartitionId>1
                            hObj.PartitionXMax(info.PartitionId)=...
                            hObj.PartitionXMax(info.PartitionId-1);

                        end
                    else
                        hObj.PartitionXMax(info.PartitionId)=eventForClient.XMax;
                    end
                end


                if~isempty(eventForClient.XMin)
                    hObj.RestartManager.DataLimitsCache([1,3])=min(hObj.RestartManager.DataLimitsCache([1,3]),...
                    [eventForClient.XMin,eventForClient.YMin]);
                    hObj.RestartManager.DataLimitsCache([2,4])=max(hObj.RestartManager.DataLimitsCache([2,4]),...
                    [eventForClient.XMax,eventForClient.YMax]);
                end

                x=eventForClient.XLocation;
                y=eventForClient.YLocation;
                [hObj.XLocation,hObj.YLocation,hObj.Values]=addDataPoints(...
                x,y,hObj.XLocation,hObj.YLocation,hObj.XBinEdges,...
                hObj.YBinEdges,hObj.Values);


                drawnow;

                if isPaused(hObj.PauseState)

                    hObj.CompletedPartitions=info.CompletedPartitions;
                end
            end

            shouldStopTheCalculation=hObj.Restart||isPaused(hObj.PauseState);

            if hObj.PauseState=="pausing"
                hObj.PauseState=matlab.graphics.chart.primitive.tall.internal.PauseState.paused;
            end
        end

        function shouldStopTheCalculation=serialBinningClient(hObj,info,...
            eventForClient,xlimmanual,ylimmanual)


            earlyfinish=false;
            nopixel=false;
            if~isempty(eventForClient)&&~hObj.Restart
                x=eventForClient.X;
                y=eventForClient.Y;


                if~isempty(x)



                    if x(1)<hObj.XMaxPrevious
                        error(message('MATLAB:plot:XNotMonotonicIncreasing'));
                    end
                    hObj.XMaxPrevious=x(end);
                    FiniteIndex=isfinite(x);
                    x=x(FiniteIndex);
                    y=y(FiniteIndex);
                end


                if isempty(hObj.PartitionXMax)
                    hObj.PartitionXMax=nan(size(info.CompletedPartitions));
                end
                if info.IsLastChunk
                    if isempty(eventForClient.XMax)

                        if info.PartitionId>1
                            hObj.PartitionXMax(info.PartitionId)=...
                            hObj.PartitionXMax(info.PartitionId-1);
                        else


                            if~istall(hObj.XData)
                                hObj.PartitionXMax(info.PartitionId)=0;
                            end
                        end
                    elseif isempty(x)&&info.PartitionId>1

                        hObj.PartitionXMax(info.PartitionId)=...
                        hObj.PartitionXMax(info.PartitionId-1)+eventForClient.XMax;
                    else
                        hObj.PartitionXMax(info.PartitionId)=eventForClient.XMax;
                    end
                end


                nopixel=(hObj.RestartManager.XNpixels==0)||...
                (hObj.RestartManager.YNpixels==0);


                if~(isempty(y)||nopixel)
                    ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');
                    import matlab.graphics.chart.primitive.utilities.isInvalidInLogScale;
                    if isempty(x)
                        if info.PartitionId>1
                            maxPrevPartition=hObj.PartitionXMax(info.PartitionId-1);
                        else
                            maxPrevPartition=0;
                        end
                        x=transpose(maxPrevPartition+(eventForClient.XMin:eventForClient.XMax));
                        xmin=x(1);
                        xmax=x(end);

                        xyIsInvalid=isInvalidInLogScale(...
                        ax.YScale,ax.YLim,y);
                    else
                        [xmin,xmax]=bounds(x);

                        if~isfloat(xmin)
                            xmin=double(xmin);
                            xmax=double(xmax);
                        end

                        xIsInvalid=isInvalidInLogScale(...
                        ax.XScale,ax.XLim,x);
                        yIsInvalid=isInvalidInLogScale(...
                        ax.YScale,ax.YLim,y);
                        xyIsInvalid=xIsInvalid|yIsInvalid;
                    end

                    x(xyIsInvalid)=[];
                    y(xyIsInvalid)=[];
                    [ymin,ymax]=bounds(y(isfinite(y)));

                    if~isfloat(ymin)
                        ymin=double(ymin);
                        ymax=double(ymax);
                    end

                    import matlab.graphics.chart.primitive.tall.internal.linspaceOnAxis;
                    import matlab.graphics.chart.primitive.tall.internal.stretchBinEdgesMax;
                    import matlab.graphics.chart.primitive.tall.internal.stretchBinEdgesMin;

                    limschanged=false;


                    xmaxchanged=false;
                    xminchanged=false;
                    if~xlimmanual
                        if isempty(hObj.XBinEdges)
                            hObj.XBinEdges=linspaceOnAxis(xmin,xmax,...
                            hObj.RestartManager.XNpixels+1,ax.XScale,0);
                            limschanged=true;
                        else
                            [hObj.XBinEdges,expandfactor]=stretchBinEdgesMax(xmax,...
                            hObj.XBinEdges,hObj.RestartManager.XNpixels,ax.XScale);
                            xmaxchanged=expandfactor>1;
                            [hObj.XBinEdges,expandfactor]=stretchBinEdgesMin(xmin,...
                            hObj.XBinEdges,hObj.RestartManager.XNpixels,ax.XScale);
                            xminchanged=expandfactor>1;
                            limschanged=limschanged|xmaxchanged|xminchanged;
                        end
                    end

                    ymaxchanged=false;
                    yminchanged=false;
                    if~ylimmanual
                        if isempty(hObj.YBinEdges)

                            hObj.YBinEdges=linspaceOnAxis(ymin,ymax,...
                            hObj.RestartManager.YNpixels+1,ax.YScale,0);
                            limschanged=true;
                        else
                            [hObj.YBinEdges,expandfactor]=stretchBinEdgesMax(ymax,...
                            hObj.YBinEdges,hObj.RestartManager.YNpixels,ax.YScale);
                            ymaxchanged=expandfactor>1;
                            [hObj.YBinEdges,expandfactor]=stretchBinEdgesMin(ymin,...
                            hObj.YBinEdges,hObj.RestartManager.YNpixels,ax.YScale);
                            yminchanged=expandfactor>1;
                            limschanged=limschanged|ymaxchanged|yminchanged;
                        end
                    end


                    stretchAxes(hObj,xmaxchanged,xminchanged,ymaxchanged,yminchanged);



                    if limschanged
                        trimDataPoints(hObj);
                    end


                    hObj.RestartManager.DataLimitsCache([1,3])=min(...
                    hObj.RestartManager.DataLimitsCache([1,3]),[xmin,ymin]);
                    hObj.RestartManager.DataLimitsCache([2,4])=max(...
                    hObj.RestartManager.DataLimitsCache([2,4]),[xmax,ymax]);

                    if~isempty(hObj.XBinEdges)&&~isempty(hObj.YBinEdges)

                        if xmin>hObj.XBinEdges(end)
                            earlyfinish=true;
                        else
                            earlyfinish=false;
                            [hObj.XLocation,hObj.YLocation,hObj.Values]=addDataPoints(...
                            x,y,hObj.XLocation,hObj.YLocation,hObj.XBinEdges,...
                            hObj.YBinEdges,hObj.Values);
                        end
                    end
                    drawnow;

                    if isPaused(hObj.PauseState)

                        hObj.CompletedPartitions=info.CompletedPartitions;
                    end
                end
            end
            shouldStopTheCalculation=earlyfinish||hObj.Restart||isPaused(hObj.PauseState)||nopixel;

            if hObj.PauseState=="pausing"
                hObj.PauseState=matlab.graphics.chart.primitive.tall.internal.PauseState.paused;
            end
        end

        function doPlot(hObj)


            progressCleanupObj=matlab.bigdata.internal.startMultiExecution(...
            'OutputFunction',@hObj.updateProgress,'PrintBasicInformation',false,'CombineMultiProgress',false);%#ok<NASGU>


            finishup=onCleanup(@()doCleanup(hObj));

            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');

            if~isempty(ax)

                hObj.AlphaCurrent=hObj.Alpha*hObj.AlphaFactor;
                hObj.MarkerFaceAlphaCurrent=hObj.MarkerFaceAlpha*hObj.AlphaFactor;
                hObj.MarkerEdgeAlphaCurrent=hObj.MarkerEdgeAlpha*hObj.AlphaFactor;
                hObj.ProgressBar.Visible='on';
                drawnow nocallbacks;

                import matlab.graphics.chart.primitive.utilities.isInvalidInLogScale;
                import matlab.graphics.chart.primitive.tall.internal.linspaceOnAxis;




                hObj.Restart=true;
                while hObj.Restart
                    hObj.Restart=false;



                    xmanual=strcmp(ax.XLimMode,'manual');
                    ymanual=strcmp(ax.YLimMode,'manual');



                    hObj.XMaxPrevious=NaN;
                    oneinput=~istall(hObj.XData);

                    completedpartitions=hObj.CompletedPartitions;
                    outofrangepartitions=hObj.OutOfRangePartitions;

                    if xmanual&&ymanual&&~oneinput




                        xbinedges=hObj.XBinEdges;
                        ybinedges=hObj.YBinEdges;
                        workerFcn=@(varargin)parallelBinningWorker(...
                        varargin{:},xbinedges,ybinedges,...
                        ax,completedpartitions,outofrangepartitions);



                        clientFcn=@(varargin)parallelBinningClient(hObj,varargin{:});
                    else









                        if oneinput
                            workerFcn=@(varargin)serialBinningWorker(...
                            varargin{:},[],ax,completedpartitions,...
                            outofrangepartitions);
                        else
                            workerFcn=@(varargin)serialBinningWorker(...
                            varargin{:},ax,completedpartitions,...
                            outofrangepartitions);
                        end



                        clientFcn=@(varargin)serialBinningClient(hObj,varargin{:},...
                        xmanual,ymanual);
                    end

                    hObj.InDoPlotLoop=true;

                    try
                        if oneinput
                            ydata=hObj.YData;
                            [ydata]=matlab.bigdata.internal.lazyeval.resizeChunksForVisualization(ydata);
                            hOrderedClientforeach(workerFcn,clientFcn,ydata);
                        else
                            xdata=hObj.XData;
                            ydata=hObj.YData;
                            [xdata,ydata]=matlab.bigdata.internal.lazyeval.resizeChunksForVisualization(xdata,ydata);
                            hOrderedClientforeach(workerFcn,clientFcn,ydata,xdata);
                        end
                    catch ME
                        if~(strcmp(ME.identifier,'MATLAB:class:InvalidHandle')||...
                            (~isempty(ME.cause)&&...
                            strcmp(ME.cause{1}.identifier,'MATLAB:class:InvalidHandle')))
                            throw(ME);
                        end
                    end

                    if~isvalid(ax)
                        return;
                    end
                    hObj.InDoPlotLoop=false;

                    if~isPaused(hObj.PauseState)
                        hObj.CompletedPartitions=false;
                    end
                end

                if~isPaused(hObj.PauseState)

                    hObj.ProgressBar.Progress=1;
                    drawnow nocallbacks;
                end


            end
        end

        function markedCleanCallback(hObj)
            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');


            [needrestart,hObj.RestartManager,hObj.XBinEdges,hObj.YBinEdges]=check(hObj.RestartManager,ax,...
            hObj.XBinEdges,hObj.YBinEdges);

            if needrestart

                hObj.Restart=true;

                hObj.PauseState=matlab.graphics.chart.primitive.tall.internal.PauseState.running;
                hObj.ProgressBar.ButtonType='pause';
                hObj.ProgressBar.BarColor=[0,0.6,1.0];
                hObj.CompletedPartitions=false;


                if strcmp(ax.XLimMode,'manual')&&~isempty(hObj.PartitionXMax)
                    hObj.OutOfRangePartitions=hObj.PartitionXMax<hObj.XBinEdges(1)|...
                    [NaN,hObj.PartitionXMax(1:end-1)]>hObj.XBinEdges(end);
                else
                    hObj.OutOfRangePartitions=false;
                end

                if~isempty(hObj.XBinEdges)&&~isempty(hObj.YBinEdges)

                    trimDataPoints(hObj)
                else


                    hObj.XLocation=[];
                    hObj.YLocation=[];
                end



                if~hObj.InDoPlotLoop
                    hObj.doPlot();
                end
            end
        end

        function pauseButtonListener(hObj)
            if isPaused(hObj.PauseState)
                pausecomplete=(hObj.PauseState=="paused");
                hObj.PauseState=matlab.graphics.chart.primitive.tall.internal.PauseState.running;
                hObj.ProgressBar.ButtonType='pause';

                hObj.ProgressBar.BarColor=[0,0.6,1.0];



                if pausecomplete
                    hObj.doPlot();
                end
            else
                hObj.PauseState=matlab.graphics.chart.primitive.tall.internal.PauseState.pausing;
                hObj.ProgressBar.ButtonType='play';

                hObj.ProgressBar.BarColor=[0.8863,0.2392,0.1765];
            end
        end

        function updateProgress(hObj,progressValue,passIndex,numPasses)

            progressValue=(passIndex-1+progressValue)/numPasses;
            completedpartitions=hObj.CompletedPartitions;
            outofrangepartitions=hObj.OutOfRangePartitions;
            completedpartitions=completedpartitions|outofrangepartitions;
            outofrangepartitions=repmat(outofrangepartitions,1,length(completedpartitions)/length(outofrangepartitions));
            progressValue=max(progressValue,mean(completedpartitions(~outofrangepartitions)));
            if isvalid(hObj)&&isvalid(hObj.ProgressBar)&&~isPaused(hObj.PauseState)
                hObj.ProgressBar.Progress=progressValue;
                drawnow nocallbacks;
            end
        end
    end
end



function[leftmost,topmost,bottommost,rightmost]=extractminmax(x,y)

    [~,xmini]=min(x);
    [~,xmaxi]=max(x);
    [~,ymini]=min(y);
    [~,ymaxi]=max(y);

    leftmost=[x(xmini(1)),y(xmini(1))];
    topmost=[x(ymaxi(1)),y(ymaxi(1))];
    bottommost=[x(ymini(1)),y(ymini(1))];
    rightmost=[x(xmaxi(1)),y(xmaxi(1))];

end


function[xloc,yloc,values]=addDataPoints(x,y,xloc,...
    yloc,xbinedges,ybinedges,values)

    if~isempty(x)
        nonFiniteY=~isfinite(y);
        xfinite=x(~nonFiniteY);



        binx=discretize(xfinite,xbinedges);
        if~isempty(binx)
            binxg=findgroups(binx);


            [left,top,bottom,right]=splitapply(@extractminmax,xfinite,y(~nonFiniteY),binxg);
            boundaryValues=unique([left;top;bottom;right],'rows');
            [~,boundingPointIDS]=ismember(boundaryValues,[x,y],'rows');


            boundingPointIDS(boundingPointIDS==0)=[];
        else
            boundingPointIDS=[];
        end


        biny=discretize(y(~nonFiniteY),ybinedges);

        subs=[binx(:),biny(:)];
        subs(any(isnan(subs),2),:)=[];
        binsToAdd=accumarray(subs,ones(size(subs,1),1),...
        [length(xbinedges)-1,length(ybinedges)-1]);

        [rownew,colnew]=find(binsToAdd&~values);
        binx_with_NaNs=NaN(size(y));
        biny_with_NaNs=binx_with_NaNs;
        binx_with_NaNs(~nonFiniteY)=binx;
        biny_with_NaNs(~nonFiniteY)=biny;

        [~,newPointIDS]=ismember([rownew,colnew],[binx_with_NaNs,biny_with_NaNs],'rows');

        newIDs=unique([boundingPointIDS;newPointIDS;find(nonFiniteY)]);

        xloc=[xloc;x(newIDs)];
        [xloc,xind]=sort(xloc);
        yloc=[yloc;y(newIDs)];
        yloc=yloc(xind);

        values=values+binsToAdd;
    end
end

function[shouldStopThisPartition,eventForClient]=...
    parallelBinningWorker(info,y,x,xbinedges,ybinedges,...
    ax,completedpartitions,outofrangepartitions)






    completedpartitions=repmat(completedpartitions,1,info.NumPartitions/length(completedpartitions));
    outofrangepartitions=repmat(outofrangepartitions,1,info.NumPartitions/length(outofrangepartitions));

    skippartitions=completedpartitions|outofrangepartitions;
    if skippartitions(info.PartitionId)
        shouldStopThisPartition=true;
        eventForClient=[];
        return;
    end

    [x,y]=matlab.graphics.internal.makeNumeric(ax,x,y);

    shouldStopThisPartition=info.IsLastChunk;




    if isempty(x)
        eventForClient=[];
        return;
    end

    [eventForClient.XMin,eventForClient.XMax]=bounds(x);
    [eventForClient.YMin,eventForClient.YMax]=bounds(y(isfinite(y)));

    [eventForClient.XLocation,eventForClient.YLocation,eventForClient.Values]=addDataPoints(...
    x,y,[],[],xbinedges,ybinedges,zeros(length(xbinedges)-1,length(ybinedges)-1));
end

function[shouldStopThisPartition,eventForClient]=...
    serialBinningWorker(info,y,x,ax,completedpartitions,outofrangepartitions)







    completedpartitions=repmat(completedpartitions,1,info.NumPartitions/length(completedpartitions));
    outofrangepartitions=repmat(outofrangepartitions,1,info.NumPartitions/length(outofrangepartitions));

    skippartitions=completedpartitions|outofrangepartitions;
    if skippartitions(info.PartitionId)
        shouldStopThisPartition=true;
        eventForClient=[];
        return;
    end

    [x,y]=matlab.graphics.internal.makeNumeric(ax,x,y);

    if isempty(x)&&~isempty(y)

        eventForClient.XMin=info.RelativeIndexInPartition;
        eventForClient.XMax=eventForClient.XMin+length(y)-1;
    else
        [eventForClient.XMin,eventForClient.XMax]=bounds(x);
    end

    eventForClient.X=x;
    eventForClient.Y=y;

    shouldStopThisPartition=info.IsLastChunk;
end

function mustBe_matlab_mixin_Heterogeneous(input)
    if~isa(input,'matlab.mixin.Heterogeneous')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropInitialClsMismatch','%s',message('MATLAB:type:PropInitialClsMismatch','matlab.mixin.Heterogeneous').getString));
    end
end
