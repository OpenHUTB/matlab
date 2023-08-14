classdef(ConstructOnLoad,Sealed)Scatter<matlab.graphics.primitive.Data...
    &matlab.graphics.mixin.Legendable&matlab.graphics.chart.interaction.DataAnnotatable...
    &matlab.graphics.mixin.Selectable&matlab.graphics.mixin.AxesParentable...
    &matlab.graphics.internal.Legacy

























    properties(Dependent,AffectsObject)



XData




YData

    end

    properties





        SlowAxesLimitsChange matlab.internal.datatype.matlab.graphics.datatype.on_off='on'
    end

    properties(AffectsObject)



        SizeData matlab.internal.datatype.matlab.graphics.datatype.Positive=36;






        MarkerFaceAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1






        MarkerEdgeAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1

    end

    properties(AffectsObject,AffectsLegend)







        MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='none'






        MarkerEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBFlatNoneColor='flat'



        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='o';




        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5




        CData=[];
    end

    properties(AffectsObject,SetObservable)


        Clipping matlab.internal.datatype.matlab.graphics.datatype.on_off='on'
    end

    properties(Hidden)
        XData_I tall=tall.empty
        YData_I tall=tall.empty
    end

    properties(Access=private)
Values
XBinEdges
YBinEdges
    end

    properties(Access=?matlab.graphics.chart.primitive.tall.internal.RestartManager)
        RestartManager matlab.graphics.chart.primitive.tall.internal.RestartManager
    end

    properties(Access=private,AffectsObject)
XLocation
YLocation
    end

    properties(Transient,Access=private)

        MarkerHandle{matlab.internal.validation.mustBeValidGraphicsObject(MarkerHandle,'matlab.graphics.primitive.world.Marker')}=matlab.graphics.primitive.world.Marker.empty

        InDoScatterLoop(1,1)logical=false
        Restart(1,1)logical=true
        PauseState matlab.graphics.chart.primitive.tall.internal.PauseState=...
        matlab.graphics.chart.primitive.tall.internal.PauseState.running
        CompletedPartitions logical{matlab.internal.validation.mustBeVector(CompletedPartitions)}=false
    end


    properties(Transient,Access=private,AffectsObject)

        MarkerFaceAlphaCurrent matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1

        MarkerEdgeAlphaCurrent matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1
    end

    properties(Transient,DeepCopy,Access=private)

        ProgressBar matlab.graphics.shape.internal.ProgressMeter
        SelectionHandle{mustBe_matlab_mixin_Heterogeneous};
    end

    properties(Access=private,Constant)
        AlphaFactor=0.5

        FrameRate=60
    end

    methods

        function hObj=Scatter(varargin)

            hObj.MarkerHandle=matlab.graphics.primitive.world.Marker('Style','circle',...
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
            'Progress',0,'ButtonType','pause','Visible','off','Internal',true);


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

            doScatter(hObj);
        end

        function xdata=get.XData(hObj)
            xdata=hObj.XData_I;
        end

        function set.XData(hObj,xdata)
            if~istall(xdata)
                error(message("MATLAB:class:RequireClass","tall"));
            end
            xdata=tall.validateType(xdata,'set.XData',...
            {'numeric','logical','datetime','duration'},1);
            xdata=lazyValidate(xdata,{@(x)iscolumn(x)&&(~isnumeric(x)||isreal(x)),...
            'MATLAB:scatter:InvalidTallData'});
            hObj.XData_I=xdata;
            if~isempty(hObj.RestartManager)
                hObj.RestartManager.DataLimitsCache(1:2)=NaN;
                hObj.RestartManager.XYDataChanged=true;
            end
            hObj.XLocation=[];
            hObj.YLocation=[];
            hObj.Values=[];
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
            'MATLAB:scatter:InvalidTallData'});
            hObj.YData_I=ydata;
            if~isempty(hObj.RestartManager)
                hObj.RestartManager.DataLimitsCache(3:4)=NaN;
                hObj.RestartManager.XYDataChanged=true;
            end
            hObj.XLocation=[];
            hObj.YLocation=[];
            hObj.Values=[];
        end

        function set.MarkerFaceAlpha(hObj,alpha)
            hObj.MarkerFaceAlpha=alpha;
            hObj.MarkerFaceAlphaCurrent=alpha;%#ok<MCSUP>
        end

        function set.MarkerEdgeAlpha(hObj,alpha)
            hObj.MarkerEdgeAlpha=alpha;
            hObj.MarkerEdgeAlphaCurrent=alpha;%#ok<MCSUP>
        end

        function set.CData(hObj,cdata)
            if~isequal(cdata,[])
                try
                    cdata=hgcastvalue('matlab.graphics.datatype.RGBColor',cdata);
                catch
                    error(message('MATLAB:scatter:CDataMustBeSingleColorSpec'));
                end
            end
            hObj.CData=cdata;
        end

        function set.XLocation(hObj,xloc)
            hObj.XLocation=xloc;
            hObj.sendDataChangedEvent();
        end

        function set.YLocation(hObj,yloc)
            hObj.YLocation=yloc;
            hObj.sendDataChangedEvent();
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

        function set.ProgressBar(hObj,hpb)
            hObj.ProgressBar=hpb;
            if~isempty(hObj.ProgressBar)
                hObj.addNode(hObj.ProgressBar);
                lh=addlistener(hObj.ProgressBar,'Action',@(~,~)pauseButtonListener(hObj));
                lh.Recursive=true;
            end
        end

        function set.SelectionHandle(hObj,hsel)
            hObj.SelectionHandle=hsel;
            if~isempty(hObj.SelectionHandle)
                hObj.addNode(hObj.SelectionHandle);


                hObj.SelectionHandle.Description='Tall Scatter SelectionHandle';
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
            x=matlab.graphics.chart.primitive.utilities.arraytolimits(x);

            if isempty(hObj.YBinEdges)
                y=hObj.YLocation;
            else
                y=[hObj.YBinEdges(1);hObj.YLocation;hObj.YBinEdges(end)];
            end
            y=matlab.graphics.chart.primitive.utilities.arraytolimits(y);

            z=[0,NaN,NaN,0];
            ex=[x;y;z];
        end

        function doUpdate(hObj,us)


            x=hObj.XLocation;
            y=hObj.YLocation;
            z=zeros(size(x));

            xIsInvalid=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
            us.DataSpace.XScale,us.DataSpace.XLim,x);
            yIsInvalid=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
            us.DataSpace.YScale,us.DataSpace.YLim,y);
            xyIsInvalid=xIsInvalid|yIsInvalid;
            x(xyIsInvalid)=[];
            y(xyIsInvalid)=[];
            z(xyIsInvalid)=[];

            piter=matlab.graphics.axis.dataspace.XYZPointsIterator;
            piter.XData=x;
            piter.YData=y;
            piter.ZData=z;

            vd=TransformPoints(us.DataSpace,...
            us.TransformUnderDataSpace,...
            piter);

            if strcmp(hObj.MarkerFaceColor,'none')||...
                (strcmp(hObj.MarkerFaceColor,'flat')&&isempty(hObj.CData))
                facecolorbinding='none';
                facecolor=uint8([1;1;1;1]);
            else
                facecolorbinding='object';
                if strcmp(hObj.MarkerFaceColor,'flat')
                    markerfacecolor=hObj.CData;
                elseif strcmp(hObj.MarkerFaceColor,'auto')
                    markerfacecolor=us.BackgroundColor;
                else
                    markerfacecolor=hObj.MarkerFaceColor;
                end
                facecolor=uint8(255*[markerfacecolor';hObj.MarkerFaceAlphaCurrent]);
            end
            if strcmp(hObj.MarkerEdgeColor,'none')||...
                (strcmp(hObj.MarkerEdgeColor,'flat')&&isempty(hObj.CData))
                edgecolorbinding='none';
                edgecolor=uint8([1;1;1;1]);
            else
                edgecolorbinding='object';
                if strcmp(hObj.MarkerEdgeColor,'flat')
                    markeredgecolor=hObj.CData;
                else
                    markeredgecolor=hObj.MarkerEdgeColor;
                end
                edgecolor=uint8(255*[markeredgecolor';hObj.MarkerEdgeAlphaCurrent]);
            end

            hgfilter('MarkerStyleToPrimMarkerStyle',...
            hObj.MarkerHandle,hObj.Marker);
            set(hObj.MarkerHandle,'VertexData',vd,'FaceColorData',facecolor,...
            'EdgeColorData',edgecolor,'FaceColorType','truecoloralpha',...
            'EdgeColorType','truecoloralpha','Size',sqrt(hObj.SizeData),...
            'FaceColorBinding',facecolorbinding,'EdgeColorBinding',edgecolorbinding,...
            'LineWidth',hObj.LineWidth,'Clipping',hObj.Clipping);


            if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&...
                strcmp(hObj.SelectionHighlight,'on')
                if isempty(hObj.SelectionHandle)
                    hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
                end
                hObj.SelectionHandle.VertexData=[hObj.MarkerHandle.VertexData];
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
            graphic=matlab.graphics.primitive.world.Marker;

            graphic.VertexData=single([0.5;0.5;0]);
            graphic.FaceColorData=hObj.MarkerHandle.FaceColorData;
            graphic.FaceColorType=hObj.MarkerHandle.FaceColorType;
            graphic.FaceColorBinding=hObj.MarkerHandle.FaceColorBinding;
            graphic.EdgeColorData=hObj.MarkerHandle.EdgeColorData;
            graphic.EdgeColorType=hObj.MarkerHandle.EdgeColorType;
            graphic.EdgeColorBinding=hObj.MarkerHandle.EdgeColorBinding;
            graphic.Style=hObj.MarkerHandle.Style;
            graphic.LineWidth=hObj.MarkerHandle.LineWidth;
            graphic.Visible=hObj.MarkerHandle.Visible;

        end

        function mcodeConstructor(~,code)


            propsToIgnore={'XData','YData'};

            arg1=codegen.codeargument('Name','xdata',...
            'IsParameter',true,'comment','X values');
            addConstructorArgin(code,arg1);
            arg2=codegen.codeargument('Name','ydata',...
            'IsParameter',true,'comment','Y values');
            addConstructorArgin(code,arg2);

            setConstructorName(code,'scatter');

            ignoreProperty(code,propsToIgnore);


            generateDefaultPropValueSyntax(code);
        end
    end

    methods(Access=protected,Hidden)
        function group=getPropertyGroups(~)


            group=matlab.mixin.util.PropertyGroup({...
            'Marker','MarkerEdgeColor','MarkerFaceColor','SizeData',...
            'LineWidth','CData'});
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


            if~isempty(hObj.XLocation)&&~isempty(hObj.YLocation)
                xcurr=hObj.XLocation(index);
                ycurr=hObj.YLocation(index);
                switch direction
                case 'left'
                    candidatenodes=find(hObj.XLocation<xcurr);
                case 'right'
                    candidatenodes=find(hObj.XLocation>xcurr);
                case 'up'
                    candidatenodes=find(hObj.YLocation>ycurr);
                case 'down'
                    candidatenodes=find(hObj.YLocation<ycurr);
                end

                if~isempty(candidatenodes)
                    currPoint=[xcurr,ycurr];
                    candidatePoints=[hObj.XLocation(candidatenodes),hObj.YLocation(candidatenodes)];
                    distSqr=sum((candidatePoints-currPoint).^2,2);
                    [~,index]=min(distSqr);
                    index=candidatenodes(index);
                end
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



        function doCleanup(hObj)
            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');
            if~isempty(ax)&&isvalid(ax)

                hObj.InDoScatterLoop=false;
                if~isPaused(hObj.PauseState)
                    hObj.ProgressBar.Visible='off';

                    hObj.ProgressBar.Progress=0;
                    hObj.CompletedPartitions=false;


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
                    hObj.RestartManager.DataLimitsCache([1,3])=min(hObj.RestartManager.DataLimitsCache([1,3]),...
                    [eventForClient.XMin,eventForClient.YMin]);
                    hObj.RestartManager.DataLimitsCache([2,4])=max(hObj.RestartManager.DataLimitsCache([2,4]),...
                    [eventForClient.XMax,eventForClient.YMax]);
                end

                [rownew,colnew]=find(eventForClient.Values&~hObj.Values);
                [~,locb]=ismember([rownew,colnew],[eventForClient.BinX,eventForClient.BinY],'rows');
                hObj.XLocation=[hObj.XLocation;eventForClient.XLocation(locb)];
                hObj.YLocation=[hObj.YLocation;eventForClient.YLocation(locb)];
                hObj.Values=hObj.Values+eventForClient.Values;


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
            nopixel=false;


            if~isempty(eventForClient)&&~hObj.Restart


                x=eventForClient.X;
                y=eventForClient.Y;


                FiniteIndex=isfinite(x)&isfinite(y);
                x=x(FiniteIndex);
                y=y(FiniteIndex);


                nopixel=(hObj.RestartManager.XNpixels==0)||...
                (hObj.RestartManager.YNpixels==0);


                if~(isempty(x)||isempty(y)||nopixel)
                    ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');
                    [x,y]=matlab.graphics.internal.makeNumeric(hObj,x,y);

                    xIsInvalid=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
                    ax.XScale,ax.XLim,x);
                    yIsInvalid=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
                    ax.YScale,ax.YLim,y);
                    xyIsInvalid=xIsInvalid|yIsInvalid;
                    x(xyIsInvalid)=[];
                    y(xyIsInvalid)=[];

                    [xmin,xmax]=bounds(x);

                    if~isfloat(xmin)
                        xmin=double(xmin);
                        xmax=double(xmax);
                    end
                    [ymin,ymax]=bounds(y);

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
                        [hObj.Values,~,~,binx,biny]=histcounts2(hObj.XLocation,...
                        hObj.YLocation,hObj.XBinEdges,hObj.YBinEdges);

                        [~,ia]=unique([binx,biny],'rows');
                        hObj.XLocation=hObj.XLocation(ia);
                        hObj.YLocation=hObj.YLocation(ia);
                    end


                    hObj.RestartManager.DataLimitsCache([1,3])=min(hObj.RestartManager.DataLimitsCache([1,3]),[xmin,ymin]);
                    hObj.RestartManager.DataLimitsCache([2,4])=max(hObj.RestartManager.DataLimitsCache([2,4]),[xmax,ymax]);

                    if~isempty(hObj.XBinEdges)&&~isempty(hObj.YBinEdges)

                        [n,~,~,binx,biny]=histcounts2(x,y,hObj.XBinEdges,hObj.YBinEdges);



                        [rownew,colnew]=find(n&~hObj.Values);
                        [~,locb]=ismember([rownew,colnew],[binx,biny],'rows');
                        hObj.XLocation=[hObj.XLocation;x(locb)];
                        hObj.YLocation=[hObj.YLocation;y(locb)];
                        hObj.Values=hObj.Values+n;
                    end


                    drawnow;
                end

                if isPaused(hObj.PauseState)

                    hObj.CompletedPartitions=info.CompletedPartitions;
                end
            end
            shouldStopTheCalculation=hObj.Restart||isPaused(hObj.PauseState)||nopixel;

            if hObj.PauseState=="pausing"
                hObj.PauseState=matlab.graphics.chart.primitive.tall.internal.PauseState.paused;
            end
        end

        function doScatter(hObj)


            progressCleanupObj=matlab.bigdata.internal.startMultiExecution(...
            'OutputFunction',@hObj.updateProgress,'PrintBasicInformation',false,'CombineMultiProgress',false);%#ok<NASGU>


            finishup=onCleanup(@()doCleanup(hObj));

            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');

            if~isempty(ax)

                hObj.MarkerEdgeAlphaCurrent=hObj.MarkerEdgeAlpha*hObj.AlphaFactor;
                hObj.MarkerFaceAlphaCurrent=hObj.MarkerFaceAlpha*hObj.AlphaFactor;
                hObj.ProgressBar.Visible='on';
                drawnow nocallbacks;

                import matlab.graphics.chart.primitive.utilities.isInvalidInLogScale;
                import matlab.graphics.chart.primitive.tall.internal.linspaceOnAxis;




                hObj.Restart=true;
                while hObj.Restart
                    hObj.Restart=false;









                    completedpartitions=hObj.CompletedPartitions;

                    xdata=hObj.XData;
                    ydata=hObj.YData;
                    [xdata,ydata]=matlab.bigdata.internal.lazyeval.resizeChunksForVisualization(xdata,ydata);

                    hObj.InDoScatterLoop=true;

                    xlimmanual=strcmp(ax.XLimMode,'manual');
                    ylimmanual=strcmp(ax.YLimMode,'manual');
                    if xlimmanual&&ylimmanual







                        xbinedges=hObj.XBinEdges;
                        ybinedges=hObj.YBinEdges;
                        workerFcn=@(varargin)parallelBinningWorker(varargin{:},...
                        xbinedges,ybinedges,ax,completedpartitions);



                        clientFcn=@(varargin)parallelBinningClient(hObj,varargin{:});

                        try
                            hClientforeach(workerFcn,clientFcn,xdata,ydata);
                        catch ME
                            if~(strcmp(ME.identifier,'MATLAB:class:InvalidHandle')||...
                                (~isempty(ME.cause)&&...
                                strcmp(ME.cause{1}.identifier,'MATLAB:class:InvalidHandle')))
                                throw(ME)
                            end
                        end
                    else








                        workerFcn=@(varargin)serialBinningWorker(varargin{:},completedpartitions);



                        clientFcn=@(varargin)serialBinningClient(hObj,varargin{:},...
                        xlimmanual,ylimmanual);

                        try
                            hOrderedClientforeach(workerFcn,clientFcn,xdata,ydata);
                        catch ME
                            if~(strcmp(ME.identifier,'MATLAB:class:InvalidHandle')||...
                                (~isempty(ME.cause)&&...
                                strcmp(ME.cause{1}.identifier,'MATLAB:class:InvalidHandle')))
                                throw(ME)
                            end
                        end
                    end

                    if~isvalid(ax)
                        return;
                    end
                    hObj.InDoScatterLoop=false;

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

                if~isempty(hObj.XBinEdges)&&~isempty(hObj.YBinEdges)
                    [hObj.Values,~,~,binx,biny]=histcounts2(hObj.XLocation,...
                    hObj.YLocation,hObj.XBinEdges,hObj.YBinEdges);

                    [~,ia]=unique([binx,biny],'rows');
                    hObj.XLocation=hObj.XLocation(ia);
                    hObj.YLocation=hObj.YLocation(ia);
                else




                    hObj.XLocation=[];
                    hObj.YLocation=[];
                end



                if~hObj.InDoScatterLoop
                    hObj.doScatter();
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
                    hObj.doScatter();
                end
            else
                hObj.PauseState=matlab.graphics.chart.primitive.tall.internal.PauseState.pausing;
                hObj.ProgressBar.ButtonType='play';

                hObj.ProgressBar.BarColor=[0.8863,0.2392,0.1765];
            end
        end

        function updateProgress(hObj,progressValue,passIndex,numPasses)

            progressValue=(passIndex-1+progressValue)/numPasses;
            progressValue=max(progressValue,mean(hObj.CompletedPartitions));
            if isvalid(hObj)&&isvalid(hObj.ProgressBar)&&~isPaused(hObj.PauseState)
                hObj.ProgressBar.Progress=progressValue;
                drawnow nocallbacks;
            end
        end
    end

end

function[shouldStopThisPartition,eventForClient]=parallelBinningWorker(info,x,y,xbinedges,ybinedges,ax,completedpartitions)







    completedpartitions=repmat(completedpartitions,1,info.NumPartitions/length(completedpartitions));

    if completedpartitions(info.PartitionId)
        shouldStopThisPartition=true;
        eventForClient=[];
        return;
    end

    shouldStopThisPartition=info.IsLastChunk;




    if isempty(x)
        eventForClient=[];
        return;
    end


    [x,y]=matlab.graphics.internal.makeNumeric(ax,x,y);
    [n,~,~,binx,biny]=histcounts2(x,y,xbinedges,ybinedges);



    [uniquebin,locb]=unique([binx,biny],'rows');
    eventForClient.XLocation=x(locb);
    eventForClient.YLocation=y(locb);
    eventForClient.BinX=uniquebin(:,1);
    eventForClient.BinY=uniquebin(:,2);
    eventForClient.Values=n;


    [eventForClient.XMin,eventForClient.XMax]=bounds(x(isfinite(x)));
    [eventForClient.YMin,eventForClient.YMax]=bounds(y(isfinite(y)));

end

function[shouldStopThisPartition,eventForClient]=serialBinningWorker(info,x,y,completedpartitions)







    completedpartitions=repmat(completedpartitions,1,info.NumPartitions/length(completedpartitions));

    if completedpartitions(info.PartitionId)
        shouldStopThisPartition=true;
        eventForClient=[];
        return;
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
