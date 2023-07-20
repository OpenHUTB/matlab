classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Sealed)HeatmapChart<...
    matlab.graphics.chart.internal.SubplotPositionableChartWithAxes&...
    matlab.graphics.datatip.internal.mixin.AggregatedDataTipMixin








    properties(Transient,Hidden,SetAccess=protected,NonCopyable)
        Type='heatmap'
    end

    properties(Dependent,Resettable=false)
        Title matlab.internal.datatype.matlab.graphics.datatype.NumericOrString=''
        XLabel matlab.internal.datatype.matlab.graphics.datatype.NumericOrString=''
        YLabel matlab.internal.datatype.matlab.graphics.datatype.NumericOrString=''
        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive=get(groot,'FactoryAxesFontSize')

        SourceTable=table.empty()
        XVariable=''
        YVariable=''
        ColorVariable=''
        ColorMethod matlab.internal.datatype.matlab.graphics.chart.datatype.HeatmapColorMethodType='none'

        XData=string.empty(0,1)
        YData=string.empty(0,1)
        ColorData matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix=[]

        XDisplayData(:,1)string=string.empty(0,1)
        YDisplayData(:,1)string=string.empty(0,1)

        XDisplayLabels(:,1)string=string.empty(0,1)
        YDisplayLabels(:,1)string=string.empty(0,1)

        XLimits=string([NaN,NaN])
        YLimits=string([NaN,NaN])
        ColorLimits matlab.internal.datatype.matlab.graphics.datatype.Limits=[0,1]
    end

    properties(Dependent,SetAccess=private)
        ColorDisplayData matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix
    end

    properties(AbortSet)
        FontColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0.15,0.15,0.15]

        CellLabelFormat matlab.internal.datatype.matlab.graphics.datatype.PrintfFormat='%0.4g'
        CellLabelColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto'
        MissingDataColor matlab.internal.datatype.matlab.graphics.datatype.RGBColor=[0.15,0.15,0.15]

        GridVisible matlab.internal.datatype.matlab.graphics.datatype.on_off='on'
    end

    properties(AffectsObject,AbortSet)
        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName=get(groot,'FactoryAxesFontName')
        Colormap matlab.internal.datatype.matlab.graphics.datatype.ColorMap=matlab.graphics.chart.internal.heatmap.blueColormap(size(get(groot,'FactoryFigureColormap'),1))
        ColorScaling matlab.internal.datatype.matlab.graphics.chart.datatype.HeatmapColorScalingType='scaled'
        MissingDataLabel matlab.internal.datatype.matlab.graphics.datatype.NumericOrString='NaN'

        ColorbarVisible matlab.internal.datatype.matlab.graphics.datatype.on_off='on'
    end

    properties(AffectsObject,Transient,NonCopyable,Hidden,Access={...
        ?ChartUnitTestFriend,...
        ?matlab.graphics.chart.internal.heatmap.Controller,...
        ?matlab.graphics.chart.internal.heatmap.DragToRearrange})
        HideXDisplayLabels(1,:)cell={}
        HideYDisplayLabels(1,:)cell={}
    end

    properties(AffectsObject,Transient,NonCopyable,Hidden,Access={...
        ?ChartUnitTestFriend,...
        ?matlab.graphics.chart.internal.heatmap.InteractionStrategy})
        UpdateDataSpaceLimits(1,1)logical=true
    end

    properties(Hidden,AbortSet,Access=?ChartUnitTestFriend)
        TitleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        XLabelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        YLabelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'

        ColorMethodMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Transient,NonCopyable,Hidden,AbortSet,Access={...
        ?ChartUnitTestFriend,...
        ?matlab.graphics.chart.internal.heatmap.Controller})

        XLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        YLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        ColorLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'

        XDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        YDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'



        ColorDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'

        XDisplayDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        YDisplayDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(AffectsObject,Hidden,AbortSet,Access=?ChartUnitTestFriend)
        Title_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString=''
        XLabel_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString=''
        YLabel_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString=''
        FontSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=get(groot,'FactoryAxesFontSize')
    end

    properties(AffectsObject,Hidden,Access=?ChartUnitTestFriend)
        SourceTable_I tabular=table.empty()
        XVariable_I=''
        YVariable_I=''
        ColorVariable_I=''
        ColorMethod_I matlab.internal.datatype.matlab.graphics.chart.datatype.HeatmapColorMethodType='none'
    end

    properties(Transient,NonCopyable,AffectsObject,Hidden,...
        Access=?ChartUnitTestFriend)

        XData_I string=string.empty(0,1)
        YData_I string=string.empty(0,1)
        ColorData_I double=[]



        XDisplay_I string=string.empty(0,2)
        YDisplay_I string=string.empty(0,2)

        XLimits_I string=string([NaN,NaN])
        YLimits_I string=string([NaN,NaN])
        ColorLimits_I matlab.internal.datatype.matlab.graphics.datatype.Limits=[0,1]
    end

    properties(Dependent,Hidden,Access=?ChartUnitTestFriend)
UsingTableForData
NotUsingTableForData
        XDisplayData_I string
        YDisplayData_I string
MissingDataValue
LooseInsetCachePosition
    end

    properties(Transient,NonCopyable,Hidden,Access=?ChartUnitTestFriend)

        CalculatedXData string=string.empty(0,1)
        CalculatedYData string=string.empty(0,1)
        CalculatedColorData double=[]
        CalculatedCounts double=[]
        CalculatedRowIndices double=[]
CalculatedDataTipData
    end

    properties(Hidden,Access=?ChartUnitTestFriend)


DataStorage



CalculatedDataStorage



        DataDirty logical=false


        XVariableName char=''
        YVariableName char=''
        ColorVariableName char=''
    end

    properties(AbortSet,Hidden,Access=?ChartUnitTestFriend)
OuterPositionCache
        LooseInsetCache matlab.internal.datatype.matlab.graphics.general.UnitPosition
    end

    properties(Hidden)

        FontSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Hidden,Access=?ChartUnitTestFriend)


PositionStorage
    end

    properties(Transient,NonCopyable,Hidden,Access=?ChartUnitTestFriend)
        MarkedCleanListener event.listener
        DataChangedEventData matlab.graphics.chart.internal.heatmap.DataChangedEventData=matlab.graphics.chart.internal.heatmap.DataChangedEventData.empty()
PrintSettingsCache
        LayoutCache=struct.empty();
        ColorbarPositionCache=struct(...
        'Units','',...
        'Colorbar',NaN(1,4),...
        'MissingDataColorbar',NaN(1,4))
        ResponsiveResizeCache=struct(...
        'Frozen',false,...
        'ColorbarGap',[8,8],...
        'FontSize',get(groot,'FactoryAxesFontSize'))
    end

    properties(Transient,NonCopyable,Hidden,AbortSet,...
        Access={?ChartUnitTestFriend,...
        ?matlab.graphics.chart.internal.heatmap.Controller})
Controller
    end

    properties(Transient,NonCopyable,Hidden,AbortSet,...
        Access={?ChartUnitTestFriend,...
        ?matlab.graphics.chart.internal.heatmap.Controller,...
        ?matlab.graphics.chart.internal.heatmap.DragToRearrange,...
        ?matlab.graphics.chart.internal.heatmap.InteractionStrategy})
        EnableInteractions(1,1)logical=true
    end

    properties(Transient,NonCopyable,Hidden,...
        Access={?ChartUnitTestFriend,...
        ?matlab.graphics.chart.internal.Chart,...
        ?matlab.graphics.chart.internal.heatmap.Controller,...
        ?matlab.graphics.chart.internal.heatmap.DragToRearrange,...
        ?matlab.graphics.chart.internal.heatmap.InteractionStrategy})
Axes
    end

    properties(Transient,NonCopyable,Hidden,AbortSet,...
        Access={?ChartUnitTestFriend,...
        ?matlab.graphics.chart.internal.heatmap.Controller,...
        ?matlab.graphics.chart.internal.heatmap.DragToRearrange,...
        ?matlab.graphics.chart.internal.heatmap.InteractionStrategy})
        Heatmap matlab.graphics.chart.primitive.Heatmap
    end

    properties(Transient,NonCopyable,Hidden,AbortSet,...
        Access=?ChartUnitTestFriend)
        XAxis matlab.graphics.axis.decorator.CategoricalRuler
        YAxis matlab.graphics.axis.decorator.CategoricalRuler
        TitleHandle matlab.graphics.primitive.Text
        XLabelHandle matlab.graphics.primitive.Text
        YLabelHandle matlab.graphics.primitive.Text
        Colorbar matlab.graphics.illustration.ColorBar
        MissingDataColorbar matlab.graphics.illustration.ColorBar
    end

    events(NotifyAccess=?ChartUnitTestFriend,...
        ListenAccess={?ChartUnitTestFriend,...
        ?matlab.graphics.chart.internal.heatmap.Controller})
DataChanged
    end

    methods
        function hObj=HeatmapChart(varargin)
            hObj.Description='HeatmapChart';


            hAx=matlab.graphics.axis.Axes();
            hObj.Axes=hAx;


            hAx.Toolbar=gobjects(0);
            hAx.InteractionContainer.Enabled='off';
            hAx.Description='Heatmap Axes';
            hAx.Internal=true;
            setActiveRuler(hAx,matlab.graphics.axis.decorator.CategoricalRuler,0);
            setActiveRuler(hAx,matlab.graphics.axis.decorator.CategoricalRuler,1);
            hAx.Box='on';
            hAx.YDir='reverse';
            hAx.TickLabelInterpreter='tex';
            hAx.TickLength=[0,0];
            hAx.Units='normalized';
            hAx.OuterPosition=[0,0,1,1];



            hObj.XAxis=hAx.ActiveXRuler;
            hObj.YAxis=hAx.ActiveYRuler;
            hObj.TitleHandle=hAx.Title;
            hObj.XLabelHandle=hObj.XAxis.Label;
            hObj.YLabelHandle=hObj.YAxis.Label;



            addlistener(hObj.TitleHandle,'String','PostSet',@(~,~)set(hObj,'Title',hObj.TitleHandle.String_I));
            addlistener(hObj.XLabelHandle,'String','PostSet',@(~,~)set(hObj,'XLabel',hObj.XLabelHandle.String_I));
            addlistener(hObj.YLabelHandle,'String','PostSet',@(~,~)set(hObj,'YLabel',hObj.YLabelHandle.String_I));



            hObj.TitleHandle.StringMode='manual';
            hObj.XLabelHandle.StringMode='manual';
            hObj.YLabelHandle.StringMode='manual';


            hObj.TitleHandle.Interpreter='tex';
            hObj.XLabelHandle.Interpreter='tex';
            hObj.YLabelHandle.Interpreter='tex';


            hObj.addNode(hAx);


            hHeatmap=matlab.graphics.chart.primitive.Heatmap;
            hObj.Heatmap=hHeatmap;


            hHeatmap.Internal=true;
            hHeatmap.MissingDataLabel='';
            hHeatmap.FontAngle=get(groot,'FactoryAxesFontAngle');
            hHeatmap.FontWeight=get(groot,'FactoryAxesFontWeight');
            hHeatmap.Interpreter='tex';
            hHeatmap.Parent=hAx;


            bh=hggetbehavior(hHeatmap,'DataCursor');
            bh.Enable=false;
            bh.Serialize=false;


            bh=hggetbehavior(hAx,'brush');
            bh.Enable=false;
            bh.Serialize=false;


            hObj.createColorbars();


            hObj.setDefaultPropertiesOnPrimitives();


            hObj.addDependencyConsumed({'ref_frame','resolution'});


            hObj.MarkedCleanListener=event.listener(hObj,...
            'MarkedClean',@(~,~)hObj.markedCleanEvent());

            try

                matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
            catch e
                throwAsCaller(e);
            end


            hObj.Controller=matlab.graphics.chart.internal.heatmap.Controller(hObj);
        end

        [colorData,xData]=sortx(hObj,varargin)
        [colorData,yData]=sorty(hObj,varargin)
        xl=xlim(hObj,limits)
        yl=ylim(hObj,limits)
    end

    methods(Hidden)
        doUpdate(hObj,updateState)

        function scaleForPrinting(hObj,flag,scale)





            switch lower(flag)
            case 'modify'

                settings.MinimumFontSize=hObj.Heatmap.MinimumFontSize;
                settings.CellMargin=hObj.Heatmap.CellMargin;
                settings.LineWidth=hObj.Heatmap.LineWidth;
                settings.Units=hObj.Units;
                if strcmpi(hObj.PositionConstraint,'outerposition')
                    settings.OuterPosition=hObj.OuterPosition;
                else
                    settings.InnerPosition=hObj.InnerPosition;
                end
                settings.LooseInsetCache=hObj.LooseInsetCache;
                hObj.PrintSettingsCache=settings;



                scopeGuard=onCleanup(@()hObj.enableSubplotListeners());
                hObj.disableSubplotListeners();
                hObj.Units='normalized';
                delete(scopeGuard);


                if scale~=1
                    hObj.Heatmap.MinimumFontSize=settings.MinimumFontSize./scale;
                    hObj.Heatmap.CellMargin=settings.CellMargin./scale;
                    hObj.Heatmap.LineWidth=settings.LineWidth./scale;
                    hObj.Colorbar.LineWidth=settings.LineWidth./scale;
                    hObj.MissingDataColorbar.LineWidth=settings.LineWidth./scale;
                end
            case 'revert'
                settings=hObj.PrintSettingsCache;

                if~isempty(settings)


                    hObj.Heatmap.MinimumFontSize=settings.MinimumFontSize;
                    hObj.Heatmap.CellMargin=settings.CellMargin;
                    hObj.Heatmap.LineWidth=settings.LineWidth;
                    hObj.Colorbar.LineWidth=settings.LineWidth;
                    hObj.MissingDataColorbar.LineWidth=settings.LineWidth;



                    scopeGuard=onCleanup(@()hObj.enableSubplotListeners());
                    hObj.disableSubplotListeners();
                    hObj.Units=settings.Units;
                    delete(scopeGuard);

                    scopeGuard=onCleanup(@()hObj.enableSubplotListeners());
                    hObj.disableSubplotListeners();
                    if strcmpi(hObj.PositionConstraint,'outerposition')
                        hObj.OuterPosition=settings.OuterPosition;
                    else
                        hObj.InnerPosition=settings.InnerPosition;
                    end
                    delete(scopeGuard);
                    hObj.LooseInsetCache=settings.LooseInsetCache;
                end


                hObj.PrintSettingsCache=[];
            end
        end

        function ignore=mcodeIgnoreHandle(~,~)

            ignore=false;
        end

        mcodeConstructor(hObj,hCode)
    end

    methods(Access=protected)

        function setDataTipConfiguration(hObj,newValue)
            setDataTipConfiguration@matlab.graphics.datatip.internal.mixin.AggregatedDataTipMixin(hObj,newValue);
            hObj.DataDirty=true;
        end
    end

    methods(Static,Hidden)
        [data,err]=validateXYData(data,dim)
    end

    methods(Static,Access=protected)

        function val=getMissingDataValue(method)

            switch(lower(method))
            case{'sum','count'}
                val=0;
            otherwise
                val=NaN;
            end
        end
    end

    methods(Hidden,Access=?ChartUnitTestFriend)
        updateData(hObj)
        updateColorMethod(hObj)
        updateLabels(hObj)

        createColorbars(hObj)
        doLayout(hObj,updateState,showColorbar,showMissingDataColorbar)

        function setDefaultPropertiesOnPrimitives(hObj)



            hObj.Axes.FontName=hObj.FontName;
            hObj.Axes.FontSize=hObj.FontSize;
            hObj.Axes.ColorSpace.Colormap=hObj.Colormap;


            hObj.Heatmap.FontName=hObj.FontName;
            hObj.Heatmap.FontSize=hObj.FontSize;
            hObj.Heatmap.CellLabelFormat=hObj.CellLabelFormat;
            hObj.Heatmap.CellLabelColor=hObj.CellLabelColor;
            hObj.Heatmap.MissingDataColor=hObj.MissingDataColor;
            hObj.Heatmap.GridVisible=hObj.GridVisible;
            hObj.Heatmap.ColorScaling=hObj.ColorScaling;


            hObj.TitleHandle.Color=hObj.FontColor;
            hObj.XAxis.Color=hObj.FontColor;
            hObj.YAxis.Color=hObj.FontColor;


            hObj.Colorbar.FontSize=0.9*hObj.FontSize;
            hObj.Colorbar.FontName=hObj.FontName;
            hObj.Colorbar.Ruler.TickLabelColor=hObj.FontColor;
            hObj.Colorbar.Visible=hObj.ColorbarVisible;


            hObj.MissingDataColorbar.FontSize=0.9*hObj.FontSize;
            hObj.MissingDataColorbar.FontName=hObj.FontName;
            hObj.MissingDataColorbar.Ruler.TickLabelColor=hObj.FontColor;
            hObj.MissingDataColorbar.Colormap=hObj.MissingDataColor;
            hObj.MissingDataColorbar.TickLabels=hObj.MissingDataLabel;
            hObj.MissingDataColorbar.Visible=hObj.ColorbarVisible;
        end

        function markedCleanEvent(hObj)





            eventData=hObj.DataChangedEventData;




            hObj.DataChangedEventData=matlab.graphics.chart.internal.heatmap.DataChangedEventData();


            if eventData.hasDataChanged()
                notify(hObj,'DataChanged',eventData);
            end
        end
    end

    methods(Static,Hidden,Access=?ChartUnitTestFriend)
        [limits,err]=validateXYLimits(limits,data,checkData,dim)
        [limits,errorID]=validateXYLimitsAgainstData(limits,data)
        [newData,dataErr]=setXYDisplayData(oldData,data,dataPropName)
        [colorDisplayData,errID,varargout]=getColorDisplayData(...
        rawColorData,xData,yData,...
        xDisplayData,yDisplayData,missingDataValue,varargin)
        [colorDisplayData,yDisplayData]=sortDisplayData(...
        xData,yData,colorData,xDisplayData,yDisplayData,...
        missingDataValue,dim,args)
    end

    methods(Access=protected,Hidden)
        function label=getDescriptiveLabelForDisplay(hObj)
            label=hObj.Title;
        end

        function groups=getPropertyGroups(hObj)
            if hObj.UsingTableForData
                groups=matlab.mixin.util.PropertyGroup(...
                {'SourceTable','XVariable','YVariable','ColorVariable','ColorMethod'});
            else
                groups=matlab.mixin.util.PropertyGroup(...
                {'XData','YData','ColorData'});
            end
        end

        function disableSubplotListeners(hObj)
            parent=hObj.Parent;
            if isscalar(parent)&&isvalid(parent)
                slm=getappdata(parent,'SubplotListenersManager');
                if~isempty(slm)
                    disable(slm);
                end
            end
        end

        function enableSubplotListeners(hObj)
            parent=hObj.Parent;
            if isscalar(parent)&&isvalid(parent)
                slm=getappdata(parent,'SubplotListenersManager');
                if~isempty(slm)
                    enable(slm);
                end
            end
        end

        function dtConfig=getDefaultDataTipConfiguration(hObj)
            dtConfig=string.empty(0,2);
            if~isempty(hObj.XVariableName)
                dtConfig(end+1,:)=[hObj.XVariableName,"none"];
            end

            if~isempty(hObj.YVariableName)
                dtConfig(end+1,:)=[hObj.YVariableName,"none"];
            end

            colorMethod=hObj.ColorMethod;
            if~strcmpi(colorMethod,'none')
                firstDimName=hObj.SourceTable.Properties.DimensionNames{1};
                dtConfig(end+1,:)=[firstDimName,"count"];
            end

            if~isempty(hObj.ColorVariableName)
                if strcmp(colorMethod,'none')
                    hObj.isAggregated=false;
                end

                dtConfig(end+1,:)=[hObj.ColorVariableName,string(colorMethod)];
            end
        end

        function dtMethods=getAllDataTipMethods(obj)

            dtMethods=setdiff(set(obj,'ColorMethod'),{'none','count'});
        end
    end

    methods(Access=?matlab.graphics.chart.internal.heatmap.Controller)

        function openContextMenu(obj,evd)


            if obj.UsingTableForData
                obj.showContextMenu(evd);
            end
        end
    end

    methods(Access={?matlab.graphics.chart.internal.heatmap.Controller,?ChartUnitTestFriend})
        str=getDataTipString(hObj,point)
    end

    methods(Access={?ChartUnitTestFriend,...
        ?matlab.graphics.chart.internal.heatmap.Controller,...
        ?matlab.graphics.chart.internal.heatmap.DragToRearrange,...
        ?matlab.graphics.chart.internal.heatmap.InteractionStrategy})
        moveDisplayData(hObj,dim,item,newIndex)
        freezeLayout(hObj,freezeRotation)
        thawLayout(hObj)
    end


    methods
        function set.Title(hObj,title)
            hObj.Title_I=title;
            hObj.TitleMode='manual';
        end

        function set.XLabel(hObj,label)
            hObj.XLabel_I=label;
            hObj.XLabelMode='manual';
        end

        function set.YLabel(hObj,label)
            hObj.YLabel_I=label;
            hObj.YLabelMode='manual';
        end

        function title=get.Title(hObj)
            title=hObj.Title_I;
        end

        function label=get.XLabel(hObj)
            label=hObj.XLabel_I;
        end

        function label=get.YLabel(hObj)
            label=hObj.YLabel_I;
        end

        function set.Title_I(hObj,title)
            hObj.Title_I=title;
            hObj.TitleHandle.String_I=title;%#ok<MCSUP>
        end

        function set.XLabel_I(hObj,label)
            hObj.XLabel_I=label;
            hObj.XLabelHandle.String_I=label;%#ok<MCSUP>
        end

        function set.YLabel_I(hObj,label)
            hObj.YLabel_I=label;
            hObj.YLabelHandle.String_I=label;%#ok<MCSUP>
        end

        function set.TitleMode(hObj,mode)


            hObj.TitleMode=mode;
            if strcmp(mode,'auto')

                hObj.updateLabels();
            end
        end

        function set.XLabelMode(hObj,mode)


            hObj.XLabelMode=mode;
            if strcmp(mode,'auto')

                hObj.updateLabels();
            end
        end

        function set.YLabelMode(hObj,mode)


            hObj.YLabelMode=mode;
            if strcmp(mode,'auto')

                hObj.updateLabels();
            end
        end
    end


    methods
        function set.SourceTable(hObj,tbl)
            import matlab.graphics.chart.internal.validateTableSubscript



            assert(hObj.UsingTableForData,...
            message('MATLAB:graphics:heatmap:MatrixWorkflow','SourceTable'));


            assert(isa(tbl,'tabular'),...
            message('MATLAB:graphics:heatmap:InvalidSourceTable'));


            [xVarName,~,errX]=validateTableSubscript(...
            tbl,hObj.XVariable_I,'XVariable');
            [yVarName,~,errY]=validateTableSubscript(...
            tbl,hObj.YVariable_I,'YVariable');
            [cVarName,~,errC]=validateTableSubscript(...
            tbl,hObj.ColorVariable_I,'ColorVariable');



            if~isempty(errX)
                throwAsCaller(errX);
            end
            if~isempty(errY)
                throwAsCaller(errY);
            end
            if~isempty(errC)
                throwAsCaller(errC);
            end


            hObj.SourceTable_I=tbl;


            hObj.DataDirty=true;


            hObj.XVariableName=xVarName;
            hObj.YVariableName=yVarName;
            hObj.ColorVariableName=cVarName;


            hObj.updateColorMethod();


            hObj.updateLabels();
        end

        function tbl=get.SourceTable(hObj)
            tbl=hObj.SourceTable_I;
        end

        function set.XVariable(hObj,var)


            assert(hObj.UsingTableForData,...
            message('MATLAB:graphics:heatmap:MatrixWorkflow','XVariable'));


            import matlab.graphics.chart.internal.validateTableSubscript
            tbl=hObj.SourceTable_I;
            [varName,var,err]=validateTableSubscript(tbl,var,'XVariable');
            if isempty(err)
                hObj.XVariableName=varName;
            else
                throwAsCaller(err);
            end


            hObj.XVariable_I=var;


            hObj.XDisplayDataMode='auto';


            hObj.DataDirty=true;


            hObj.DataChangedEventData.XData=true;


            hObj.updateColorMethod();


            hObj.updateLabels();
        end

        function var=get.XVariable(hObj)
            var=hObj.XVariable_I;
        end

        function set.YVariable(hObj,var)


            assert(hObj.UsingTableForData,...
            message('MATLAB:graphics:heatmap:MatrixWorkflow','YVariable'));


            import matlab.graphics.chart.internal.validateTableSubscript
            tbl=hObj.SourceTable_I;
            [varName,var,err]=validateTableSubscript(tbl,var,'YVariable');
            if isempty(err)
                hObj.YVariableName=varName;
            else
                throwAsCaller(err);
            end


            hObj.YVariable_I=var;


            hObj.YDisplayDataMode='auto';


            hObj.DataChangedEventData.YData=true;


            hObj.DataDirty=true;


            hObj.updateColorMethod();


            hObj.updateLabels();
        end

        function var=get.YVariable(hObj)
            var=hObj.YVariable_I;
        end

        function set.ColorVariable(hObj,var)


            assert(hObj.UsingTableForData,...
            message('MATLAB:graphics:heatmap:MatrixWorkflow','ColorVariable'));


            import matlab.graphics.chart.internal.validateTableSubscript
            tbl=hObj.SourceTable_I;
            [varName,var,err]=validateTableSubscript(tbl,var,'ColorVariable');
            if isempty(err)
                hObj.ColorVariableName=varName;
            else
                throwAsCaller(err);
            end


            hObj.ColorVariable_I=var;


            hObj.DataDirty=true;


            hObj.updateColorMethod();


            hObj.updateLabels();
        end

        function var=get.ColorVariable(hObj)
            var=hObj.ColorVariable_I;
        end

        function set.ColorMethod(hObj,method)

            hObj.ColorMethod_I=method;


            hObj.DataDirty=true;


            hObj.ColorMethodMode='manual';


            hObj.updateLabels();
        end

        function method=get.ColorMethod(hObj)
            method=hObj.ColorMethod_I;
        end

        function set.ColorMethodMode(hObj,mode)


            hObj.ColorMethodMode=mode;
            if strcmp(mode,'auto')


                hObj.updateColorMethod();
            end
        end
    end


    methods
        function set.XData(hObj,data)




            matrixMode=hObj.NotUsingTableForData;
            assert(matrixMode,message('MATLAB:graphics:heatmap:TableWorkflow','XData'));


            [data,err]=hObj.validateXYData(data,'x');
            if~isempty(err)
                throwAsCaller(err);
            end

            hObj.XData_I=data;
            hObj.XDataMode='manual';


            hObj.XDisplayDataMode='auto';


            hObj.DataChangedEventData.XData=true;
        end

        function data=get.XData(hObj)
            if hObj.UsingTableForData

                updateData(hObj);
            end
            data=cellstr(hObj.XData_I);
        end

        function set.XDataMode(hObj,mode)


            hObj.XDataMode=mode;
            if strcmp(mode,'auto')

                if hObj.UsingTableForData

                    hObj.XData_I=hObj.CalculatedXData;
                else

                    nx=size(hObj.ColorData_I,2);
                    hObj.XData_I=string(1:nx)';
                end
            end
        end

        function set.XData_I(hObj,data)

            hObj.XData_I=data(:);


            if strcmp(hObj.XDisplayDataMode,'auto')
                hObj.XDisplayData_I=data(:);
            end


            hObj.DataChangedEventData.Matrix=true;
        end

        function set.YData(hObj,data)




            matrixMode=hObj.NotUsingTableForData;
            assert(matrixMode,message('MATLAB:graphics:heatmap:TableWorkflow','YData'));


            [data,err]=hObj.validateXYData(data,'y');
            if~isempty(err)
                throwAsCaller(err);
            end

            hObj.YData_I=data;
            hObj.YDataMode='manual';


            hObj.YDisplayDataMode='auto';


            hObj.DataChangedEventData.YData=true;
        end

        function data=get.YData(hObj)
            if hObj.UsingTableForData

                updateData(hObj);
            end
            data=cellstr(hObj.YData_I);
        end

        function set.YDataMode(hObj,mode)


            hObj.YDataMode=mode;
            if strcmp(mode,'auto')

                if hObj.UsingTableForData

                    hObj.YData_I=hObj.CalculatedYData;
                else

                    ny=size(hObj.ColorData_I,1);
                    hObj.YData_I=string(1:ny)';
                end
            end
        end

        function set.YData_I(hObj,data)

            hObj.YData_I=data(:);


            if strcmp(hObj.YDisplayDataMode,'auto')
                hObj.YDisplayData_I=data(:);
            end


            hObj.DataChangedEventData.Matrix=true;
        end

        function set.ColorData(hObj,data)




            matrixMode=hObj.NotUsingTableForData;
            assert(matrixMode,message('MATLAB:graphics:heatmap:TableWorkflow','ColorData'));

            hObj.ColorData_I=data;


            [ny,nx]=size(hObj.ColorData_I);


            if strcmp(hObj.XDataMode,'auto')
                hObj.XData_I=string(1:nx)';
            end


            if strcmp(hObj.YDataMode,'auto')
                hObj.YData_I=string(1:ny)';
            end


            hObj.ColorDataMode='manual';
        end

        function data=get.ColorData(hObj)
            if hObj.UsingTableForData

                updateData(hObj);
            end
            data=hObj.ColorData_I;
            if isempty(data)&&xor(isempty(hObj.XData_I),isempty(hObj.YData_I))



                nx=numel(hObj.XData_I);
                ny=numel(hObj.YData_I);
                data=NaN(ny,nx);
            end
        end

        function set.ColorDataMode(hObj,mode)


            hObj.ColorDataMode=mode;
            if strcmp(mode,'auto')


                hObj.ColorData_I=hObj.CalculatedColorData;
                hObj.XData_I=hObj.CalculatedXData;
                hObj.YData_I=hObj.CalculatedYData;
            end
        end

        function set.ColorData_I(hObj,data)

            hObj.ColorData_I=data;


            hObj.DataChangedEventData.Matrix=true;
        end

        function tf=get.UsingTableForData(hObj)


            tf=strcmp(hObj.ColorDataMode,'auto');
        end

        function tf=get.NotUsingTableForData(hObj)




            tf=strcmp(hObj.ColorDataMode,'manual')||width(hObj.SourceTable)==0;
        end
    end


    methods
        function set.XDisplayData(hObj,data)

            hObj.XDisplayData_I=data;
            hObj.XDisplayDataMode='manual';
        end

        function data=get.XDisplayData(hObj)
            if hObj.UsingTableForData

                updateData(hObj);
            end

            data=cellstr(hObj.XDisplayData_I);
        end

        function set.XDisplayData_I(hObj,data)

            [newData,dataErr]=hObj.setXYDisplayData(hObj.XDisplay_I,data,'x');


            if~isempty(dataErr)
                throwAsCaller(dataErr);
            end


            hObj.XDisplay_I=newData;
        end

        function data=get.XDisplayData_I(hObj)



            data=hObj.XDisplay_I(:,1);
        end

        function set.XDisplayDataMode(hObj,mode)


            hObj.XDisplayDataMode=mode;
            if strcmp(mode,'auto')

                hObj.XDisplay_I=hObj.setXYDisplayData(hObj.XDisplay_I,...
                hObj.XData_I,'x');
            end
        end

        function set.XDisplay_I(hObj,data)

            hObj.XDisplay_I=data;


            hObj.DataChangedEventData.XDisplay=true;


            xordered=data(:,1);
            if strcmp(hObj.XLimitsMode,'manual')
                [hObj.XLimits_I,limitsErr]=...
                hObj.validateXYLimitsAgainstData(hObj.XLimits_I,xordered);
                if~isempty(limitsErr)
                    warning(message('MATLAB:graphics:heatmap:ResettingLimits',...
                    'XLimits','XDisplayData'));
                    hObj.XLimitsMode='auto';
                end
            end


            if strcmp(hObj.XLimitsMode,'auto')
                if isempty(xordered)
                    limits=string([NaN,NaN]);
                else
                    limits=xordered([1,end]);
                end
                hObj.XLimits_I=limits(:)';
            end
        end

        function set.YDisplayData(hObj,data)

            hObj.YDisplayData_I=data;
            hObj.YDisplayDataMode='manual';
        end

        function data=get.YDisplayData(hObj)
            if hObj.UsingTableForData

                updateData(hObj);
            end

            data=cellstr(hObj.YDisplayData_I);
        end

        function set.YDisplayData_I(hObj,data)

            [newData,dataErr]=hObj.setXYDisplayData(hObj.YDisplay_I,data,'y');


            if~isempty(dataErr)
                throwAsCaller(dataErr);
            end


            hObj.YDisplay_I=newData;
        end

        function data=get.YDisplayData_I(hObj)



            data=hObj.YDisplay_I(:,1);
        end

        function set.YDisplayDataMode(hObj,mode)


            hObj.YDisplayDataMode=mode;
            if strcmp(mode,'auto')

                hObj.YDisplay_I=hObj.setXYDisplayData(hObj.YDisplay_I,...
                hObj.YData_I,'y');
            end
        end

        function set.YDisplay_I(hObj,data)

            hObj.YDisplay_I=data;


            hObj.DataChangedEventData.YDisplay=true;


            yordered=data(:,1);
            if strcmp(hObj.YLimitsMode,'manual')
                [hObj.YLimits_I,limitsErr]=...
                hObj.validateXYLimitsAgainstData(hObj.YLimits_I,yordered);
                if~isempty(limitsErr)
                    warning(message('MATLAB:graphics:heatmap:ResettingLimits',...
                    'YLimits','YDisplayData'));
                    hObj.YLimitsMode='auto';
                end
            end


            if strcmp(hObj.YLimitsMode,'auto')
                if isempty(yordered)
                    limits=string([NaN,NaN]);
                else
                    limits=yordered([1,end]);
                end
                hObj.YLimits_I=limits(:)';
            end
        end

        function set.XDisplayLabels(hObj,labels)

            if hObj.UsingTableForData&&strcmp(hObj.XDisplayDataMode,'auto')

                updateData(hObj);
            end


            assert(numel(labels)==size(hObj.XDisplay_I,1),...
            message('MATLAB:graphics:heatmap:LabelsMismatch','XDisplayLabels','XDisplayData'));


            labels=strrep(labels,newline,' ');


            hObj.XDisplay_I(:,2)=labels(:);
        end

        function data=get.XDisplayLabels(hObj)
            if hObj.UsingTableForData

                updateData(hObj);
            end




            data=cellstr(hObj.XDisplay_I(:,2));
        end

        function set.YDisplayLabels(hObj,labels)

            if hObj.UsingTableForData&&strcmp(hObj.YDisplayDataMode,'auto')

                updateData(hObj);
            end


            assert(numel(labels)==size(hObj.YDisplay_I,1),...
            message('MATLAB:graphics:heatmap:LabelsMismatch','YDisplayLabels','YDisplayData'));


            labels=strrep(labels,newline,' ');


            hObj.YDisplay_I(:,2)=labels(:);
        end

        function data=get.YDisplayLabels(hObj)
            if hObj.UsingTableForData

                updateData(hObj);
            end




            data=cellstr(hObj.YDisplay_I(:,2));
        end

        function cdata=get.ColorDisplayData(hObj)











            rawColorData=hObj.ColorData;


            xData=hObj.XData_I;
            yData=hObj.YData_I;
            xDisplayData=hObj.XDisplayData_I;
            yDisplayData=hObj.YDisplayData_I;


            [cdata,errID]=hObj.getColorDisplayData(...
            rawColorData,xData,yData,...
            xDisplayData,yDisplayData,hObj.MissingDataValue);



            if~isempty(errID)
                throwAsCaller(MException(message(errID)));
            end
        end

        function val=get.MissingDataValue(hObj)


            val=hObj.getMissingDataValue(hObj.ColorMethod_I);
        end
    end


    methods
        function set.DataStorage(hObj,data)




            hObj.ColorData_I=data.ColorData;%#ok<MCSUP>
            hObj.XData_I=data.XData;%#ok<MCSUP>
            hObj.YData_I=data.YData;%#ok<MCSUP>


            if isfield(data,'XDisplay')&&isfield(data,'YDisplay')
                hObj.XDisplay_I=data.XDisplay;%#ok<MCSUP>
                hObj.YDisplay_I=data.YDisplay;%#ok<MCSUP>
            end


            if isfield(data,'XLimitsR2017b')&&isfield(data,'YLimitsR2017b')

                hObj.XLimits_I=data.XLimitsR2017b;%#ok<MCSUP>
                hObj.YLimits_I=data.YLimitsR2017b;%#ok<MCSUP>
            else

                hObj.XLimits_I=data.XLimits;%#ok<MCSUP>
                hObj.YLimits_I=data.YLimits;%#ok<MCSUP>
            end
            hObj.ColorLimits_I=data.ColorLimits;%#ok<MCSUP>





            hObj.XDataMode=data.XDataMode;%#ok<MCSUP>
            hObj.YDataMode=data.YDataMode;%#ok<MCSUP>
            hObj.ColorDataMode=data.ColorDataMode;%#ok<MCSUP>


            if isfield(data,'XDisplayDataMode')&&isfield(data,'YDisplayDataMode')
                hObj.XDisplayDataMode=data.XDisplayDataMode;%#ok<MCSUP>
                hObj.YDisplayDataMode=data.YDisplayDataMode;%#ok<MCSUP>
            end

            if isfield(data,'XLimitsModeR2017b')&&isfield(data,'YLimitsModeR2017b')

                hObj.XLimitsMode=data.XLimitsModeR2017b;%#ok<MCSUP>
                hObj.YLimitsMode=data.YLimitsModeR2017b;%#ok<MCSUP>
            else

                hObj.XLimitsMode=data.XLimitsMode;%#ok<MCSUP>
                hObj.YLimitsMode=data.YLimitsMode;%#ok<MCSUP>
            end
            hObj.ColorLimitsMode=data.ColorLimitsMode;%#ok<MCSUP>
        end

        function data=get.DataStorage(hObj)




            data.XData=hObj.XData_I;
            data.YData=hObj.YData_I;
            data.ColorData=hObj.ColorData_I;


            data.XDisplay=hObj.XDisplay_I;
            data.YDisplay=hObj.YDisplay_I;


            data.XDataMode=hObj.XDataMode;
            data.YDataMode=hObj.YDataMode;
            data.ColorDataMode=hObj.ColorDataMode;


            data.XDisplayDataMode=hObj.XDisplayDataMode;
            data.YDisplayDataMode=hObj.YDisplayDataMode;











            if isempty(hObj.XData_I)
                data.XLimits=string([NaN,NaN]);
            else
                data.XLimits=hObj.XData_I([1,end])';
            end
            if isempty(hObj.XData_I)
                data.YLimits=string([NaN,NaN]);
            else
                data.YLimits=hObj.YData_I([1,end])';
            end
            data.XLimitsMode='auto';
            data.YLimitsMode='auto';



            data.XLimitsR2017b=hObj.XLimits_I;
            data.YLimitsR2017b=hObj.YLimits_I;
            data.XLimitsModeR2017b=hObj.XLimitsMode;
            data.YLimitsModeR2017b=hObj.YLimitsMode;


            data.ColorLimits=hObj.ColorLimits_I;
            data.ColorLimitsMode=hObj.ColorLimitsMode;


            [v,d]=version;
            data.Version=v;
            data.Date=d;
        end

        function set.CalculatedDataStorage(hObj,data)





            hObj.CalculatedXData=data.XData;%#ok<MCSUP>
            hObj.CalculatedYData=data.YData;%#ok<MCSUP>
            hObj.CalculatedColorData=data.ColorData;%#ok<MCSUP>
            hObj.CalculatedDataTipData=data.DataTipData;%#ok<MCSUP>
            hObj.CalculatedRowIndices=data.RowIndices;%#ok<MCSUP>


            if isfield(data,'Counts')
                hObj.CalculatedCounts=data.Counts;%#ok<MCSUP>
            else

                hObj.DataDirty=true;%#ok<MCSUP>
            end
        end

        function data=get.CalculatedDataStorage(hObj)





            data.XData=hObj.CalculatedXData;
            data.YData=hObj.CalculatedYData;
            data.Counts=hObj.CalculatedCounts;
            data.ColorData=hObj.CalculatedColorData;
            data.DataTipData=hObj.CalculatedDataTipData;
            data.RowIndices=hObj.CalculatedRowIndices;


            [v,d]=version;
            data.Version=v;
            data.Date=d;
        end




        function set.PositionStorage(hObj,data)



            if~any(isfield(data,{'PositionConstraint','ActivePositionProperty'}))
                return
            end






            if~isfield(data,'PositionConstraint')
                if strcmpi(data.ActivePositionProperty,'outerposition')
                    data.PositionConstraint='outerposition';
                else
                    data.PositionConstraint='innerposition';
                end
            end

            hObj.Axes.Units=data.Units;%#ok<MCSUP>

            if strcmpi(data.PositionConstraint,'outerposition')
                hObj.Axes.PositionConstraint=data.PositionConstraint;%#ok<MCSUP>
                hObj.Axes.OuterPosition=data.OuterPosition;%#ok<MCSUP>
            else
                hObj.Axes.PositionConstraint=data.PositionConstraint;%#ok<MCSUP>
                hObj.Axes.Position=data.InnerPosition;%#ok<MCSUP>
            end
        end

        function data=get.PositionStorage(hObj)



            data.Units=hObj.Axes.Units;
            data.ActivePositionProperty=hObj.Axes.ActivePositionProperty;
            data.PositionConstraint=hObj.Axes.PositionConstraint;
            data.InnerPosition=hObj.Axes.Position;
            data.OuterPosition=hObj.Axes.OuterPosition;
        end
    end


    methods
        function set.XLimits(hObj,limits)















            tableMode=hObj.UsingTableForData;
            matrixMode=hObj.NotUsingTableForData;
            checkData=~tableMode||(~matrixMode&&~hObj.DataDirty)||...
            strcmp(hObj.XDisplayDataMode,'manual')||...
            strcmp(hObj.XDataMode,'manual');


            [limits,err]=hObj.validateXYLimits(limits,...
            hObj.XDisplayData_I,checkData,'X');


            if~isempty(err)
                throwAsCaller(err);
            end

            hObj.XLimits_I=limits;
            hObj.XLimitsMode='manual';
        end

        function limits=get.XLimits(hObj)

            if strcmp(hObj.XLimitsMode,'auto')&&hObj.UsingTableForData

                updateData(hObj);
            end



            limits=hObj.XLimits_I;
            limits(ismissing(limits))="";


            limits=cellstr(limits);
        end

        function set.XLimitsMode(hObj,mode)


            hObj.XLimitsMode=mode;
            if strcmp(mode,'auto')


                data=hObj.XDisplayData_I;
                if isempty(data)
                    limits=string([NaN,NaN]);
                else
                    limits=data([1,end]);
                end
                hObj.XLimits_I=limits(:)';
            end
        end

        function set.YLimits(hObj,limits)















            tableMode=hObj.UsingTableForData;
            matrixMode=hObj.NotUsingTableForData;
            checkData=~tableMode||(~matrixMode&&~hObj.DataDirty)||...
            strcmp(hObj.YDisplayDataMode,'manual')||...
            strcmp(hObj.YDataMode,'manual');


            [limits,err]=hObj.validateXYLimits(limits,...
            hObj.YDisplayData_I,checkData,'Y');


            if~isempty(err)
                throwAsCaller(err);
            end

            hObj.YLimits_I=limits;
            hObj.YLimitsMode='manual';
        end

        function limits=get.YLimits(hObj)

            if strcmp(hObj.YLimitsMode,'auto')&&hObj.UsingTableForData

                updateData(hObj);
            end



            limits=hObj.YLimits_I;
            limits(ismissing(limits))="";


            limits=cellstr(limits);
        end

        function set.YLimitsMode(hObj,mode)


            hObj.YLimitsMode=mode;
            if strcmp(mode,'auto')


                data=hObj.YDisplayData_I;
                if isempty(data)
                    limits=string([NaN,NaN]);
                else
                    limits=data([1,end]);
                end
                hObj.YLimits_I=limits(:)';
            end
        end

        function set.ColorLimits(hObj,limits)
            hObj.ColorLimits_I=limits;
            hObj.ColorLimitsMode='manual';
        end

        function limits=get.ColorLimits(hObj)
            if strcmp(hObj.ColorLimitsMode,'auto')


                forceFullUpdate(hObj,'all','ColorLimits');
            end
            limits=hObj.ColorLimits_I;
        end

        function set.ColorLimitsMode(hObj,mode)


            hObj.ColorLimitsMode=mode;
            if strcmp(mode,'auto')

                hObj.MarkDirty('all');
            end
        end

        function set.OuterPositionCache(hObj,opc)








            if~isfield(opc,'Version')||opc.Version<2
                hAx=hObj.Axes;%#ok<MCSUP>
                hAx.Units=opc.Units;
                hAx.OuterPosition=opc.Position;
            end
        end

        function opc=get.OuterPositionCache(hObj)







            hAx=hObj.Axes;
            opc=struct('Units',hAx.Units,...
            'Position',hAx.OuterPosition,'Version',2);
        end

        function set.LooseInsetCachePosition(hObj,li)







            lic=hObj.LooseInsetCache;
            if any(strcmp(lic.Units,{'pixels','devicepixels'}))
                li=li+[1,1,0,0];
            end
            hObj.LooseInsetCache.Position=li;
        end

        function li=get.LooseInsetCachePosition(hObj)



            lic=hObj.LooseInsetCache;
            li=lic.Position;
            if any(strcmp(lic.Units,{'pixels','devicepixels'}))
                li=li-[1,1,0,0];
            end
        end
    end


    methods
        function eventData=get.DataChangedEventData(hObj)
            eventData=hObj.DataChangedEventData;


            if isempty(eventData)
                eventData=matlab.graphics.chart.internal.heatmap.DataChangedEventData();
                hObj.DataChangedEventData=eventData;
            end
        end
    end




    methods
        function set.FontName(hObj,fontName)

            hAx=hObj.Axes;%#ok<MCSUP>
            hHeatmap=hObj.Heatmap;%#ok<MCSUP>
            hColorbar=hObj.Colorbar;%#ok<MCSUP>
            hMColorbar=hObj.MissingDataColorbar;%#ok<MCSUP>

            if isscalar(hAx)&&isvalid(hAx)
                hAx.FontName=fontName;
            end

            if isscalar(hHeatmap)&&isvalid(hHeatmap)
                hHeatmap.FontName=fontName;
            end

            if isscalar(hColorbar)&&isvalid(hColorbar)
                hColorbar.FontName=fontName;
            end

            if isscalar(hMColorbar)&&isvalid(hMColorbar)
                hMColorbar.FontName=fontName;
            end

            hObj.FontName=fontName;
        end

        function set.FontSize_I(hObj,fontSize)


            hAx=hObj.Axes;%#ok<MCSUP>
            hHeatmap=hObj.Heatmap;%#ok<MCSUP>
            hColorbar=hObj.Colorbar;%#ok<MCSUP>
            hMColorbar=hObj.MissingDataColorbar;%#ok<MCSUP>

            if isscalar(hAx)&&isvalid(hAx)
                hAx.FontSize=fontSize;
            end

            if isscalar(hHeatmap)&&isvalid(hHeatmap)
                hHeatmap.FontSize=fontSize;
            end

            if isscalar(hColorbar)&&isvalid(hColorbar)
                hColorbar.FontSize=0.9*fontSize;
            end

            if isscalar(hMColorbar)&&isvalid(hMColorbar)
                hMColorbar.FontSize=0.9*fontSize;
            end

            hObj.FontSize_I=fontSize;
        end

        function set.FontSize(hObj,fontSize)
            hObj.FontSize_I=fontSize;%#ok<MCSUP>
            hObj.FontSizeMode='manual';%#ok<MCSUP>
        end

        function fontSize=get.FontSize(hObj)
            if strcmp(hObj.FontSizeMode,'auto')


                forceFullUpdate(hObj,'all','FontSize');
            end
            fontSize=hObj.FontSize_I;
        end

        function set.FontColor(hObj,fontColor)


            hTitle=hObj.TitleHandle;%#ok<MCSUP>
            hXAxis=hObj.XAxis;%#ok<MCSUP>
            hYAxis=hObj.YAxis;%#ok<MCSUP>
            hColorbar=hObj.Colorbar;%#ok<MCSUP>
            hMColorbar=hObj.MissingDataColorbar;%#ok<MCSUP>

            if isscalar(hTitle)&&isvalid(hTitle)
                hTitle.Color=fontColor;
            end

            if isscalar(hXAxis)&&isvalid(hXAxis)
                hXAxis.Color=fontColor;
            end

            if isscalar(hYAxis)&&isvalid(hYAxis)
                hYAxis.Color=fontColor;
            end

            if isscalar(hColorbar)&&isvalid(hColorbar)
                hColorbar.Ruler.TickLabelColor=fontColor;
            end

            if isscalar(hMColorbar)&&isvalid(hMColorbar)
                hMColorbar.Ruler.TickLabelColor=fontColor;
            end

            hObj.FontColor=fontColor;
        end

        function set.CellLabelFormat(hObj,format)

            hHeatmap=hObj.Heatmap;%#ok<MCSUP>

            if isscalar(hHeatmap)&&isvalid(hHeatmap)
                hHeatmap.CellLabelFormat=format;
            end

            hObj.CellLabelFormat=format;
        end

        function set.CellLabelColor(hObj,color)

            hHeatmap=hObj.Heatmap;%#ok<MCSUP>

            if isscalar(hHeatmap)&&isvalid(hHeatmap)
                hHeatmap.CellLabelColor=color;
            end

            hObj.CellLabelColor=color;
        end

        function set.MissingDataColor(hObj,color)


            hHeatmap=hObj.Heatmap;%#ok<MCSUP>
            hMCBar=hObj.MissingDataColorbar;%#ok<MCSUP>

            if isscalar(hHeatmap)&&isvalid(hHeatmap)
                hHeatmap.MissingDataColor=color;
            end

            if isscalar(hMCBar)&&isvalid(hMCBar)
                hMCBar.Colormap=color;
            end

            hObj.MissingDataColor=color;
        end

        function set.MissingDataLabel(hObj,label)


            hMCBar=hObj.MissingDataColorbar;%#ok<MCSUP>

            if isscalar(hMCBar)&&isvalid(hMCBar)
                hMCBar.TickLabels=label;
            end

            hObj.MissingDataLabel=label;
        end

        function set.GridVisible(hObj,visible)

            hHeatmap=hObj.Heatmap;%#ok<MCSUP>

            if isscalar(hHeatmap)&&isvalid(hHeatmap)
                hHeatmap.GridVisible=visible;
            end

            hObj.GridVisible=visible;
        end

        function set.ColorScaling(hObj,scaling)

            hHeatmap=hObj.Heatmap;%#ok<MCSUP>

            if isscalar(hHeatmap)&&isvalid(hHeatmap)
                hHeatmap.ColorScaling=scaling;
            end

            hObj.ColorScaling=scaling;
        end

        function set.Colormap(hObj,map)

            hAx=hObj.Axes;%#ok<MCSUP>

            if isscalar(hAx)&&isvalid(hAx)
                hAx.Colormap=map;
            end

            hObj.Colormap=map;
        end

        function set.ColorbarVisible(hObj,visible)

            hColorbar=hObj.Colorbar;%#ok<MCSUP>
            hMColorbar=hObj.MissingDataColorbar;%#ok<MCSUP>

            if isscalar(hColorbar)&&isvalid(hColorbar)
                hColorbar.Visible=visible;
            end

            if isscalar(hMColorbar)&&isvalid(hMColorbar)
                hMColorbar.Visible=visible;
            end

            hObj.ColorbarVisible=visible;
        end
    end
end
