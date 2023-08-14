classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Sealed)ScatterHistogramChart<...
    matlab.graphics.chart.internal.SubplotPositionableChartWithAxes&...
    matlab.graphics.chartcontainer.mixin.ColorOrderMixin&...
    matlab.graphics.datatip.internal.mixin.DataTipMixin








    properties(Transient,Hidden,SetAccess=protected,NonCopyable)
        Type='scatterhistogram'
    end

    properties(Transient,NonCopyable,Hidden,...
        Access={?matlab.graphics.chart.internal.SubplotPositionableChart,...
        ?tOrangeChartWithcolororder})


Axes
    end

    properties(Transient,NonCopyable,Access=private)


AxesHistX
AxesHistY
LegendHandle
    end

    properties(Dependent)
SourceTable
XVariable
YVariable
GroupVariable
    end

    properties(Dependent)
FontSize
XData
YData
Color
XLimits
YLimits
    end

    properties(Access='protected')
        ColorOrderInternalMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Hidden,AffectsObject,Access=private)
XData_I
YData_I
Color_I
XLimits_I
YLimits_I
    end

    properties(AffectsObject,Hidden,AbortSet)
        Title_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
        XLabel_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
        YLabel_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
    end

    properties(AffectsObject,Hidden)
        SourceTable_I tabular=table.empty();
        XVariable_I=''
        YVariable_I=''
        GroupVariable_I=''
    end

    properties(AffectsObject,AbortSet)
        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName=get(groot,'FactoryAxesFontName')
    end

    properties(Access=private,AbortSet)


        UsingTableForData=true;
    end

    properties(Access=private)


        DataDirty logical=false


        XVariableName char=''
        YVariableName char=''
        GroupVariableName char=''
    end

    properties(Access={?tScatterHistogramChart,?tScatterHistogramChart_Negative,...
        ?tscatterhistogramActionAPI,?tScatterHistogramChartDatatips},...
        Transient,NonCopyable)



        StatsTbxActive=false;
    end

    properties(Access=private,Transient,NonCopyable)



ListenerHistX
ListenerHistY


        ListenerTitleEdit=event.proplistener.empty()
        ListenerXLabelEdit=event.proplistener.empty()
        ListenerYLabelEdit=event.proplistener.empty()


MarkedCleanListener
    end

    properties(Access=private)

        NumGroups double;
UniqueGroups
        GroupIndex double



XBins
YBins
XBinWidths
YBinWidths


        UpdateX logical=true
        UpdateY logical=true
        UpdateScatter logical=true;
        UpdateLegend logical=true;
        UpdateLimits logical=true;
        UpdateMarkers logical=true;
        UpdateLines logical=true;
        UpdateLimsInPan logical=true;



        AxesFilled logical=true;
        AxesFilledX logical=true;
        AxesFilledY logical=true;




        LegendVisibleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        LegendTitleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        XLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        YLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        BinWidthsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        NumBinsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        XLabelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        YLabelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        ColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        LineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';



        PlotIndices logical


        XLimitsCache double
        YLimitsCache double
        NumGroupsCache;


ScatterAxesChildren
XHistAxesChildren
YHistAxesChildren



        MaxYValue=0;


        UpdateSavedLimits=false
    end

    properties(Access=private)


DataStorage
PrintSettingsCache
        LooseInsetCache;



PositionStorage
    end

    properties(Dependent)


        NumBins=[]
        BinWidths=[]
        ScatterPlotLocation char{mustBeMember(ScatterPlotLocation,{'SouthWest','SouthEast','NorthEast','NorthWest'})}...
        ='SouthWest'
        XHistogramDirection char{mustBeMember(XHistogramDirection,{'up','down'})}='up';
        YHistogramDirection char{mustBeMember(YHistogramDirection,{'left','right'})}='right';
GroupData
        HistogramDisplayStyle char{mustBeMember(HistogramDisplayStyle,{'stairs','bar','smooth'})}='stairs';
        LegendVisible char{mustBeMember(LegendVisible,{'on','off'})}='on';
        LineStyle=["-",":","-.","--"];
        LineWidth=0.5
        MarkerStyle="o"
        MarkerSize=36
        MarkerFilled char{mustBeMember(MarkerFilled,{'on','off'})}='on';
        MarkerAlpha=1
        ScatterPlotProportion double{mustBeReal,mustBeFinite}=0.75;
        Title matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
        XLabel matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
        YLabel matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
        LegendTitle matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
    end

    properties(Access=private,AffectsObject)


        NumBins_I cell={[],[]}
        BinWidths_I cell={[],[]}
        ScatterPlotLocation_I char{mustBeMember(ScatterPlotLocation_I,{'SouthWest','SouthEast','NorthEast','NorthWest'})}...
        ='SouthWest'
        XHistogramDirection_I char{mustBeMember(XHistogramDirection_I,{'up','down'})}='up';
        YHistogramDirection_I char{mustBeMember(YHistogramDirection_I,{'left','right'})}='right';
GroupData_I
        HistogramDisplayStyle_I char{mustBeMember(HistogramDisplayStyle_I,{'stairs','bar','smooth'})}='stairs';
        LineStyle_I=["-",":","-.","--"];
        LineWidth_I=0.5
        LegendVisible_I char{mustBeMember(LegendVisible_I,{'on','off'})}='on';
        MarkerStyle_I="o"
        MarkerSize_I=36
        MarkerFilled_I char{mustBeMember(MarkerFilled_I,{'on','off'})}='on';
        ScatterPlotProportion_I double{mustBeReal,mustBeFinite}=0.75;
        MarkerAlpha_I=1
        LegendTitle_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
        FontSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=get(groot,'FactoryAxesFontSize')
    end


    properties(Access=private,Transient,NonCopyable)
PanZoomKeystrokes
PanInteraction
ScrollZoomInteraction
        PanZoomActionUpdatePending=false
    end

    properties(Access=private,Transient,Constant)
        StepsPerZoomLevelDefault=1
        StepsPerZoomLevelKeystrokes=1.125
        StepsPerZoomLevelScrollWheel=8
    end


    properties(Access=private,Transient,NonCopyable)
        PointDatatip;
        Linger;
    end

    properties(Hidden)

        FontSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    methods

        function sh=ScatterHistogramChart(varargin)
            sh.Description='ScatterHistogramChart';


            initializeAxesAndLegend(sh);

            setDefaultProperties(sh);

            if~isempty(ver('stats'))

                [status,~]=builtin('license','checkout','Statistics_Toolbox');
                sh.StatsTbxActive=status==1;
            end


            sh.addDependencyConsumed({'ref_frame','resolution'});
            try

                matlab.graphics.chart.internal.ctorHelper(sh,varargin);
            catch e

                sh.Parent=[];
                throwAsCaller(e);
            end


            enableInteractions(sh);


            sh.MarkedCleanListener=addlistener(sh,'MarkedClean',...
            @(~,~)markedCleanCallback(sh));


            drawnow;



            addlistener(sh.Axes,'Hit',...
            @(e,d)sh.showContextMenu(d));
        end

    end


    methods(Access=protected)
        function dtConfig=getDefaultDataTipConfiguration(sh)
            dtConfig=string.empty(0,1);
            if~isempty(sh.SourceTable)

                if~isempty(sh.XVariable)
                    dtConfig{end+1}=sh.XVariableName;
                end

                if~isempty(sh.YVariable)
                    dtConfig{end+1}=sh.YVariableName;
                end

                dtConfig{end+1}=sh.SourceTable.Properties.DimensionNames{1};
                if~isempty(sh.GroupVariable)
                    dtConfig{end+1}=sh.GroupVariableName;
                end
            end
        end

        function showContextMenu(obj,evd)
            if obj.UsingTableForData
                showContextMenu@matlab.graphics.datatip.internal.mixin.DataTipMixin(obj,evd);
            end
        end
    end


    methods(Hidden)
        function initializeAxesAndLegend(sh)

            axScatter=matlab.graphics.axis.Axes();
            axHistX=matlab.graphics.axis.Axes();
            axHistY=matlab.graphics.axis.Axes();


            sh.Axes=axScatter;
            sh.AxesHistX=axHistX;
            sh.AxesHistY=axHistY;
            sh.AxesHistY.YDir='reverse';
            set(axScatter,'Box','on');


            axScatter.Internal=true;
            axHistX.Internal=true;
            axHistY.Internal=true;


            axScatter.Description='ScatterAxes';
            axHistX.Description='HistXAxes';
            axHistY.Description='HistYAxes';


            axHistX.Visible='off';
            axHistY.Visible='off';



            axHistX.PickableParts='all';
            axHistY.PickableParts='all';


            axScatter.FontSizeMode='manual';
            axHistX.FontSizeMode='manual';


            axScatter.NextPlot='replacechildren';
            axHistX.NextPlot='replacechildren';
            axHistY.NextPlot='replacechildren';


            axHistX.XAxis.Visible='on';
            axHistY.XAxis.Visible='on';
            axHistX.Toolbar.Visible='off';
            axHistY.Toolbar.Visible='off';
            axHistX.XTick=[];
            axHistY.XTick=[];
            axHistX.PositionConstraint='innerposition';
            axHistY.PositionConstraint='innerposition';




            axScatter.Title.String='';
            axHistX.Title.String='';


            sh.addNode(axScatter);
            sh.addNode(axHistX);
            sh.addNode(axHistY);


            bh=hggetbehavior(axScatter,'brush');
            bh.Enable=false;
            bh.Serialize=false;
            bh=hggetbehavior(axHistX,'brush');
            bh.Enable=false;
            bh.Serialize=false;
            bh=hggetbehavior(axHistY,'brush');
            bh.Enable=false;
            bh.Serialize=false;


            sh.LegendHandle=matlab.graphics.illustration.internal.ColorLegend(axScatter);
            sh.LegendHandle.Legend.Units='normalized';
            sh.LegendHandle.Visible='off';


            axesLegendNode=getNode(sh.LegendHandle);
            addNode(sh,axesLegendNode);
        end


        function setDefaultProperties(sh)



            sh.UpdateX=false;
            sh.UpdateY=false;
            sh.UpdateScatter=false;

            sh.AxesFilled=false;
            sh.AxesFilledX=false;
            sh.AxesFilledY=false;
            sh.UpdateLegend=true;
            sh.UpdateMarkers=false;
            sh.UpdateLines=false;

            co=get(groot,'FactoryAxesColorOrder');
            sh.Color_I=co(1,:);
            sh.NumGroups=1;


            sh.FontName=get(groot,'FactoryAxesFontName');
            sh.FontSize_I=get(groot,'FactoryAxesFontSize');
        end


        function enableInteractions(sh)

            sh.initializePalette(@(~,~)zoomIn(sh),@(~,~)zoomOut(sh),...
            @(~,~)fitToData(sh));
            sh.setupMouseInteraction();


            sh.initializeDatatip();
        end
    end


    methods

        function set.XData(sh,data)


            matrixMode=~sh.UsingTableForData||width(sh.SourceTable)==0;
            assert(matrixMode,message('MATLAB:graphics:scatterhistogram:TableWorkflow','XData'));


            validateattributes(data,{'numeric','categorical'},{'real','nonsparse','vector'},'','XData');


            sh.UpdateX=true;sh.UpdateScatter=true;sh.UpdateLegend=true;
            sh.XData_I=data(:);
            sh.UsingTableForData=false;


            sh.PlotIndices=true(size(sh.XData));
        end

        function data=get.XData(sh)
            if sh.UsingTableForData

                updateData(sh);
            end
            data=sh.XData_I;
        end


        function set.YData(sh,data)


            matrixMode=~sh.UsingTableForData||width(sh.SourceTable)==0;
            assert(matrixMode,message('MATLAB:graphics:scatterhistogram:TableWorkflow','YData'));


            validateattributes(data,{'numeric','categorical'},{'real','nonsparse','vector'},'','YData');


            sh.UpdateY=true;sh.UpdateScatter=true;sh.UpdateLegend=true;
            sh.YData_I=data(:);
            sh.UsingTableForData=false;
        end

        function data=get.YData(sh)
            if sh.UsingTableForData

                updateData(sh);
            end
            data=sh.YData_I;
        end


        function xlimit=get.XLimits(sh)
            xlimit=sh.Axes.XLim;
        end

        function set.XLimits(sh,xlimit)

            try
                sh.Axes.XLim=xlimit;
                sh.XLimits_I=xlimit;
                sh.XLimitsMode='manual';
            catch e
                throwAsCaller(e);
            end
        end

        function set.XLimitsMode(sh,mode)


            sh.XLimitsMode=mode;
            if strcmp(mode,'manual')
                sh.XLimitsCache=sh.XLimits_I;%#ok<MCSUP>
            else
                sh.XLimitsCache=[];%#ok<MCSUP>
            end
        end



        xl=xlim(sh,limits);
        yl=ylim(sh,limits);


        function ylimit=get.YLimits(sh)
            ylimit=sh.Axes.YLim;
        end

        function set.YLimits(sh,ylimit)

            try
                sh.Axes.YLim=ylimit;
                sh.YLimits_I=ylimit;
                sh.YLimitsMode='manual';
            catch e
                throwAsCaller(e);
            end
        end

        function set.YLimitsMode(sh,mode)


            sh.YLimitsMode=mode;
            if strcmp(mode,'manual')
                sh.YLimitsCache=sh.YLimits_I;%#ok<MCSUP>
            else
                sh.YLimitsCache=[];%#ok<MCSUP>
            end
        end


        function grp=get.GroupData(sh)
            grp=sh.GroupData_I;
        end

        function set.GroupData(sh,group)


            matrixMode=~sh.UsingTableForData||width(sh.SourceTable)==0;
            assert(matrixMode,message('MATLAB:graphics:scatterhistogram:TableWorkflow','GroupData'));



            validateAndSetGroupInfo(sh,group);
        end


        function set.Color(sh,clr)

            validateattributes(clr,{'numeric','char','string','cell'},...
            {'real','nonsparse','2d'},'','Color');



            sh.updateAllAxesFlags();

            if isnumeric(clr)


                validateattributes(clr,{'numeric'},{'>=',0,'<=',1},'','Color');
                if~isequal(size(clr,2),3)
                    throwAsCaller(MException(message('MATLAB:graphics:scatterhistogram:InvalidNumericColorSize')));
                end

                sh.Color_I=clr;
            else

                sh.Color_I=matlab.graphics.chart.ScatterHistogramChart...
                .colorStringToRGB(clr,sh.Axes);
            end
            sh.ColorMode='manual';
        end

        function c=get.Color(sh)
            if strcmp(sh.ColorMode,'auto')
                forceFullUpdate(sh,'all','Color');
            end
            c=sh.Color_I;
        end
    end


    methods

        function set.SourceTable(sh,tbl)
            import matlab.graphics.chart.internal.validateTableSubscript



            assert(sh.UsingTableForData,...
            message('MATLAB:graphics:scatterhistogram:MatrixWorkflow','SourceTable'));


            assert(isa(tbl,'tabular'),...
            message('MATLAB:graphics:scatterhistogram:InvalidSourceTable'));


            [xVarName,~,errX]=validateTableSubscript(...
            tbl,sh.XVariable_I,'XVariable');
            [yVarName,~,errY]=validateTableSubscript(...
            tbl,sh.YVariable_I,'YVariable');
            [gVarName,~,errG]=validateTableSubscript(...
            tbl,sh.GroupVariable_I,'GroupVariable');



            if~isempty(errX)
                throwAsCaller(errX);
            end
            if~isempty(errY)
                throwAsCaller(errY);
            end
            if~isempty(errG)
                throwAsCaller(errG);
            end

            if width(sh.SourceTable)~=0
                sh.updateAllAxesFlags();
            end


            sh.SourceTable_I=tbl;


            sh.DataDirty=true;


            sh.XVariableName=xVarName;
            sh.YVariableName=yVarName;
            sh.GroupVariableName=gVarName;


            if strcmp(sh.XLabelMode,'auto')
                sh.XLabel_I=xVarName;
            end

            if strcmp(sh.YLabelMode,'auto')
                sh.YLabel_I=yVarName;
            end

            if strcmp(sh.LegendTitleMode,'auto')
                sh.LegendHandle.TitleString=gVarName;
            end

            sh.initializeDataTipConfiguration();
        end

        function tbl=get.SourceTable(sh)
            tbl=sh.SourceTable_I;
        end


        function set.XVariable(sh,var)


            assert(sh.UsingTableForData,...
            message('MATLAB:graphics:scatterhistogram:MatrixWorkflow','XVariable'));


            import matlab.graphics.chart.internal.validateTableSubscript
            tbl=sh.SourceTable_I;
            [varName,var,err]=validateTableSubscript(tbl,var,'XVariable');
            if isempty(err)
                sh.XVariableName=varName;
            else
                throwAsCaller(err);
            end



            validateattributes(sh.SourceTable.(varName),{'numeric','categorical'},{'real','nonsparse','vector'},'','XData');
            sh.XData_I=sh.SourceTable.(varName);


            sh.PlotIndices=true(size(sh.XData_I));


            if strcmp(sh.XLabelMode,'auto')
                sh.XLabel_I=varName;
            end

            sh.UpdateX=true;sh.UpdateScatter=true;sh.UpdateLegend=true;


            sh.XVariable_I=var;
        end

        function var=get.XVariable(sh)
            var=sh.XVariable_I;
        end


        function set.YVariable(sh,var)


            assert(sh.UsingTableForData,...
            message('MATLAB:graphics:scatterhistogram:MatrixWorkflow','YVariable'));


            import matlab.graphics.chart.internal.validateTableSubscript
            tbl=sh.SourceTable_I;
            [varName,~,err]=validateTableSubscript(tbl,var,'YVariable');
            if isempty(err)
                sh.YVariableName=varName;
            else
                throwAsCaller(err);
            end



            validateattributes(sh.SourceTable.(varName),{'numeric','categorical'},{'real','nonsparse','vector'},'','YData');
            sh.YData_I=sh.SourceTable.(varName);


            if strcmp(sh.YLabelMode,'auto')
                sh.YLabel_I=varName;
            end

            sh.UpdateY=true;sh.UpdateScatter=true;sh.UpdateLegend=true;


            sh.YVariable_I=var;
        end

        function var=get.YVariable(sh)
            var=sh.YVariable_I;
        end


        function set.GroupVariable(sh,var)



            assert(sh.UsingTableForData,...
            message('MATLAB:graphics:scatterhistogram:MatrixWorkflow','GroupVariable'));


            import matlab.graphics.chart.internal.validateTableSubscript
            tbl=sh.SourceTable_I;
            [varName,~,err]=validateTableSubscript(tbl,var,'GroupVariable');
            if isempty(err)
                sh.GroupVariableName=varName;
            else
                throwAsCaller(err);
            end



            validateAndSetGroupInfo(sh,sh.SourceTable.(varName));

            if sh.AxesFilledY
                sh.updateAllAxesFlags();
            end


            if strcmp(sh.LegendTitleMode,'auto')
                sh.LegendHandle.TitleString=varName;
            end


            sh.GroupVariable_I=var;
        end

        function var=get.GroupVariable(sh)
            var=sh.GroupVariable_I;
        end
    end


    methods

        function mrk=get.MarkerStyle(sh)
            mrk=sh.MarkerStyle_I;
        end



        function set.MarkerStyle(sh,mrk)

            validateattributes(mrk,{'char','string','cell'},{'vector','nonempty'},'','MarkerStyle');
            if ischar(mrk)
                mrk=mrk(:);
            end
            mrk=string(mrk);
            sh.MarkerStyle_I=mrk;
            sh.UpdateMarkers=true;
        end


        function mrkSiz=get.MarkerSize(sh)
            mrkSiz=sh.MarkerSize_I;
        end



        function set.MarkerSize(sh,mrkSiz)

            validateattributes(mrkSiz,{'numeric'},{'vector','nonempty','real','nonzero','nonnegative'},'','MarkerSize');
            sh.MarkerSize_I=mrkSiz;
            sh.UpdateMarkers=true;
        end


        function mrkFill=get.MarkerFilled(sh)
            mrkFill=sh.MarkerFilled_I;
        end

        function set.MarkerFilled(sh,mrkFill)
            validateattributes(string(mrkFill),{'string'},{'scalar'},'','MarkerFilled');

            sh.MarkerFilled_I=mrkFill;
            sh.UpdateMarkers=true;
        end


        function mrkAlpha=get.MarkerAlpha(sh)
            mrkAlpha=sh.MarkerAlpha_I;
        end

        function set.MarkerAlpha(sh,mrkAlpha)

            validateattributes(mrkAlpha,{'numeric'},{'vector','nonempty','real','>=',0,'<=',1},'','MarkerAlpha');
            sh.MarkerAlpha_I=mrkAlpha;
            sh.UpdateMarkers=true;
        end
    end


    methods

        function dir=get.XHistogramDirection(sh)
            dir=sh.XHistogramDirection_I;
        end

        function set.XHistogramDirection(sh,direction)
            validateattributes(string(direction),{'string'},{'scalar'},'','XHistogramDirection');
            sh.XHistogramDirection_I=direction;
        end

        function dir=get.XHistogramDirection_I(sh)
            if strcmp(sh.AxesHistX.YDir,'normal')
                dir='up';
            else
                dir='down';
            end
        end

        function set.XHistogramDirection_I(sh,direction)


            if strcmp(direction,'down')
                sh.AxesHistX.YDir='reverse';%#ok<MCSUP>
                set(sh.AxesHistX,'xaxisLocation','top');%#ok<MCSUP>
            else
                sh.AxesHistX.YDir='normal';%#ok<MCSUP>
                set(sh.AxesHistX,'xaxisLocation','bottom');%#ok<MCSUP>
            end
        end

        function dir=get.YHistogramDirection(sh)
            dir=sh.YHistogramDirection_I;
        end


        function set.YHistogramDirection(sh,direction)
            validateattributes(string(direction),{'string'},{'scalar'},'','YHistogramDirection');
            sh.YHistogramDirection_I=direction;
        end

        function dir=get.YHistogramDirection_I(sh)
            if strcmp(sh.AxesHistY.YDir,'normal')
                dir='left';
            else
                dir='right';
            end
        end

        function set.YHistogramDirection_I(sh,direction)


            if strcmp(direction,'right')
                sh.AxesHistY.YDir='reverse';%#ok<MCSUP>
                set(sh.AxesHistY,'xaxisLocation','bottom');%#ok<MCSUP>
            else
                sh.AxesHistY.YDir='normal';%#ok<MCSUP>
                set(sh.AxesHistY,'xaxisLocation','top');%#ok<MCSUP>
            end
        end

        function nbins=get.NumBins(sh)
            nbins=[sh.NumBins_I{1};sh.NumBins_I{2}];
        end


        function set.NumBins(sh,nbins)

            validateattributes(nbins,{'numeric'},{'2d','real','nonzero','nonnegative','finite','integer'},'','NumBins');


            if~(isempty(nbins)||isscalar(nbins)||isequal(size(nbins,1),2))
                throwAsCaller(MException(message('MATLAB:graphics:scatterhistogram:InvalidBinSize',...
                'NumBins')));
            end

            sh.NumBinsMode='manual';

            if isempty(nbins)
                sh.XBins=[];
                sh.YBins=[];
            elseif isscalar(nbins)
                sh.XBins=nbins;
                sh.YBins=nbins;
            else
                sh.XBins=nbins(1,:);
                sh.YBins=nbins(2,:);
            end

            sh.XBinWidths=[];
            sh.YBinWidths=[];


            sh.UpdateX=true;sh.UpdateY=true;

            sh.NumBins_I={sh.XBins,sh.YBins};
        end


        function bw=get.BinWidths(sh)
            bw=[sh.BinWidths_I{1};sh.BinWidths_I{2}];
        end

        function set.BinWidths(sh,bw)

            validateattributes(bw,{'numeric'},{'2d','real','nonzero','nonnegative','finite'},'','BinWidths');


            if~(isempty(bw)||isscalar(bw)||isequal(size(bw,1),2))
                throwAsCaller(MException(message('MATLAB:graphics:scatterhistogram:InvalidBinSize',...
                'BinWidths')));
            end

            sh.BinWidthsMode='manual';

            if isempty(bw)
                sh.XBinWidths=[];
                sh.YBinWidths=[];
            elseif isscalar(bw)
                sh.XBinWidths=bw;
                sh.YBinWidths=bw;
            else
                sh.XBinWidths=bw(1,:);
                sh.YBinWidths=bw(2,:);
            end

            sh.XBins=[];
            sh.YBins=[];


            sh.UpdateX=true;sh.UpdateY=true;

            sh.BinWidths_I={sh.XBinWidths;sh.YBinWidths};
        end


        function style=get.HistogramDisplayStyle(sh)
            style=sh.HistogramDisplayStyle_I;
        end

        function set.HistogramDisplayStyle(sh,style)
            validateattributes(string(style),{'string'},{'scalar'},'','HistogramDisplayStyle');


            if strcmpi(style,'smooth')
                if~sh.StatsTbxActive
                    throwAsCaller(MException(message(...
                    'MATLAB:graphics:scatterhistogram:StatsTbxInstalled')));
                end

                if~isnumeric(sh.XData)||~isnumeric(sh.YData)
                    throwAsCaller(MException(message(...
                    'MATLAB:graphics:scatterhistogram:NonNumericSmooth')));
                end
            end

            sh.UpdateX=true;sh.UpdateY=true;
            sh.HistogramDisplayStyle_I=style;
        end


        function mrk=get.LineStyle(sh)
            mrk=sh.LineStyle_I;
        end



        function set.LineStyle(sh,ls)

            validateattributes(ls,{'char','string','cell'},{'vector','nonempty'},'','LineStyle');
            sh.LineStyleMode='manual';
            sh.LineStyle_I=string(ls);
            sh.UpdateLines=true;
        end


        function mrkSiz=get.LineWidth(sh)
            mrkSiz=sh.LineWidth_I;
        end



        function set.LineWidth(sh,lw)

            validateattributes(lw,{'numeric'},{'vector','nonempty','real','finite','nonzero','nonnegative'},...
            '','LineWidth');
            sh.LineWidth_I=lw;
            sh.Axes.LineWidth=min(lw);
            sh.AxesHistX.LineWidth=min(lw);
            sh.AxesHistY.LineWidth=min(lw);
            sh.UpdateLines=true;
        end
    end


    methods

        function loc=get.ScatterPlotLocation(sh)
            loc=sh.ScatterPlotLocation_I;
        end

        function set.ScatterPlotLocation(sh,loc)
            validateattributes(string(loc),{'string'},{'scalar'},'','ScatterPlotLocation');


            sh.ScatterPlotLocation_I=loc;



            sh.Title=sh.Title;
        end


        function ar=get.ScatterPlotProportion(sh)
            ar=sh.ScatterPlotProportion_I;
        end

        function set.ScatterPlotProportion(sh,spp)

            if~(isnumeric(spp)&&isscalar(spp)&&isreal(spp)&&spp>=0&&spp<=1)
                throwAsCaller(MException(message('MATLAB:graphics:scatterhistogram:InvalidProportion')));
            end


            sh.ScatterPlotProportion_I=spp;



            sh.Title=sh.Title;
        end
    end


    methods

        function leg=get.LegendVisible(sh)
            leg=sh.LegendVisible_I;
        end

        function set.LegendVisible(sh,leg)
            validateattributes(string(leg),{'string'},{'scalar'},'','LegendVisible');

            sh.LegendVisibleMode='manual';
            sh.LegendVisible_I=leg;

            if~isempty(sh.LegendHandle.Categories)
                sh.LegendHandle.Visible=leg;
            end
        end


        function legTitle=get.LegendTitle(sh)
            legTitle=sh.LegendTitle_I;
        end

        function set.LegendTitle(sh,legTitle)



            if isempty(legTitle)
                legTitle='';
            end

            sh.LegendTitle_I=legTitle;
            sh.LegendTitleMode='manual';
        end

        function legTitle=get.LegendTitle_I(sh)
            legTitle=sh.LegendHandle.TitleString;
        end

        function set.LegendTitle_I(sh,legTitle)

            sh.LegendHandle.TitleString=legTitle;%#ok<MCSUP>
        end
    end


    methods

        function title=get.Title(sh)
            title=sh.Title_I;
        end

        function set.Title(sh,titl)

            sh.Title_I=titl;



            if contains(lower(sh.ScatterPlotLocation),'north')
                sh.Axes.Title_IS.String_I=titl;
                sh.Axes.Title_IS.StringMode='manual';
                sh.AxesHistX.Title_IS.String_I='';
            else
                sh.AxesHistX.Title_IS.String_I=titl;
                sh.AxesHistX.Title_IS.StringMode='manual';
                sh.Axes.Title_IS.String_I='';
            end
            sh.MarkDirty('all');
        end


        function xlabel=get.XLabel(sh)
            xlabel=sh.XLabel_I;
        end

        function set.XLabel(sh,xlabel)
            sh.XLabel_I=xlabel;
            sh.XLabelMode='manual';
        end


        function ylabel=get.YLabel(sh)
            ylabel=sh.YLabel_I;
        end

        function set.YLabel(sh,ylabel)
            sh.YLabel_I=ylabel;
            sh.YLabelMode='manual';
        end


        function set.FontName(sh,fontName)

            if isvalid(sh.Axes)%#ok<MCSUP>
                sh.Axes.FontName=fontName;%#ok<MCSUP>
                sh.AxesHistX.FontName=fontName;%#ok<MCSUP>
                sh.AxesHistY.FontName=fontName;%#ok<MCSUP>
                sh.LegendHandle.FontName=fontName;%#ok<MCSUP>


                sh.FontName=fontName;
            end
        end


        function set.FontSize_I(sh,fontSize)

            if isvalid(sh.Axes)%#ok<MCSUP>
                sh.LegendHandle.FontSize=fontSize;%#ok<MCSUP>
                sh.Axes.FontSize=fontSize;%#ok<MCSUP>
                sh.AxesHistX.FontSize=fontSize;%#ok<MCSUP>
                sh.AxesHistY.FontSize=fontSize;%#ok<MCSUP>


                sh.FontSize_I=fontSize;
            end
        end

        function set.FontSize(sh,fontSize)
            sh.FontSizeMode='manual';
            sh.FontSize_I=fontSize;


            if isvalid(sh.Axes)%#ok<MCSUP>
                sh.AxesHistX.Position([1,3])=sh.Axes.Position([1,3]);%#ok<MCSUP>
                sh.AxesHistY.Position([2,4])=sh.Axes.Position([2,4]);%#ok<MCSUP>
            end
        end

        function val=get.FontSize(sh)
            val=sh.FontSize_I;
        end
    end


    methods(Hidden)

        function plotScatter(sh)

            if isempty(sh.XData_I)||isempty(sh.YData_I)
                return;
            end




            ax=sh.Axes;

            sh.initializeDataTipConfiguration();


            sh.ScatterAxesChildren=...
            matlab.graphics.chart.ScatterHistogramChart.scatterplot(ax,...
            sh.XData_I,sh.YData_I,sh.GroupIndex,sh.UniqueGroups,...
            sh.Color_I,sh.MarkerStyle_I,...
            sh.MarkerSize_I,sh.XLabel_I,sh.YLabel_I,sh.GroupVariable_I,...
            sh.MarkerFilled_I,sh.MarkerAlpha_I,sh);


            sh.AxesFilled=true;sh.UpdateScatter=false;

            if sh.UpdateSavedLimits&&~isempty(sh.XLimits_I)
                ax.XLim=sh.XLimits_I;
            else

                if isnumeric(sh.XData_I)&&isnumeric(ax.XLim_I)
                    if strcmp(sh.XLimitsMode,'manual')
                        ax.XLim=sh.XLimits_I;
                    else
                        minx=min(sh.XData_I);
                        maxx=max(sh.XData_I);
                        if minx~=maxx&&~(isnan(minx)||isnan(maxx))
                            ax.XLim=[minx,maxx];
                        end
                    end
                elseif iscategorical(sh.XData_I)
                    c=categories(sh.XData_I);
                    if~isempty(c)
                        ax.XLim=[c(1),c(end)];
                    end
                end
            end

            if sh.UpdateSavedLimits&&~isempty(sh.YLimits_I)
                ax.YLim=sh.YLimits_I;
            else
                if isnumeric(sh.YData_I)&&isnumeric(ax.YLim_I)
                    if strcmp(sh.YLimitsMode,'manual')
                        ax.YLim=sh.YLimits_I;
                    else
                        miny=min(sh.YData_I);
                        maxy=max(sh.YData_I);
                        if miny~=maxy&&~(isnan(miny)||isnan(maxy))
                            ax.YLim=[miny,maxy];
                        end
                    end
                elseif iscategorical(sh.YData_I)
                    c=categories(sh.YData_I);
                    if~isempty(c)
                        ax.YLim=[c(1),c(end)];
                    end
                end
            end

            sh.UpdateSavedLimits=false;



            if isempty(sh.ListenerHistX)
                xl=findprop(sh.Axes,'XLim');
                sh.ListenerHistX=addlistener(ax,xl,'PostSet',...
                @(s,e)matlab.graphics.chart.ScatterHistogramChart.panZoomCallback(s,e,sh));

                yl=findprop(sh.Axes,'YLim');
                sh.ListenerHistY=addlistener(ax,yl,'PostSet',...
                @(s,e)matlab.graphics.chart.ScatterHistogramChart.panZoomCallback(s,e,sh));
            end
        end


        function plotHistogramX(sh)

            if isempty(sh.XData_I)
                return;
            end
            ax=sh.AxesHistX;



            if strcmp(sh.HistogramDisplayStyle,'smooth')
                if~isnumeric(sh.XData_I)
                    throwAsCaller(MException(message(...
                    'MATLAB:graphics:scatterhistogram:NonNumericSmooth')));
                end
                [sh.BinWidths_I{1},sh.MaxYValue(1),sh.XHistAxesChildren]=...
                matlab.graphics.chart.ScatterHistogramChart.plotGroupedKSDensity...
                (ax,sh.XData_I,sh.GroupIndex,sh.UniqueGroups,...
                sh.Color_I,sh.LineWidth_I,sh.LineStyle_I,sh.XBinWidths);
            else
                [sh.NumBins_I{1},sh.BinWidths_I{1},sh.MaxYValue(1),sh.XHistAxesChildren]=...
                matlab.graphics.chart.ScatterHistogramChart.plotGroupedHist...
                (ax,sh.XData_I,sh.GroupIndex,sh.UniqueGroups,sh.XBins,...
                sh.Color_I,sh.LineStyle_I,sh.LineWidth_I,sh.XBinWidths,...
                'DisplayStyle',sh.HistogramDisplayStyle,'Norm','pdf');
            end

            sh.AxesFilledX=true;sh.UpdateX=false;
        end


        function plotHistogramY(sh)

            if isempty(sh.YData_I)
                return;
            end
            ax=sh.AxesHistY;



            if strcmp(sh.HistogramDisplayStyle,'smooth')
                if~isnumeric(sh.YData_I)
                    throwAsCaller(MException(message(...
                    'MATLAB:graphics:scatterhistogram:NonNumericSmooth')));
                end
                [sh.BinWidths_I{2},sh.MaxYValue(2),sh.YHistAxesChildren]=...
                matlab.graphics.chart.ScatterHistogramChart.plotGroupedKSDensity...
                (ax,sh.YData_I,sh.GroupIndex,sh.UniqueGroups,...
                sh.Color_I,sh.LineWidth_I,sh.LineStyle_I,sh.YBinWidths);
            else
                [sh.NumBins_I{2},sh.BinWidths_I{2},sh.MaxYValue(2),sh.YHistAxesChildren]=...
                matlab.graphics.chart.ScatterHistogramChart.plotGroupedHist...
                (ax,sh.YData_I,sh.GroupIndex,sh.UniqueGroups,sh.YBins,...
                sh.Color_I,sh.LineStyle_I,sh.LineWidth_I,sh.YBinWidths,...
                'DisplayStyle',sh.HistogramDisplayStyle,'Norm','pdf');
            end


            view(ax,270,90);

            sh.AxesFilledY=true;sh.UpdateY=false;
        end


        function plotLegend(sh)



            if isempty(sh.GroupData_I)
                sh.LegendVisible='off';
                sh.LegendVisibleMode='auto';
            end
            axLegend=sh.LegendHandle;


            grp=unique(sh.GroupIndex,'stable');
            if~isempty(grp)
                axLegend.ColorList=sh.Color_I(grp,:);
            end




            axLegend.MarkerFilled=sh.MarkerFilled;
            axLegend.MarkerList=sh.MarkerStyle;
            axLegend.MarkerAlpha=sh.MarkerAlpha;




            cats=sh.UniqueGroups;
            if~isempty(grp)
                cats=cats(grp);
            end
            axLegend.Legend.PositionMode='auto';
            axLegend.Categories=cats;
            axLegend.categoricalLegend();

            sh.UpdateLegend=false;
        end
    end


    methods
        function set.DataStorage(sh,data)




            sh.XData_I=data.XData;%#ok<MCSUP>
            sh.YData_I=data.YData;%#ok<MCSUP>
            sh.Color=data.Color;%#ok<MCSUP>


            sh.XLimits_I=data.XLimits;%#ok<MCSUP>
            sh.YLimits_I=data.YLimits;%#ok<MCSUP>
            sh.UpdateSavedLimits=true;%#ok<MCSUP>


            sh.ColorMode=data.ColorMode;%#ok<MCSUP>

            sh.UsingTableForData=data.UsingTableForData;%#ok<MCSUP>
        end

        function data=get.DataStorage(sh)




            data.XData=sh.XData_I;
            data.YData=sh.YData_I;
            data.Color=sh.Color_I;


            data.XLimits=sh.XLimits;
            data.YLimits=sh.YLimits;


            data.ColorMode=sh.ColorMode;


            [v,d]=version;
            data.Version=v;
            data.Date=d;

            data.UsingTableForData=sh.UsingTableForData;
        end



        function set.PositionStorage(sh,data)








            if~isfield(data,'PositionConstraint')&&isfield(data,'ActivePositionProperty')
                if strcmpi(data.ActivePositionProperty,'outerposition')
                    data.PositionConstraint='outerposition';
                else
                    data.PositionConstraint='innerposition';
                end
            end

            sh.Units=data.Units;

            sh.Axes.PositionConstraint=data.PositionConstraint;%#ok<MCSUP>
            if strcmpi(data.PositionConstraint,'outerposition')
                sh.Axes.OuterPosition=data.OuterPosition;%#ok<MCSUP>
            else
                sh.Axes.InnerPosition=data.InnerPosition;%#ok<MCSUP>
            end
        end

        function data=get.PositionStorage(sh)



            data.Units=sh.Axes.Units;
            data.ActivePositionProperty=sh.Axes.ActivePositionProperty;
            data.PositionConstraint=sh.Axes.PositionConstraint;
            data.InnerPosition=sh.Axes.Position;
            data.OuterPosition=sh.Axes.OuterPosition;
        end
    end


    methods(Hidden)
        function scaleForPrinting(sh,flag,scale)





            switch lower(flag)
            case 'modify'

                settings.LineWidth=sh.LineWidth;
                settings.MarkerSize=sh.MarkerSize;
                settings.Units=sh.Units;
                if strcmpi(sh.PositionConstraint,'outerposition')
                    settings.OuterPosition=sh.OuterPosition;
                else
                    settings.InnerPosition=sh.InnerPosition;
                end
                settings.LooseInsetCache=sh.LooseInsetCache;
                sh.PrintSettingsCache=settings;



                scopeGuard=onCleanup(@()sh.enableSubplotListeners());
                sh.disableSubplotListeners();
                sh.Units='normalized';
                delete(scopeGuard);


                if scale~=1
                    sh.MarkerSize=settings.MarkerSize./scale;
                end
            case 'revert'
                settings=sh.PrintSettingsCache;

                if~isempty(settings)


                    sh.LineWidth=settings.LineWidth;
                    sh.MarkerSize=settings.MarkerSize;



                    scopeGuard=onCleanup(@()sh.enableSubplotListeners());
                    sh.disableSubplotListeners();
                    sh.Units=settings.Units;
                    delete(scopeGuard);

                    scopeGuard=onCleanup(@()sh.enableSubplotListeners());
                    sh.disableSubplotListeners();
                    if strcmpi(sh.PositionConstraint,'outerposition')
                        sh.OuterPosition=settings.OuterPosition;
                    else
                        sh.InnerPosition=settings.InnerPosition;
                    end
                    delete(scopeGuard);
                    sh.LooseInsetCache=settings.LooseInsetCache;
                end


                sh.PrintSettingsCache=[];
            end
        end

        function disableSubplotListeners(sh)
            parent=sh.Parent;
            if isscalar(parent)&&isvalid(parent)
                slm=getappdata(parent,'SubplotListenersManager');
                if~isempty(slm)
                    disable(slm);
                end
            end
        end

        function enableSubplotListeners(sh)
            parent=sh.Parent;
            if isscalar(parent)&&isvalid(parent)
                slm=getappdata(parent,'SubplotListenersManager');
                if~isempty(slm)
                    enable(slm);
                end
            end
        end
    end


    methods(Hidden)
        doUpdate(sh,updateState)
        doLayout(sh,updateState)

        function updateData(sh)




            if sh.UsingTableForData&&sh.DataDirty


                sh.XData_I=sh.SourceTable.(sh.XVariableName);


                if~isempty(sh.YVariableName)
                    sh.YData_I=sh.SourceTable.(sh.YVariableName);
                end

                if~isempty(sh.GroupVariableName)
                    sh.DataDirty=false;

                    validateAndSetGroupInfo(sh,sh.SourceTable.(sh.GroupVariableName));
                end


                sh.DataDirty=false;
            end
        end

        function updateDataInLimits(sh)



            x=sh.XData_I;
            y=sh.YData_I;
            ax=sh.Axes;



            if iscategorical(x)
                lims=ax.XLim_I;
                cats=ax.XAxis.Categories;
                [~,loc]=ismember(lims,cats);
                cats=cats(loc(1):loc(2));
                xPoints=ismember(x,cats);
            else
                xPoints=x>=ax.XLim_I(1)&x<=ax.XLim_I(2);
            end

            if iscategorical(y)
                lims=ax.YLim_I;
                cats=ax.YAxis.Categories;
                [~,loc]=ismember(lims,cats);
                cats=cats(loc(1):loc(2));
                yPoints=ismember(y,cats);
            else
                yPoints=y>=ax.YLim_I(1)&y<=ax.YLim_I(2);
            end

            sh.PlotIndices=xPoints&yPoints;
        end

        function updateAllAxesFlags(sh)

            sh.UpdateX=true;
            sh.UpdateY=true;
            sh.UpdateScatter=true;
            sh.UpdateLegend=true;
        end

        function validateAndSetGroupInfo(sh,group)

            validateattributes(group,{'numeric','categorical','logical',...
            'char','string','cell'},{'real','nonsparse','2d'},'','GroupData');



            if~isempty(group)&&~(iscategorical(group)&&isempty(categories(group)))

                if iscell(group)&&~iscellstr(group)%#ok<ISCLSTR>
                    throwAsCaller(MException(message('MATLAB:graphics:scatterhistogram:InvalidGroupDataCell')));
                end


                grp=group;
                if ischar(grp)
                    grp=string(grp);
                end



                try
                    grp=categorical(grp);
                catch e
                    throwAsCaller(MException(message('MATLAB:graphics:scatterhistogram:InvalidCategoryNames')));
                end




                sh.GroupIndex=findgroups(grp);
                sh.UniqueGroups=string(unique(grp,'stable'));
                sh.GroupIndex=sh.GroupIndex(:);
                sh.UniqueGroups=sh.UniqueGroups(:);


                ind=isnan(sh.GroupIndex);
                if any(ind)
                    nanVal=max(sh.GroupIndex)+1;
                    sh.GroupIndex(ind)=nanVal;



                    sh.UniqueGroups(ismissing(sh.UniqueGroups))="<undefined>";
                    sh.UniqueGroups=unique(sh.UniqueGroups,'stable');
                end



                sh.NumGroups=numel(sh.UniqueGroups);



                [~,~,sh.GroupIndex]=unique(sh.GroupIndex,'stable');

                sh.GroupData_I=group;
            else
                sh.NumGroups=1;
                sh.GroupIndex=[];
                sh.UniqueGroups=[];
                sh.GroupData_I=[];
            end


            sh.updateAllAxesFlags();
        end
    end

    methods(Access='protected',Hidden)

        function groups=getPropertyGroups(sh)
            if sh.UsingTableForData
                groups=matlab.mixin.util.PropertyGroup(...
                {'SourceTable','XVariable','YVariable','GroupVariable'});
            else
                groups=matlab.mixin.util.PropertyGroup(...
                {'XData','YData','GroupData'});
            end
        end


        function postSetUnits(sh)
            units=sh.Axes.Units_I;
            sh.AxesHistX.Units=units;
            sh.AxesHistY.Units=units;
            sh.LegendHandle.Legend.Units=units;
        end

        function setColorOrderInternal(sh,listOfColors)
            sh.ColorOrderInternalMode='manual';
            sh.ColorMode='auto';
            sh.updateAllAxesFlags();
            sh.Color_I=listOfColors;
        end

    end


    methods(Static,Hidden)

        hh=scatterplot(ax,x,y,g,gn,clr,sym,siz,xnam,ynam,grpname,filled,alpha,sh)
        clrRGB=colorStringToRGB(clrString,ax)
        varargout=cycleLineProperties(nG,varargin)
        [nBins,bw,maxv,hh]=plotGroupedHist(ax,x,grpID,gname,nbins,clr,ls,lw,bw,varargin)
        [bw,maxv,hh]=plotGroupedKSDensity(ax,x,grpID,gname,clr,lw,ls,ww)


        function panZoomCallback(~,~,sh)





            if sh.UpdateLimits

                sh.updateDataInLimits();

                maxy=zeros(1,sh.NumGroups);
                if strcmp(sh.HistogramDisplayStyle,'smooth')



                    x=sh.XData_I(sh.PlotIndices);
                    y=sh.YData_I(sh.PlotIndices);
                    grpID=[];
                    if~isempty(sh.GroupIndex)
                        grpID=sh.GroupIndex(sh.PlotIndices);
                    end


                    [x,grpIDx,~,xrange]=matlab.graphics.chart...
                    .ScatterHistogramChart.computeDensityRange(x,grpID);
                    [y,grpIDy,~,yrange]=matlab.graphics.chart...
                    .ScatterHistogramChart.computeDensityRange(y,grpID);
                    bw=zeros(1,sh.NumGroups);

                    Xlines=sh.XHistAxesChildren;
                    Ylines=sh.YHistAxesChildren;

                    for idx=1:sh.NumGroups

                        if~(isempty(grpIDx)||isempty(x)||isempty(xrange))
                            xg=x(grpIDx==idx);
                            [px,sh.BinWidths_I{1}]=matlab.graphics.chart.ScatterHistogramChart...
                            .computeKernelPDF(xg,xrange,sh.XBinWidths,bw,idx);
                        else
                            px=nan;
                            xrange=nan;
                        end

                        if~(isempty(grpIDy)||isempty(y)||isempty(yrange))
                            yg=y(grpIDy==idx);
                            [py,sh.BinWidths_I{2}]=matlab.graphics.chart.ScatterHistogramChart...
                            .computeKernelPDF(yg,yrange,sh.YBinWidths,bw,idx);
                        else
                            py=nan;
                            yrange=nan;
                        end


                        Xlines(idx).XData=xrange;
                        Xlines(idx).YData=px;
                        Ylines(idx).XData=yrange;
                        Ylines(idx).YData=py;

                        maxy(idx)=max([px(:);py(:)]);
                    end
                else


                    for idx=1:sh.NumGroups


                        if sh.NumGroups>1
                            plotPts=sh.GroupIndex==idx;
                            plotPts=plotPts&sh.PlotIndices;
                        else
                            plotPts=sh.PlotIndices;
                        end


                        sh.XHistAxesChildren(idx).Data=sh.XData_I(plotPts);
                        sh.YHistAxesChildren(idx).Data=sh.YData_I(plotPts);

                        maxy(idx)=max([sh.XHistAxesChildren(idx).Values(:);sh.YHistAxesChildren(idx).Values(:)]);
                    end
                end



                if sh.UpdateLimsInPan
                    sh.AxesHistX.XLim=sh.Axes.XLim_I;
                    sh.AxesHistY.XLim=sh.Axes.YLim_I;
                end
            end
        end





        function pos=getPositionInPoints(ax,updateState,posType)

            if nargin<3
                posType='Position';
            end


            layout=ax.GetLayoutInformation();
            posPoints=updateState.convertUnits('canvas','points','pixels',layout.(posType));


            pos=updateState.convertUnits('canvas',ax.Units_I,'points',posPoints);
        end

        function pos=getDecoratedPositionInUnits(ax,posType)


            if nargin<2
                posType='DecoratedPlotBox';
            end


            axLayout=ax.GetLayoutInformation;
            vp=ax.Camera.Viewport;
            pos=matlab.graphics.chart.Chart.convertUnits...
            (vp,ax.Units,'pixels',axLayout.(posType));
        end

        function tightInsetPoints=getTightInset(ax,updateState)
            layout=ax.GetLayoutInformation();


            posPoints=updateState.convertUnits('canvas',ax.Units,'pixels',layout.Position);

            decPBPoints=updateState.convertUnits('canvas',ax.Units,'pixels',layout.DecoratedPlotBox);

            tightInsetPoints=[0,0,0,0];
            tightInsetPoints(1:2)=[...
            posPoints(1)-decPBPoints(1),...
            posPoints(2)-decPBPoints(2)];
            tightInsetPoints(3:4)=[...
            decPBPoints(3)-posPoints(3)-tightInsetPoints(1),...
            decPBPoints(4)-posPoints(4)-tightInsetPoints(2)];

            tightInsetPoints(tightInsetPoints<0)=0;
        end

        function[x,grpID,grp,xrange]=computeDensityRange(x,grpID)
            if isempty(grpID)
                grpID=ones(size(x));
            end
            grp=unique(grpID);


            xrange=[];
            wasNaN=isnan(x);
            x(wasNaN)=[];
            grpID(wasNaN)=[];
            if isempty(x)
                return;
            end


            cxmax=max(x);
            cxmin=min(x);
            if cxmax==cxmin
                [~,xrange]=ksdensity(x);
            else
                dx=0.1*range(x);
                xLim=[cxmin-dx,cxmax+dx];
                xrange=xLim(1):0.01*dx:xLim(2);
            end
        end

        function[px,bw]=computeKernelPDF(xg,xrange,ww,bw,idx)
            if~isempty(xg)
                if isempty(ww)
                    [px,~,bw(idx)]=ksdensity(xg,xrange);
                else
                    [px,~,bw(idx)]=ksdensity(xg,xrange,'Width',ww(idx));
                end
            else
                px=nan(1,size(xrange,2));
            end
        end
    end


    methods(Hidden)
        function ignore=mcodeIgnoreHandle(~,~)

            ignore=false;
        end
        mcodeConstructor(sh,code);
    end


    methods(Hidden)

        function initializePalette(obj,zoomInCallback,zoomOutCallback,fitToDataCallback)

            [tb,btn]=axtoolbar(obj.Axes,{'restoreview'});

            if~isempty(tb)
                tb.HandleVisibility='off';

                btn.Visible='on';
                btn.HandleVisibility='off';
                btn.ButtonPushedFcn=fitToDataCallback;

                iconsFolder=toolboxdir(['matlab',filesep,'graphics',...
                filesep,'+matlab',filesep,'+graphics',filesep,...
                '+controls',filesep,'icons']);

                pbZoomOut=axtoolbarbtn(tb,'push','HandleVisibility','off');
                pbZoomOut.ButtonPushedFcn=zoomOutCallback;
                pbZoomOut.Icon=fullfile(iconsFolder,'zoom_out_action.png');
                pbZoomOut.Tooltip=getString(message('MATLAB:graphics:scatterhistogram:ZoomOut'));
                pbZoomOut.Tag='zoom-out';

                pbZoomin=axtoolbarbtn(tb,'push','HandleVisibility','off');
                pbZoomin.ButtonPushedFcn=zoomInCallback;
                pbZoomin.Icon=fullfile(iconsFolder,'zoom_in_action.png');
                pbZoomin.Tooltip=getString(message('MATLAB:graphics:scatterhistogram:ZoomIn'));
                pbZoomin.Tag='zoom-in';
            end
        end

        function setupMouseInteraction(sh)

            ax=sh.Axes;
            strategy=matlab.graphics.interaction.uiaxes...
            .AxesInteractionStrategy(ax);
            strategy.Chart=sh;
            fig=ancestor(sh,'figure');

            pan=matlab.graphics.interaction.uiaxes.Pan(ax,fig,...
            'WindowMousePress','WindowMouseMotion','WindowMouseRelease');
            pan.strategy=strategy;
            pan.enable()

            sz=matlab.graphics.interaction.uiaxes.ScrollZoom(ax,fig,...
            'WindowScrollWheel','WindowMouseMotion');
            sz.strategy=strategy;
            sz.zoom_factor=2^(1/sh.StepsPerZoomLevelScrollWheel);
            sz.enable()

            sh.PanInteraction=pan;
            sh.ScrollZoomInteraction=sz;
        end

        function initializeDatatip(sh)





            hCursor=matlab.graphics.shape.internal.PointDataCursor();
            hCursor.Interpolate='off';
            hTip=matlab.graphics.shape.internal.PointDataTip(hCursor,...
            'Draggable','off','Visible','off','HandleVisibility','off',...
            'DataTipStyle',matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerOnly);
            hLocator=hTip.LocatorHandle;
            hLocator.PickableParts='none';
            hLocator.HitTest='off';



            hTip.TipHandle.Text.PickableParts='none';
            hTip.TipHandle.Rectangle.PickableParts='none';
            scribePeer=hTip.TipHandle.ScribeHost.getScribePeer();
            scribePeer.PickableParts='none';
            hLocator.setMarkerPickableParts('none');

            sh.PointDatatip=hTip;


            hLinger=matlab.graphics.interaction.actions.Linger(...
            [sh.Axes,sh.AxesHistX,sh.AxesHistY]);
            hLinger.IncludeChildren=true;
            hLinger.LingerResetMethod='exitaxes';
            hLinger.LingerTime=1;
            hLinger.enable();
            addlistener(hLinger,'EnterObject',@(~,e)sh.updateDatatip(e));
            addlistener(hLinger,'ExitObject',@(~,e)sh.updateDatatip(e));
            addlistener(hLinger,'LingerOverObject',@(~,e)sh.lingerFcn(e));
            addlistener(hLinger,'LingerReset',@(~,e)sh.updateDatatip(e));
            sh.Linger=hLinger;
        end

        function updateDatatip(sh,eventobj)

            hTip=sh.PointDatatip;


            if isempty(hTip)||~isvalid(hTip)
                initializeDatatip(sh);
                hTip=sh.PointDatatip;
            end

            if eventobj.EventName=="EnterObject"






                dataSource=eventobj.HitObject;
                if~(isa(dataSource,'matlab.graphics.chart.primitive.Scatter')...
                    ||isa(dataSource,'matlab.graphics.chart.primitive.Line')...
                    ||isa(dataSource,'matlab.graphics.chart.primitive.categorical.Histogram')...
                    ||isa(dataSource,'matlab.graphics.chart.primitive.Histogram'))...
                    ||~isvalid(dataSource)
                    return;
                end
                hTip.DataSource=dataSource;





                hCursor=hTip.Cursor;
                dataIndex=hCursor.DataIndex;
                newIndex=eventobj.NearestPoint;
                movePoint=~isequal(dataIndex,newIndex);
                if movePoint
                    hCursor.DataIndex=newIndex;
                end
                toggleDatatipLocator(hTip,'on');
            elseif eventobj.EventName=="LingerReset"



                hTip.DataTipStyle=matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerOnly;
                toggleDatatipLocator(hTip,'off');
            else


                if isvalid(hTip)
                    toggleDatatipLocator(hTip,'off');
                end
            end
        end

        function lingerFcn(sh,~)
            hTip=sh.PointDatatip;

            if isvalid(hTip)
                if isempty(hTip.String)
                    toggleDatatipLocator(hTip,'off');
                else
                    showTip=hTip.Visible=="on";
                    if showTip
                        hTip.DataTipStyle=matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerAndTip;
                    end
                end
            end
        end


        function zoomIn(sh)


            ax=sh.Axes;
            xlim=ruler2num(ax.XLim,ax.XAxis);
            ylim=ruler2num(ax.YLim,ax.YAxis);
            ctr=[mean(xlim),mean(ylim)];
            wd=(xlim(2)-xlim(1))/sh.StepsPerZoomLevelKeystrokes;
            ht=(ylim(2)-ylim(1))/sh.StepsPerZoomLevelKeystrokes;



            sh.UpdateLimits=false;
            ax.XLim=num2ruler([ctr(1)-wd/2,ctr(1)+wd/2],ax.XAxis);
            sh.UpdateLimits=true;
            ax.YLim=num2ruler([ctr(2)-ht/2,ctr(2)+ht/2],ax.YAxis);
        end

        function zoomOut(sh)


            ax=sh.Axes;
            xlim=ruler2num(ax.XLim,ax.XAxis);
            ylim=ruler2num(ax.YLim,ax.YAxis);
            ctr=[mean(xlim),mean(ylim)];
            wd=(xlim(2)-xlim(1))*sh.StepsPerZoomLevelKeystrokes;
            ht=(ylim(2)-ylim(1))*sh.StepsPerZoomLevelKeystrokes;


            sh.UpdateLimits=false;
            ax.XLim=num2ruler([ctr(1)-wd/2,ctr(1)+wd/2],ax.XAxis);
            sh.UpdateLimits=true;
            ax.YLim=num2ruler([ctr(2)-ht/2,ctr(2)+ht/2],ax.YAxis);
        end

        function fitToData(sh)




            ax=sh.Axes;
            if isempty(sh.XLimitsCache)
                if isnumeric(sh.XData_I)
                    minx=min(sh.XData_I);
                    maxx=max(sh.XData_I);
                    if isnan(minx)||isnan(maxx)
                        ax.XLim=[0,1];
                    elseif minx==maxx
                        ax.XLim=[minx-1,minx+1];
                    else
                        ax.XLim=[minx,maxx];
                    end
                else
                    ax.XLim=ax.XAxis.Categories([1,end]);
                end
            else
                ax.XLim=sh.XLimitsCache;
            end

            if isempty(sh.YLimitsCache)
                if isnumeric(sh.YData_I)
                    miny=min(sh.YData_I);
                    maxy=max(sh.YData_I);
                    if isnan(miny)||isnan(maxy)
                        ax.YLim=[0,1];
                    elseif miny==maxy
                        ax.YLim=[miny-1,miny+1];
                    else
                        ax.YLim=[miny,maxy];
                    end
                else
                    ax.YLim=ax.YAxis.Categories([1,end]);
                end
            else
                ax.YLim=sh.YLimitsCache;
            end
        end

        function markedCleanCallback(sh)

            sh.AxesHistX.Position([1,3])=sh.Axes.Position([1,3]);
            sh.AxesHistY.Position([2,4])=sh.Axes.Position([2,4]);


            sh.AxesHistX.XLim=sh.Axes.XLim;
            sh.AxesHistY.XLim=sh.Axes.YLim;




            if isempty(sh.PanInteraction)||~isequal(sh.PanInteraction.source,sh.Parent)
                sh.enableInteractions();







                sh.UpdateLimits=true;
                sh.UpdateLimsInPan=false;
                matlab.graphics.chart.ScatterHistogramChart.panZoomCallback(1,1,sh);
                sh.UpdateLimsInPan=true;
            end
        end
    end


    methods(Hidden,Access={?tScatterHistogramChart,?tscatterhistogram,...
        ?tscatterhistogramInteractions})
        function obj=getInternalChildren(sh)
            obj.Axes=sh.Axes;
            obj.AxesHistX=sh.AxesHistX;
            obj.AxesHistY=sh.AxesHistY;
            obj.Legend=sh.LegendHandle.Legend;
        end
    end


    methods(Hidden=true,Access={?ChartUnitTestFriend,...
        ?matlab.graphics.chart.Chart,...
        ?matlab.internal.editor.figure.ChartAccessor,...
        ?matlab.plottools.service.accessor.ChartAccessor})

        function hTitle=getTitleHandle(sh)


            if contains(lower(sh.ScatterPlotLocation),'north')
                hTitle=sh.Axes.Title_IS;
            else
                hTitle=sh.AxesHistX.Title_IS;
            end
        end


        function hXLabel=getXlabelHandle(sh)



            if contains(lower(sh.ScatterPlotLocation),'south')
                hXLabel=sh.Axes.XAxis.Label_IS;
            else
                hXLabel=sh.AxesHistX.XAxis.Label_IS;
            end
        end


        function hYLabel=getYlabelHandle(sh)



            if contains(lower(sh.ScatterPlotLocation),'west')
                hYLabel=sh.Axes.YAxis.Label_IS;
            else

                hYLabel=sh.AxesHistY.XAxis.Label_IS;
            end
        end
    end
end

function toggleDatatipLocator(hTip,onoff)
    hTip.Visible=onoff;
    hLocator=hTip.LocatorHandle;
    hLocator.ScribeMarkerHandleEdge.Visible=onoff;
    hLocator.ScribeMarkerHandleFace.Visible=onoff;
end
