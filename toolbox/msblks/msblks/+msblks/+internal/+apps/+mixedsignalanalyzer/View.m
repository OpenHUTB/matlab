classdef View<handle




    properties

Toolstrip


DataDoc
DataFig
DataFigLayout
DataDB
DataTree
        DataTreeAnalysisMetricsRootNodes=[];
        DataTreeAnalysisWaveformsRootNodes=[];
        DataTreeCheckedNodes=[];
        DataTreeMetricCheckedNodes=[];
        DataTreeWaveformCheckedNodes=[];
        DataTree_SelectedTablesAndNodes=[];


BlankPlotDoc
BlankPlotFig
PlotDocs
PlotFigs
PlotsGroup
PlotsGroupListener
        PlotsCount=0;
        isCreatingNewPlot=false;
        isDeletingOldPlot=false;


OptionsDoc
OptionsFig
OptionsFigLayout


        PlotOptionsPanels={[],[],[]};
        PlotOptionsTables={[],[],[]};
        PlotOptionsTitleLabels={[],[],[]};
        PlotOptionsFilterButtons={[],[],[]};
        PlotOptionsFilterCheckboxes={[],[],[]};
DisplayedTablesAndNodes


ToolstripFilterFigure
ToolstripFilterTree
        PlotOptionsFilterFigures={[],[],[]};
        PlotOptionsFilters={[],[],[]};

PlotOptionsFilterCheckedNodes
        PlotOptionsFilterCheckedNodesChanged=false;


setPlotScalesFigure
setPlotScalesRadioButton_xLinear
setPlotScalesRadioButton_yLinear
setPlotScalesRadioButton_xLog
setPlotScalesRadioButton_yLog


        oldDataDB=[];
oldDBindex
oldDB
newDB
oldSimIndex
oldSim
newSim
oldSimName
newSimName
oldNodeDB
oldNodeSim
oldCornerTable
oldCornerTableIndex
oldFilterFigure
    end

    properties(Hidden)
Listeners

AllFigures
PlotsFig_All
NonPlotFigures

MixedSignalAnalyzerTool
ClientActionListener

        ClosingAppContainer=false;

        editedIsChecked=[];
        editedRowNumber=[];
        editedRowCorner=[];
        editedRowCorner2=[];
    end

    events
UpdateCustomGalleryListeners
    end

    properties(Constant,Hidden)
        PPSS=get(0,'ScreenSize')
        DPSS=ismac*msblks.internal.apps.mixedsignalanalyzer.View.PPSS+...
        ~ismac*matlab.ui.internal.PositionUtils.getDevicePixelScreenSize
        PixelRatio=...
        msblks.internal.apps.mixedsignalanalyzer.View.DPSS(4)/msblks.internal.apps.mixedsignalanalyzer.View.PPSS(4)
        AppSize=[1100,1000]*msblks.internal.apps.mixedsignalanalyzer.View.PixelRatio

        MetricsText=getString(message('msblks:mixedsignalanalyzer:MetricsText'));
        AnalysisMetricsText=getString(message('msblks:mixedsignalanalyzer:AnalysisMetricsRootNodeText'));
        AnalysisWaveformsText=getString(message('msblks:mixedsignalanalyzer:AnalysisWaveformsRootNodeText'));


        ColumnCheckboxText=getString(message('msblks:mixedsignalanalyzer:ColumnCheckboxText'));
        ColumnWaveformNameText=getString(message('msblks:mixedsignalanalyzer:ColumnWaveformNameText'));
        ColumnCornerText=getString(message('msblks:mixedsignalanalyzer:ColumnCornerText'));
        ColumnDataPointText=getString(message('msblks:mixedsignalanalyzer:ColumnDataPointText'));
    end

    methods
        function runAnalysisCustomFunction(obj,path)
            data.path=path;
            e=msblks.internal.apps.mixedsignalanalyzer.ArbitraryEventData(data);
            obj.notify('UpdateCustomGalleryListeners',e);
        end


        function obj=View(name,mixedsignalanalysis)
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;


            set(0,'DefaultTextInterpreter','none');

            obj.Toolstrip=msblks.internal.apps.mixedsignalanalyzer.Toolstrip(obj);
            obj.enableFilterActions(false);
            obj.enableAnalysisActions(false);
            obj.enableMetricsActions(false);


            group=FigureDocumentGroup();
            group.Title="Data";
            group.Tag="data";
            obj.Toolstrip.appContainer.add(group);
            documentOptions.Title=getString(message('msblks:mixedsignalanalyzer:DataText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="DataFig";
            obj.DataDoc=FigureDocument(documentOptions);
            obj.DataDoc.Closable=false;
            obj.Toolstrip.appContainer.add(obj.DataDoc);
            obj.DataFig=obj.DataDoc.Figure;
            obj.DataFig.AutoResizeChildren='off';
            obj.DataFigLayout=uigridlayout(obj.DataFig,'RowHeight',{'1x'},'ColumnWidth',{'1x'},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            obj.AllFigures=obj.DataFig;


            obj.DataTree=uitree(obj.DataFigLayout,'Multiselect','on','Tag','DataTree');

            obj.DataTree.SelectionChangedFcn=@obj.treeCheckedNodeChanged;


            group=FigureDocumentGroup();
            group.Title="Plots";
            group.Tag="plots";
            obj.Toolstrip.appContainer.add(group);
            documentOptions.Title=getString(message('msblks:mixedsignalanalyzer:PlotsText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="BlankPlotFig";
            obj.BlankPlotDoc=FigureDocument(documentOptions);
            obj.BlankPlotDoc.Closable=false;
            obj.Toolstrip.appContainer.add(obj.BlankPlotDoc);
            obj.BlankPlotFig=obj.BlankPlotDoc.Figure;
            obj.BlankPlotFig.AutoResizeChildren='off';
            obj.AllFigures(end+1)=obj.BlankPlotFig;
            obj.PlotsGroup=group;
            obj.PlotsGroupListener=addlistener(group,'PropertyChanged',@(h,e)plotSelectedFcn(obj,group));
            obj.BlankPlotDoc.Phantom=false;
            pause(2.0);


            group=FigureDocumentGroup();
            group.Title="Options";
            group.Tag="options";
            obj.Toolstrip.appContainer.add(group);
            documentOptions.Title=getString(message('msblks:mixedsignalanalyzer:PlotOptionsText'));
            documentOptions.DocumentGroupTag=group.Tag;
            documentOptions.Tag="OptionsFig";
            obj.OptionsDoc=FigureDocument(documentOptions);
            obj.OptionsDoc.Closable=false;
            obj.Toolstrip.appContainer.add(obj.OptionsDoc);
            obj.OptionsFig=obj.OptionsDoc.Figure;
            obj.OptionsFig.AutoResizeChildren='off';
            obj.OptionsFigLayout=uigridlayout(obj.OptionsFig,'RowHeight',{'1x'},'ColumnWidth',{'1x'},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            obj.AllFigures(end+1)=obj.OptionsFig;




            filterFigure=uifigure('Visible','off',...
            'Name',getString(message('msblks:mixedsignalanalyzer:ToolstripFilterDialogTitleText')),...
            'CloseRequestFcn',@obj.hideFilter);
            filterGridLayout=uigridlayout(filterFigure,'RowHeight',{'1x',22},'ColumnWidth',{'1x',100,100,100},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            filterTree=uitree(filterGridLayout,'checkbox');
            okButton=uibutton('Parent',filterGridLayout,...
            'Text',getString(message('msblks:mixedsignalanalyzer:OkText')),...
            'Tooltip',getString(message('msblks:mixedsignalanalyzer:FilterTip')),...
            'ButtonPushedFcn',@obj.applyAndHideFilter,...
            'Tag','okButton');
            cancelButton=uibutton('Parent',filterGridLayout,...
            'Text',getString(message('msblks:mixedsignalanalyzer:CancelText')),...
            'ButtonPushedFcn',@obj.hideFilter,...
            'Tag','cancelButton');
            filterTree.Layout.Row=1;
            okButton.Layout.Row=2;
            cancelButton.Layout.Row=2;
            filterTree.Layout.Column=[1,4];
            okButton.Layout.Column=3;
            cancelButton.Layout.Column=4;
            obj.ToolstripFilterFigure=filterFigure;
            obj.ToolstripFilterTree=filterTree;
            obj.AllFigures(end+1)=obj.ToolstripFilterFigure;



            s=settings;
            screensize=get(0,'MonitorPositions');
            if~isempty(s)&&~isempty(screensize)&&...
                isprop(s,'msblks')&&...
                isprop(s.msblks,'MixedSignalAnalyzer')&&...
                isprop(s.msblks.MixedSignalAnalyzer,'X')&&...
                isprop(s.msblks.MixedSignalAnalyzer,'Y')&&...
                isprop(s.msblks.MixedSignalAnalyzer,'Width')&&...
                isprop(s.msblks.MixedSignalAnalyzer,'Height')


                X=s.msblks.MixedSignalAnalyzer.X.ActiveValue;
                Y=s.msblks.MixedSignalAnalyzer.Y.ActiveValue;
                Width=s.msblks.MixedSignalAnalyzer.Width.ActiveValue;
                Height=s.msblks.MixedSignalAnalyzer.Height.ActiveValue;


                Xmin=screensize(1,1);
                Ymin=screensize(1,2);
                Xmax=screensize(1,3);
                Ymax=screensize(1,4);
                if numel(screensize)>4

                    for i=2:numel(screensize)/4
                        Xmax=Xmax+screensize(i,3);
                        if X<Xmax
                            Ymax=screensize(i,4);
                            break;
                        end
                    end
                end


                if X<Xmin||X>=Xmax
                    X=s.msblks.MixedSignalAnalyzer.X.FactoryValue;
                end
                if Y<Ymin||Y>=Ymax
                    Y=s.msblks.MixedSignalAnalyzer.Y.FactoryValue;
                end


                if Width<400||Width>Xmax-Xmin
                    Width=s.msblks.MixedSignalAnalyzer.Width.FactoryValue;
                end
                if Height<400||Height>Ymax-Ymin
                    Height=s.msblks.MixedSignalAnalyzer.Height.FactoryValue;
                end


                if X+Width>Xmax
                    X=Xmax-Width;
                end
                if Y+Height>Ymax
                    Y=Ymax-Height;
                end


                if~isempty(obj.Toolstrip)&&...
                    ~isempty(obj.Toolstrip.appContainer)&&...
                    isprop(obj.Toolstrip.appContainer,'WindowBounds')
                    obj.Toolstrip.appContainer.WindowBounds=[X,Y,Width,Height];
                end
            end
            drawAndPause(0.3);
            obj.addNewPlot();


            obj.createMetricsPlotOptionsTable();
            obj.createWaveformsPlotLegendAndVisibilityTable();
            obj.clearPlotOptions();
        end


        function addNewPlot(obj,varargin)

            obj.Toolstrip.PlotListItem_SetPlotScales.Enabled=true;


            obj.isCreatingNewPlot=true;
            obj.PlotsCount=obj.PlotsCount+1;
            obj.getFigureHandle(['Plot ',num2str(obj.PlotsCount)]);
            drawAndPause(2.0);
            if nargin>1
                obj.PlotDocs{end}.Title=varargin{1};
            end
            obj.isCreatingNewPlot=false;
            for j=1:length(obj.PlotDocs)

                if~isempty(obj.PlotDocs{j})&&isvalid(obj.PlotDocs{j})
                    obj.PlotDocs{j}.Selected=(j==length(obj.PlotDocs));
                end
            end
            obj.togglePlotGrid();
            obj.clearPlotOptions();
            obj.MixedSignalAnalyzerTool.Model.IsChanged=true;
        end
        function togglePlotGrid(obj)
            [fig,doc]=obj.getSelectedPlot();
            if~isempty(fig)&&~isempty(doc)
                if fig.CurrentAxes.XGrid=='off' %#ok<BDSCA>
                    grid(fig.CurrentAxes,'on');
                    if strcmpi(fig.CurrentAxes.XScale,'log')
                        fig.CurrentAxes.XMinorGrid='on';
                    end
                    if strcmpi(fig.CurrentAxes.YScale,'log')
                        fig.CurrentAxes.YMinorGrid='on';
                    end
                else
                    grid(fig.CurrentAxes,'off');
                end
                obj.MixedSignalAnalyzerTool.Model.IsChanged=true;
            end
        end
        function addPlotMargins(obj)
            [fig,doc]=obj.getSelectedPlot();
            if~isempty(fig)&&~isempty(doc)
                figAxes=fig.CurrentAxes;

                xlim(figAxes,'auto');
                ylim(figAxes,'auto');

                if strcmpi(figAxes.XScale,'linear')

                    minMax=xlim(figAxes);
                    margin=diff(minMax)*0.025;
                    xlim(figAxes,[minMax(1)-margin,minMax(2)+margin]);
                end

                if strcmpi(figAxes.YScale,'linear')

                    minMax=ylim(figAxes);
                    margin=diff(minMax)*0.025;
                    ylim(figAxes,[minMax(1)-margin,minMax(2)+margin]);
                end
            end
        end
        function renamePlot(obj)
            [fig,doc]=obj.getSelectedPlot();
            if~isempty(fig)&&~isempty(doc)
                dlgPrompt=getString(message('msblks:mixedsignalanalyzer:PlotBtn'));
                dlgTitle=getString(message('msblks:mixedsignalanalyzer:PlotListItem_RenamePlot'));
                dlgSize=[1,40];
                dlgDefault=doc.Title;
                reply=inputdlg(dlgPrompt,dlgTitle,dlgSize,dlgDefault);
                if isempty(reply)||isempty(reply{1})

                    msg=getString(message('msblks:mixedsignalanalyzer:BlankPlotNameMessage'));
                    title=getString(message('msblks:mixedsignalanalyzer:BlankPlotNameTitle'));
                    uialert(fig,msg,title);
                    return;
                end
                if~strcmp(reply{1},doc.Title)

                    for i=1:length(obj.PlotDocs)
                        if obj.PlotDocs{i}~=doc&&strcmp(obj.PlotDocs{i}.Title,reply{1})

                            msg=getString(message('msblks:mixedsignalanalyzer:DuplicatePlotNameMessage',reply{1}));
                            title=getString(message('msblks:mixedsignalanalyzer:DuplicatePlotNameTitle'));
                            uialert(fig,msg,title);
                            return;
                        end
                    end
                    doc.Title=reply{1};
                    obj.PlotOptionsTitleLabels{3}.Text=doc.Title;
                    obj.PlotOptionsFilterFigures{3}.Name=doc.Title;
                    obj.MixedSignalAnalyzerTool.Model.IsChanged=true;
                end
            end
        end
        function setPlotScales(obj)
            [fig,doc]=obj.getSelectedPlot();
            if~isempty(fig)&&~isempty(doc)

                if isempty(obj.setPlotScalesFigure)||~isvalid(obj.setPlotScalesFigure)
                    obj.createPlotScalesDialog();
                end

                figAxes=fig.CurrentAxes;
                if~isempty(figAxes)&&isvalid(figAxes)
                    isLinearX=strcmpi(figAxes.XScale,'linear');
                    isLinearY=strcmpi(figAxes.YScale,'linear');
                    obj.setPlotScalesRadioButton_xLinear.Value=isLinearX;
                    obj.setPlotScalesRadioButton_yLinear.Value=isLinearY;
                    obj.setPlotScalesRadioButton_xLog.Value=~isLinearX;
                    obj.setPlotScalesRadioButton_yLog.Value=~isLinearY;
                end

                obj.setPlotScalesFigure.Visible='on';
            end
        end
        function createPlotScalesDialog(obj)
            if~isempty(obj.setPlotScalesFigure)&&~isvalid(obj.setPlotScalesFigure)
                obj.setPlotScalesFigure=[];
            end
            if isempty(obj.setPlotScalesFigure)
                height=20;
                width=80;
                fig=uifigure('Name',getString(message('msblks:mixedsignalanalyzer:PlotListItem_SetPlotScales')),...
                'Visible','off','WindowStyle','modal');
                position=fig.Position;
                fig.Position=[position(1),position(2),300,100];
                fig.Resize='off';
                gridLayout=uigridlayout(fig,'RowHeight',{'1x','1x','1x','1x','1x'},...
                'ColumnWidth',{'1x','1x','1x','1x'},...
                'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
                xLabel=uilabel('Parent',gridLayout,'Text','X Axis:','HorizontalAlignment','center');
                yLabel=uilabel('Parent',gridLayout,'Text','Y Axis:','HorizontalAlignment','center');
                xGroup=uibuttongroup('Parent',gridLayout,'BorderType','none');
                yGroup=uibuttongroup('Parent',gridLayout,'BorderType','none');
                xLinear=uiradiobutton('Parent',xGroup,'Text','Linear','Position',[5,0,width,height]);
                yLinear=uiradiobutton('Parent',yGroup,'Text','Linear','Position',[5,0,width,height]);
                xLog=uiradiobutton('Parent',xGroup,'Text','Log','Position',[width,0,width,height]);
                yLog=uiradiobutton('Parent',yGroup,'Text','Log','Position',[width,0,width,height]);
                ok=uibutton(gridLayout,'Text','OK');
                cancel=uibutton(gridLayout,'Text','Cancel');

                xLabel.Layout.Row=2;
                yLabel.Layout.Row=3;
                xGroup.Layout.Row=2;
                yGroup.Layout.Row=3;
                xLabel.Layout.Column=1;
                yLabel.Layout.Column=1;
                xGroup.Layout.Column=[2,4];
                yGroup.Layout.Column=[2,4];
                ok.Layout.Row=5;
                ok.Layout.Column=3;
                cancel.Layout.Row=5;
                cancel.Layout.Column=4;

                ok.ButtonPushedFcn=@(h,e)obj.applyPlotScalesDialog();
                cancel.ButtonPushedFcn=@(h,e)obj.closePlotScalesDialog();

                obj.setPlotScalesFigure=fig;
                obj.setPlotScalesRadioButton_xLinear=xLinear;
                obj.setPlotScalesRadioButton_yLinear=yLinear;
                obj.setPlotScalesRadioButton_xLog=xLog;
                obj.setPlotScalesRadioButton_yLog=yLog;
            end
        end
        function applyPlotScalesDialog(obj)
            [fig,doc]=obj.getSelectedPlot();
            if~isempty(fig)&&~isempty(doc)

                figAxes=fig.CurrentAxes;
                if~isempty(figAxes)&&isvalid(figAxes)
                    isLinearX=strcmpi(figAxes.XScale,'linear');
                    isLinearY=strcmpi(figAxes.YScale,'linear');
                    if obj.setPlotScalesRadioButton_xLinear.Value~=isLinearX

                        if isLinearX
                            figAxes.XScale='log';
                        else
                            figAxes.XScale='linear';
                        end
                    end
                    if obj.setPlotScalesRadioButton_yLinear.Value~=isLinearY

                        if isLinearY
                            figAxes.YScale='log';
                        else
                            figAxes.YScale='linear';
                        end
                    end
                end
            end

            obj.closePlotScalesDialog();
        end
        function closePlotScalesDialog(obj)

            if~isempty(obj.setPlotScalesFigure)&&isvalid(obj.setPlotScalesFigure)
                obj.setPlotScalesFigure.Visible='off';
            end
        end
        function[fig,doc]=getSelectedPlot(obj)
            drawnow limitrate;
            pause(0.3);

            if isempty(obj)||~isvalid(obj)||isempty(obj.PlotsGroup)||~isvalid(obj.PlotsGroup)
                fig=[];
                doc=[];
                return;
            end
            selectedFigureTag=obj.PlotsGroup.LastSelected;
            if~isempty(selectedFigureTag)
                selectedFigureTag=selectedFigureTag.tag;
            end
            if~isempty(selectedFigureTag)&&~isempty(obj.PlotDocs)&&~isempty(obj.PlotFigs)

                for i=1:min(length(obj.PlotDocs),length(obj.PlotFigs))
                    if strcmp(obj.PlotDocs{i}.Tag,selectedFigureTag)
                        fig=obj.PlotFigs{i};
                        doc=obj.PlotDocs{i};
                        return;
                    end
                end
            elseif~isempty(obj.PlotFigs)

                fig=obj.PlotFigs{end};
                doc=obj.PlotDocs{end};
                if~isempty(fig)&&isvalid(fig)
                    figure(fig);
                else
                    obj.addNewPlot();
                    drawnow limitrate;
                    pause(0.5);
                    fig=obj.PlotFigs{end};
                    doc=obj.PlotDocs{end};
                end
                return;
            end
            fig=[];
            doc=[];
        end
        function[docHandle,figHandle]=getFigureHandle(obj,figureTitle)
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;

            if isempty(obj.PlotFigs)

                documentOptions.Title=figureTitle;
                documentOptions.DocumentGroupTag="plots";
                documentOptions.Tag=figureTitle;
                obj.PlotDocs{1}=FigureDocument(documentOptions);
                obj.Toolstrip.appContainer.add(obj.PlotDocs{1});
                obj.PlotFigs{1}=obj.PlotDocs{1}.Figure;
                obj.AllFigures(end+1)=obj.PlotFigs{1};
                obj.Toolstrip.addPlotToLayout(figureTitle);
                docHandle=obj.PlotDocs{1};
                figHandle=obj.PlotFigs{1};
            else

                for i=1:length(obj.PlotDocs)
                    if strcmpi(obj.PlotDocs{i}.Title,figureTitle)
                        docHandle=obj.PlotDocs{i};
                        figHandle=obj.PlotFigs{i};
                        return;
                    end
                end

                documentOptions.Title=figureTitle;
                documentOptions.DocumentGroupTag="plots";
                documentOptions.Tag=figureTitle;
                obj.PlotDocs{end+1}=FigureDocument(documentOptions);
                obj.Toolstrip.appContainer.add(obj.PlotDocs{end});
                obj.PlotFigs{end+1}=obj.PlotDocs{end}.Figure;
                obj.AllFigures(end+1)=obj.PlotFigs{end};
                obj.Toolstrip.addPlotToLayout(figureTitle);
                docHandle=obj.PlotDocs{end};
                figHandle=obj.PlotFigs{end};
            end
            if isempty(figHandle.CurrentAxes)

                figHandle.CurrentAxes=axes('Parent',figHandle);
                plot(figHandle.CurrentAxes,0,0);
            end
            docHandle.CanCloseFcn=@(h,e)plotCloseRequestFcn(obj,figHandle);
            figHandle.AutoResizeChildren='off';
            figHandle.SizeChangedFcn=@(h,e)plotSizeChangedFcn(obj,figHandle);
            figHandle.ButtonDownFcn=@(h,e)plotSelectedFcn(obj,figHandle);
            figHandle.WindowButtonDownFcn=@(h,e)plotSelectedFcn(obj,figHandle);
            obj.BlankPlotDoc.Phantom=true;
        end
        function plotSizeChangedFcn(obj,selectedFigure)

            if~isvalid(obj)||obj.isCreatingNewPlot||obj.ClosingAppContainer
                return;
            end
            if~isempty(selectedFigure)&&~isempty(selectedFigure.UserData)
                if obj.isWaveformPlot(selectedFigure)

                    return;
                else

                    for i=1:length(selectedFigure.Children)
                        if strcmpi(selectedFigure.Children(i).Type,'axes')

                            figAxes=selectedFigure.Children(i);
                            if~isempty(figAxes.UserData)
                                delete(figAxes.UserData{1});
                                figAxes.UserData{1}=[];
                                xAxisLabelsString=figAxes.UserData{2};
                                msblks.internal.apps.mixedsignalanalyzer.View.setXAxisLabels(figAxes,xAxisLabelsString);
                            end
                            return;
                        end
                    end
                end
            end
        end
        function plotSelectedFcn(obj,selectedFigure)

            drawnow limitrate;

            if~isvalid(obj)||obj.isCreatingNewPlot
                return;
            end
            obj.MixedSignalAnalyzerTool.Model.IsChanged=true;
            obj.clearPlotOptions();
            if isa(selectedFigure,'matlab.ui.internal.FigureDocumentGroup')
                if obj.isDeletingOldPlot
                    selectedFigure=obj.getSelectedPlot();
                    if isempty(selectedFigure)&&~isempty(obj.PlotFigs)

                        figure(obj.PlotFigs{end});

                    end
                    obj.isDeletingOldPlot=false;
                    if~isempty(obj.PlotFigs)&&~isempty(obj.PlotDocs)

                        obj.Toolstrip.PlotListItem_SetPlotScales.Enabled=obj.isWaveformPlot(selectedFigure);
                        return;
                    else

                        obj.PlotFigs=[];
                        obj.PlotDocs=[];
                        obj.PlotsCount=0;
                        obj.addNewPlot();
                    end
                end

                selectedFigure=obj.getSelectedPlot();
            end

            obj.Toolstrip.PlotListItem_SetPlotScales.Enabled=true;


            if~isempty(selectedFigure)&&~isempty(selectedFigure.UserData)
                if obj.isWaveformPlot(selectedFigure)

                    obj.showPlotOptions(selectedFigure.UserData);

                    obj.loadWaveformLegendAndVisibilityTable(selectedFigure.UserData{1});
                else

                    obj.Toolstrip.PlotListItem_SetPlotScales.Enabled=false;




                    obj.showPlotOptions(selectedFigure.UserData(1));
                    obj.loadTrendChartWidgets(...
                    selectedFigure.UserData{2},...
                    selectedFigure.UserData{3},...
                    selectedFigure.UserData{4},...
                    selectedFigure.UserData{5},...
                    selectedFigure.UserData{6},...
                    selectedFigure.UserData{7},...
                    selectedFigure.UserData{8},...
                    selectedFigure.UserData{9},...
                    selectedFigure.UserData{10},...
                    []);




                end
                drawnow;
            end
        end
        function isOnlyUITables=isWaveformPlot(obj,selectedFigure)

            if isempty(selectedFigure)
                selectedFigure=obj.getSelectedPlot();
            end
            if isempty(selectedFigure)||isempty(selectedFigure.UserData)
                isOnlyUITables=false;
                return;
            end
            for i=1:length(selectedFigure.UserData)
                if i==1&&...
                    iscell(selectedFigure.UserData{1})&&...
                    isstruct(selectedFigure.UserData{1}{1})&&...
                    strcmp(selectedFigure.UserData{1}{1}.Type,'uitable')
                    continue;
                end

                if~isa(selectedFigure.UserData{i},'msblks.internal.apps.mixedsignalanalyzer.uitableStruct')
                    isOnlyUITables=false;
                    return;
                end
            end
            isOnlyUITables=true;
        end
        function updateMetricFilterTree(obj,metricFilterTree,plotList,xAxisList,legendList)

            checkedNodes=[];
            for i=1:length(metricFilterTree.Children.Children)
                node=metricFilterTree.Children.Children(i);
                if any(strcmp(plotList.Items,node.Text))||...
                    any(strcmp(xAxisList.Items,node.Text))||...
                    any(strcmp(legendList.Items,node.Text))
                    if isempty(checkedNodes)
                        checkedNodes=node;
                    else
                        checkedNodes(end+1)=node;%#ok<AGROW>
                    end
                end
            end
            metricFilterTree.CheckedNodes=checkedNodes;
        end
        function result=plotCloseRequestFcn(obj,selectedFigure)


            if isempty(obj)||~isvalid(obj)
                result=true;
                return;
            end
            result=obj.ClosingAppContainer;
            if result
                return;
            end
            obj.isDeletingOldPlot=true;
            if~isempty(obj.PlotFigs)
                for i=1:length(obj.PlotFigs)
                    if obj.PlotFigs{i}==selectedFigure

                        if length(selectedFigure.UserData)<10
                            for j=1:length(selectedFigure.UserData)
                                if isa(selectedFigure.UserData{j},'matlab.ui.container.Panel')
                                    offset=-1;
                                else
                                    offset=0;
                                end
                                table=selectedFigure.UserData{j};
                                if~isempty(table)&&~iscell(table)&&isvalid(table)
                                    titles=convertCharsToStrings(table.UserData{8+offset});
                                    for k=length(titles):-1:1
                                        if strcmp(titles{k},obj.PlotDocs{i}.Title)
                                            table.UserData{6+offset}(k)=[];
                                            table.UserData{7+offset}(k,:)=[];
                                            table.UserData{8+offset}(k)=[];
                                        end
                                    end
                                end
                            end
                        end

                        if length(obj.PlotDocs)<=1
                            obj.BlankPlotDoc.Phantom=false;
                        end
                        obj.Toolstrip.removePlotFromLayout(obj.PlotDocs{i}.Title);
                        obj.PlotDocs{i}.CanCloseFcn=[];
                        obj.PlotDocs(i)=[];
                        obj.PlotFigs(i)=[];
                        break;
                    end
                end
            end
            result=true;
        end


        function enableFilterActions(obj,enabled)
            if~isempty(obj.Toolstrip)&&~isempty(obj.Toolstrip.FilterBtn)
                obj.Toolstrip.FilterBtn.Enabled=enabled;
            end
        end
        function enableAnalysisActions(obj,enabled)
            if~isempty(obj.Toolstrip)&&~isempty(obj.Toolstrip.AnalysisButtons)
                for i=1:length(obj.Toolstrip.AnalysisButtons)



                    obj.Toolstrip.AnalysisButtons{i}.Enabled=enabled;

                end
            end

            if~isempty(obj.Toolstrip)&&~isempty(obj.Toolstrip.AnalysisCustomButtons)
                for i=1:length(obj.Toolstrip.AnalysisCustomButtons)




                    obj.Toolstrip.AnalysisCustomButtons(i).Enabled=enabled;
                end
            end

        end
        function enableMetricsActions(obj,enabled)
            if~isempty(obj.Toolstrip)&&~isempty(obj.Toolstrip.MetricsButtons)
                for i=1:length(obj.Toolstrip.MetricsButtons)
                    if enabled&&i>1
                        break;
                    end
                    obj.Toolstrip.MetricsButtons{i}.Enabled=enabled;
                end
            end
        end
    end

    methods(Hidden)
        function filterAction(obj,~)

            selectedNodes=obj.DataTreeCheckedNodes;
            if isempty(selectedNodes)||~any(isvalid(selectedNodes))||...
                isempty(obj.ToolstripFilterTree)||~isvalid(obj.ToolstripFilterTree)
                return;
            end
            selectedNodesPerTable{length(obj.PlotOptionsFilterFigures)}=[];
            for i=1:length(selectedNodes)
                if isempty(selectedNodes(i))||~isvalid(selectedNodes(i))||...
                    length(selectedNodes(i).NodeData)<5||...
                    strcmp(selectedNodes(i).Parent.Text,obj.MetricsText)||...
                    strcmp(selectedNodes(i).Parent.Text,obj.AnalysisMetricsText)
                    continue;
                end
                dbIndex=selectedNodes(i).NodeData{1};
                simName=selectedNodes(i).NodeData{2};
                nodName=selectedNodes(i).NodeData{3};
                if length(selectedNodes(i).NodeData)==5
                    if~iscell(selectedNodes(i).NodeData{5})&&...
                        strcmpi(selectedNodes(i).NodeData{5},'Analysis Waveform')
                        nodName=selectedNodes(i).Text;
                    else
                        fncName=selectedNodes(i).NodeData{4};

                        nodName=[fncName,'.',nodName];%#ok<AGROW>
                    end
                end
                for j=4:length(obj.PlotOptionsTables)
                    if obj.PlotOptionsTables{j}.UserData{1}==dbIndex&&...
                        strcmpi(obj.PlotOptionsTables{j}.UserData{2},simName)
                        if isempty(selectedNodesPerTable{j})
                            selectedNodesPerTable{j}{1}=nodName;
                        elseif~any(strcmpi(selectedNodesPerTable{j},nodName))
                            selectedNodesPerTable{j}{end+1}=nodName;
                        end
                        break;
                    end
                end
            end

            filterFigure=obj.ToolstripFilterFigure;
            filterTree=obj.ToolstripFilterTree;


            filterTreeParent=filterTree.Parent;
            filterTree.Parent=[];

            if~isempty(filterTree.Children)&&any(isvalid(filterTree.Children))
                delete(filterTree.Children);
            end
            lastDbIndex=0;
            for i=3:length(selectedNodesPerTable)
                if isempty(selectedNodesPerTable{i})
                    continue;
                end
                dbIndex=obj.PlotOptionsTables{i}.UserData{1};
                if dbIndex~=lastDbIndex
                    lastDbIndex=dbIndex;
                    db=obj.DataDB(dbIndex);
                    dbRoot=uitreenode(filterTree,'Text',db.matFileName,'NodeData',{filterFigure,filterTree});
                end
                nodeList=selectedNodesPerTable{i}{1};
                for j=2:length(selectedNodesPerTable{i})
                    nodeList=[nodeList,', ',selectedNodesPerTable{i}{j}];%#ok<AGROW>
                end




                simRoot=uitreenode(dbRoot,'Text',obj.PlotOptionsTables{i}.UserData{2});
                nodesRoot=uitreenode(simRoot,'Text',nodeList,'NodeData',i);

                paramNames=obj.PlotOptionsFilters{i}.Children.Children;
                for j=1:length(paramNames)
                    paramRoot=uitreenode(nodesRoot,'Text',paramNames(j).Text,'NodeData','ColumnName');
                    paramValues=paramNames(j).Children;
                    leafNodes(length(paramValues))=uitreenode(paramRoot,'Text',paramValues(1).Text,'NodeData',paramValues(1));%#ok<AGROW>
                    for k=2:length(paramValues)
                        leafNodes(k-1)=uitreenode(paramRoot,'Text',paramValues(k).Text,'NodeData',paramValues(k));
                    end
                end
            end
            if isempty(filterTree.Children)||any(~isvalid(filterTree.Children))
                filterTree.Parent=filterTreeParent;
                return;
            end

            filterTree.CheckedNodes=filterTree.Children;
            expand(filterTree);
            for i=1:length(filterTree.Children)
                expand(filterTree.Children(i));
                for j=1:length(filterTree.Children(i).Children)
                    expand(filterTree.Children(i).Children(j));
                    for k=1:length(filterTree.Children(i).Children(j))
                        if strcmpi(filterTree.Children(i).Children(j).Children(k).NodeData,'ColumnName')
                            break;
                        end
                        expand(filterTree.Children(i).Children(j).Children(k));
                    end
                end
            end
            filterTree.Parent=filterTreeParent;
            filterFigure.Visible='on';
            drawnow limitrate;
        end

        function defaultLayoutAction(obj)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyDefaultLayout')));





                obj.Toolstrip.setInitialLayout();























            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
        end















        function addDatabaseToDataTree(obj,pathname,fileName,waveformsDatabase,updateRequest)
            obj.MixedSignalAnalyzerTool.Model.IsChanged=true;
            if isempty(updateRequest)

                waveformsDB=waveformsDatabase;
                if isempty(obj.DataDB)
                    obj.DataDB=waveformsDB;
                else
                    obj.DataDB(end+1)=waveformsDB;
                end
                indexDB=length(obj.DataDB);
                database=uitreenode(obj.DataTree,'Text',fileName,'NodeData',{indexDB,waveformsDB});
            else

                indexDB=updateRequest{1};
                indexSim=updateRequest{2};

                indexWaveformsSim=updateRequest{4};
                indexPanel2Update=updateRequest{5};


                obj.oldDBindex=indexDB;
                obj.oldDB=obj.oldDataDB{indexDB};
                obj.oldSimIndex=indexSim;
                obj.oldSim=obj.oldDB.SimulationResultsObjects{indexSim};
                obj.oldSimName=obj.oldDB.SimulationResultsNames{indexSim};
                database=obj.DataTree.Children(indexDB);
                simulation=database.Children(indexSim);
                obj.oldNodeDB=database.get;
                obj.oldNodeSim=simulation.get;
                obj.oldCornerTable=[];
                obj.oldCornerTableIndex=0;


                waveformsDB=waveformsDatabase;
                resultsObject=waveformsDB.SimulationResultsObjects{indexWaveformsSim};
                resultsName=waveformsDB.SimulationResultsNames{indexWaveformsSim};
                obj.newDB=waveformsDB;
                obj.newSim=resultsObject;
                obj.newSimName=resultsName;


                obj.DataDB(indexDB)=waveformsDB;



                database.Text=fileName;
                database.NodeData={indexDB,waveformsDB};


                if~isempty(database.Children(indexSim).NodeData)
                    database.Children(indexSim).Text=resultsName;
                    database.Children(indexSim).NodeData={indexDB,resultsName};
                    database=database.Children(indexSim);
                end


                plotsVsTreeNodes=obj.PlotOptionsTables{indexPanel2Update}.UserData{9};
                for i=1:length(plotsVsTreeNodes)
                    for j=length(plotsVsTreeNodes{i}{2}):-1:1
                        if isempty(plotsVsTreeNodes{i}{2}(j))||~isvalid(plotsVsTreeNodes{i}{2}(j))
                            plotsVsTreeNodes{i}{2}(j)=[];
                        end
                    end
                    plotsVsTreeNodes{i}{3}{length(plotsVsTreeNodes{i}{2})}={};
                    for j=1:length(plotsVsTreeNodes{i}{2})
                        plotsVsTreeNodes{i}{3}{j}=plotsVsTreeNodes{i}{2}(j).get;
                    end
                end
                obj.PlotOptionsTables{indexPanel2Update}.UserData{9}=plotsVsTreeNodes;


                for i=1:length(obj.PlotFigs)
                    if length(obj.PlotFigs{i}.UserData)<11||~isa(obj.PlotFigs{i}.UserData{1},'matlab.ui.container.Panel')
                        continue;
                    end
                    yAxisParamNames=obj.PlotFigs{i}.UserData{9};
                    metricCheckedNodes=obj.PlotFigs{i}.UserData{11};
                    for j=length(metricCheckedNodes):-1:1
                        if isempty(metricCheckedNodes(j))||~isvalid(metricCheckedNodes(j))
                            metricCheckedNodes(j)=[];
                            yAxisParamNames(j)=[];
                        end
                    end
                    if length(obj.PlotFigs{i}.UserData{11})~=length(metricCheckedNodes)
                        obj.PlotFigs{i}.UserData{9}=yAxisParamNames;
                        obj.PlotFigs{i}.UserData{11}=metricCheckedNodes;
                    end
                    if isempty(metricCheckedNodes)
                        metricCheckedNodesInStructForm={};
                    else
                        metricCheckedNodesInStructForm{length(metricCheckedNodes)}=[];%#ok<AGROW>
                        for j=1:length(metricCheckedNodes)
                            metricCheckedNodesInStructForm{j}=metricCheckedNodes(j).get;
                            metricCheckedNodesInStructForm{j}.UserData=resultsName;
                        end
                    end
                    obj.PlotFigs{i}.UserData{12}=metricCheckedNodesInStructForm;
                end


                database.Children.delete;
            end
            if isempty(waveformsDB.SimulationResultsObjects)
                if isempty(updateRequest)

                    uitreenode(database,'Text',getString(message('msblks:mixedsignalanalyzer:NoNodenamesAndWaveformsMessage')),'NodeData',{indexDB,[]});
                    obj.DataTreeAnalysisWaveformsRootNodes{indexDB}={};
                    obj.DataTreeAnalysisMetricsRootNodes{indexDB}={};
                end

            elseif~isempty(updateRequest)




                tableName=resultsObject.getParamValue('tableName');
                caseCountPerTable=resultsObject.getParamValue('caseCount');
                pointSweepCountPerTable=resultsObject.getParamValue('pointSweepCount');
                nodesPerTable=resultsObject.getParamValue('nodes');
                waveNodesPerTable=resultsObject.getParamValue('waveNodes');
                waveTypesPerTable=resultsObject.getParamValue('waveTypes');
                cornersPerNode=resultsObject.getParamValue('corners');
                waveformTypesPerTable=resultsObject.getParamValue('waveformTypes');
                normalWfTypesPerTable=resultsObject.getParamValue('normalWaveformTypes');
                designParamsCountPerTable=resultsObject.getParamValue('designParamsCount');
                paramNamesPerTable_ShortMetrics=resultsObject.getParamValue('paramNames_ShortMetrics');
                if isempty(caseCountPerTable)||isempty(pointSweepCountPerTable)
                    obj.addWaveformLeafNodes(tableName,...
                    nodesPerTable,...
                    cornersPerNode,...
                    waveformTypesPerTable,...
                    designParamsCountPerTable,database,indexDB);
                else
                    obj.addWaveformLeafNodes2(tableName,...
                    nodesPerTable,...
                    waveNodesPerTable,...
                    waveTypesPerTable,...
                    normalWfTypesPerTable,...
                    cornersPerNode,...
                    waveformTypesPerTable,...
                    caseCountPerTable,pointSweepCountPerTable,database,indexDB);
                end
                analysisWaveformsNode=uitreenode(database,'Text',obj.AnalysisWaveformsText,'NodeData',{indexDB,waveformsDB,tableName});
                metricsNode=uitreenode(database,'Text',obj.MetricsText,'NodeData',{indexDB,waveformsDB,tableName});
                obj.addMetricLeafNodes(tableName,...
                nodesPerTable,...
                cornersPerNode,...
                paramNamesPerTable_ShortMetrics,...
                designParamsCountPerTable,metricsNode,indexDB);
                analysisMetricsNode=uitreenode(metricsNode,'Text',obj.AnalysisMetricsText,'NodeData',{indexDB,waveformsDB,tableName});
                obj.DataTreeAnalysisWaveformsRootNodes{indexDB}={analysisWaveformsNode};
                obj.DataTreeAnalysisMetricsRootNodes{indexDB}={analysisMetricsNode};
            else

                for i=1:length(waveformsDB.SimulationResultsObjects)
                    tableName=waveformsDB.SimulationResultsObjects{i}.getParamValue('tableName');
                    caseCountPerTable=waveformsDB.SimulationResultsObjects{i}.getParamValue('caseCount');
                    pointSweepCountPerTable=waveformsDB.SimulationResultsObjects{i}.getParamValue('pointSweepCount');
                    nodesPerTable=waveformsDB.SimulationResultsObjects{i}.getParamValue('nodes');
                    waveNodesPerTable=waveformsDB.SimulationResultsObjects{i}.getParamValue('waveNodes');
                    waveTypesPerTable=waveformsDB.SimulationResultsObjects{i}.getParamValue('waveTypes');
                    cornersPerNode=waveformsDB.SimulationResultsObjects{i}.getParamValue('corners');
                    waveformTypesPerTable=waveformsDB.SimulationResultsObjects{i}.getParamValue('waveformTypes');
                    normalWfTypesPerTable=waveformsDB.SimulationResultsObjects{i}.getParamValue('normalWaveformTypes');
                    designParamsCountPerTable=waveformsDB.SimulationResultsObjects{i}.getParamValue('designParamsCount');
                    paramNamesPerTable_ShortMetrics=waveformsDB.SimulationResultsObjects{i}.getParamValue('paramNames_ShortMetrics');
                    if isempty(designParamsCountPerTable)
                        designParamsCountPerTable=0;
                    end
                    if isempty(paramNamesPerTable_ShortMetrics)
                        paramNamesPerTable_ShortMetrics=waveformsDB.SimulationResultsObjects{i}.ParamNames;
                    end
                    if isempty(caseCountPerTable)||isempty(pointSweepCountPerTable)
                        table=uitreenode(database,...
                        'Text',tableName,...
                        'NodeData',{indexDB,tableName});
                        obj.addWaveformLeafNodes(tableName,...
                        nodesPerTable,...
                        cornersPerNode,...
                        waveformTypesPerTable,...
                        designParamsCountPerTable,table,indexDB);
                    else
                        cornerCount=caseCountPerTable/pointSweepCountPerTable;
                        if isnan(cornerCount)
                            cornerCount=0;
                        end
                        if strcmpi(waveformsDB.sourceType,'table')||...
                            strcmpi(waveformsDB.sourceType,'.csv')||...
                            strcmpi(waveformsDB.sourceType,'.xlsx')
                            rowCount=waveformsDB.SimulationResultsObjects{i}.getParamValue('caseCount');
                            colCount=length(waveformsDB.SimulationResultsObjects{i}.ParamNames)-12;
                            info=getString(message('msblks:mixedsignalanalyzer:NodenameAndDatabaseInfo3',...
                            tableName,num2str(rowCount),num2str(colCount)));
                        else
                            info=getString(message('msblks:mixedsignalanalyzer:NodenameAndDatabaseInfo2',...
                            tableName,num2str(caseCountPerTable),num2str(pointSweepCountPerTable),num2str(cornerCount)));
                        end
                        table=uitreenode(database,'Text',info,...
                        'NodeData',{indexDB,tableName});
                        obj.addWaveformLeafNodes2(tableName,...
                        nodesPerTable,...
                        waveNodesPerTable,...
                        waveTypesPerTable,...
                        normalWfTypesPerTable,...
                        cornersPerNode,...
                        waveformTypesPerTable,...
                        caseCountPerTable,pointSweepCountPerTable,table,indexDB);
                    end
                    analysisWaveformsNode=uitreenode(table,'Text',obj.AnalysisWaveformsText,'NodeData',{indexDB,waveformsDB,tableName});
                    metricsNode=uitreenode(table,'Text',obj.MetricsText,'NodeData',{indexDB,waveformsDB,tableName});
                    obj.addMetricLeafNodes(tableName,...
                    nodesPerTable,...
                    cornersPerNode,...
                    paramNamesPerTable_ShortMetrics,...
                    designParamsCountPerTable,metricsNode,indexDB);
                    analysisMetricsNode=uitreenode(metricsNode,'Text',obj.AnalysisMetricsText,'NodeData',{indexDB,waveformsDB,tableName});
                    if i==1
                        obj.DataTreeAnalysisWaveformsRootNodes{indexDB}={analysisWaveformsNode};
                        obj.DataTreeAnalysisMetricsRootNodes{indexDB}={analysisMetricsNode};
                    else
                        obj.DataTreeAnalysisWaveformsRootNodes{indexDB}{end+1}=analysisWaveformsNode;
                        obj.DataTreeAnalysisMetricsRootNodes{indexDB}{end+1}=analysisMetricsNode;
                    end
                end
            end

            obj.DataTree.SelectedNodes=database;
            obj.treeCheckedNodeChanged();
            expand(obj.DataTree,'All');



            if~isempty(obj.DataDB)&&~isempty(obj.DataDB(indexDB))
                for i=1:length(obj.DataDB(indexDB).SimulationResultsObjects)
                    obj.DataDB(indexDB).SimulationResultsObjects{i}.setParam('wfDBIndex',indexDB);
                end
            end

            obj.MixedSignalAnalyzerTool.Model.enableNewSaveUpdateToolstripButtons();
        end
        function addWaveformLeafNodes(obj,table,nodes,corners,types,designParamsCount,parentNode,indexDB)

            if isempty(nodes)
                uitreenode(parentNode,'Text',getString(message('msblks:mixedsignalanalyzer:NoNodenamesAndWaveformsMessage2')),'NodeData',{indexDB,table,[]});
            else
                for i=1:length(types)
                    typeNode=uitreenode(parentNode,'Text',types{i});
                    for j=1:length(nodes)

                        uitreenode(typeNode,...
                        'Text',getString(message('msblks:mixedsignalanalyzer:NodenameAndDatabaseInfo',...
                        nodes{j},num2str(designParamsCount),num2str(length(corners)))),...
                        'NodeData',{indexDB,table,nodes{j},types{i},corners});
                    end
                end
            end
        end
        function addWaveformLeafNodes2(obj,table,nodes,waveNodes,waveTypes,normalTypes,corners,types,caseCount,pointSweepCount,parentNode,indexDB)

            if isempty(nodes)
                uitreenode(parentNode,'Text',getString(message('msblks:mixedsignalanalyzer:NoNodenamesAndWaveformsMessage2')),'NodeData',{indexDB,table,[]});
            else
                for i=1:length(types)
                    typeNode=uitreenode(parentNode,'Text',types{i});
                    for j=1:length(nodes)






                        include=true;
                        isWaveNode=false;
                        if~isempty(waveNodes)&&any(strcmp(waveNodes,nodes{j}))

                            for k=1:length(waveNodes)
                                if strcmp(nodes{j},waveNodes{k})
                                    if~strcmp(types{i},waveTypes{k})
                                        include=false;
                                    end
                                    isWaveNode=true;
                                    break;
                                end
                            end
                        end
                        if~isWaveNode&&include

                            include=false;
                            for k=1:length(normalTypes)
                                if strcmp(types{i},normalTypes{k})
                                    include=true;
                                    break;
                                end
                            end
                        end
                        if include
                            uitreenode(typeNode,...
                            'Text',nodes{j},...
                            'NodeData',{indexDB,table,nodes{j},types{i},corners});
                        end
                    end
                end
            end
        end
        function addMetricLeafNodes(obj,table,nodes,corners,paramNames,designParamsCount,parentNode,indexDB)

            if length(paramNames)<=designParamsCount||...
                iscell(paramNames)&&length(paramNames)==1&&isempty(paramNames{1})
                uitreenode(parentNode,'Text',getString(message('msblks:mixedsignalanalyzer:NoMetricsMessage')),'NodeData',{indexDB,table,[]});
            else
                for i=designParamsCount+1:length(paramNames)














                    if isempty(corners)||all(strcmpi(corners,'Nominal'))
                        uitreenode(parentNode,'Text',[paramNames{i},' (',getString(message('msblks:mixedsignalanalyzer:NoCornerParamsMessage')),')'],'NodeData',{indexDB,table,[]});
                    else
                        uitreenode(parentNode,'Text',paramNames{i},'NodeData',{indexDB,table,paramNames{i},corners{1}});
                    end
                end
            end
        end




        function isContinue=checkCompatibilityOfRequest(obj,waveformsDatabase,updateRequest)
            isContinue=true;


            indexDB=updateRequest{1};
            indexSim=updateRequest{2};

            indexWaveformsSim=updateRequest{4};



            existingDB=obj.DataDB(indexDB);
            existingSim=existingDB.SimulationResultsObjects{indexSim};
            existingName=[existingDB.matFileName,',  ',existingDB.SimulationResultsNames{indexSim}];
            existingWaves=existingSim.WaveNames;
            existingParams=existingSim.getParamValue('params_ShortVsLongNames');


            replacementDB=waveformsDatabase;
            replacementSim=replacementDB.SimulationResultsObjects{indexWaveformsSim};
            replacementName=[replacementDB.matFileName,',  ',replacementDB.SimulationResultsNames{indexWaveformsSim}];
            replacementWaves=replacementSim.WaveNames;
            replacementParams=replacementSim.getParamValue('params_ShortVsLongNames');


            existingWavesMissingCount=0;
            for i=1:length(existingWaves)
                [~,simType,nodeName,simCorner]=unpackWaveformName(existingWaves{i});
                found=false;
                for j=1:length(replacementWaves)
                    [~,simType2,nodeName2,simCorner2]=unpackWaveformName(replacementWaves{j});
                    if strcmpi(simType,simType2)&&...
                        strcmpi(nodeName,nodeName2)&&...
                        strcmpi(simCorner,simCorner2)
                        found=true;
                        break;
                    end
                end
                if~found
                    existingWavesMissingCount=existingWavesMissingCount+1;
                end
            end


            existingParamsMissingCount=0;
            for i=1:length(existingParams)
                found=false;
                for j=1:length(replacementParams)
                    if strcmpi(existingParams{i}{1},replacementParams{j}{1})
                        found=true;
                        break;
                    end
                end
                if~found
                    existingParamsMissingCount=existingParamsMissingCount+1;
                end
            end


            if existingWavesMissingCount>0&&existingParamsMissingCount>0
                msg=getString(message('msblks:mixedsignalanalyzer:MismatchedWavesAndMetricPromptQuestion',...
                existingName,replacementName,existingWavesMissingCount,existingParamsMissingCount));
            elseif existingWavesMissingCount>0
                msg=getString(message('msblks:mixedsignalanalyzer:MismatchedWavesPromptQuestion',...
                existingName,replacementName,existingWavesMissingCount));
            elseif existingParamsMissingCount>0
                msg=getString(message('msblks:mixedsignalanalyzer:MismatchedMetricsPromptQuestion',...
                existingName,replacementName,existingParamsMissingCount));
            end
            if existingWavesMissingCount>0||existingParamsMissingCount>0
                appFig=obj.Toolstrip.appContainer;
                title=getString(message('msblks:mixedsignalanalyzer:MismatchedWavesOrMetricsPromptTitle'));
                if~isempty(appFig)&&isvalid(appFig)
                    selection=uiconfirm(appFig,msg,title);
                    if strcmpi(selection,'Cancel')
                        isContinue=false;
                    end
                end
            end
        end
        function updateAnalysisWaveformsAndMetrics(obj)



            obj.oldDBindex;
            obj.oldDB;
            obj.newDB;
            obj.oldSimIndex;
            obj.oldSim;
            obj.newSim;
            obj.oldSimName;
            obj.newSimName;
            obj.oldNodeDB;
            obj.oldNodeSim;
            obj.oldCornerTable;
            obj.oldCornerTableIndex;

            analysisWaveforms=obj.oldDB.analysisWaveforms;
            analysisWfAnswers=obj.oldDB.analysisWfAnswers;
            if~isempty(analysisWaveforms)






                analysisFunction={};
                analysisSymType={};
                analysisNodeName={};
                dialogAnswers={};
                for i=1:length(analysisWaveforms)
                    if analysisWaveforms{i}.wfDBIndex{1}==obj.oldDBindex

                        analysis=analysisWaveforms{i}.function;
                        [simName,simType,nodeName,~]=unpackWaveformName([', ',analysisWaveforms{i}.wfName{1}]);
                        if length(analysisWfAnswers)>=i
                            answer=analysisWfAnswers{i};
                        else
                            answer=[];
                        end

                        [analysisFunction,analysisSymType,analysisNodeName,dialogAnswers]=obj.storeUniqueAnalysisData(...
                        extractAfter(simName,', '),analysis,simType,nodeName,answer,...
                        analysisFunction,analysisSymType,analysisNodeName,dialogAnswers);
                    end
                end

                for i=1:length(analysisSymType)
                    ptr=strfind(analysisSymType{i},')');
                    if~isempty(ptr)

                        ptr=ptr(1);
                        analysisNodeName{i}=[extractBefore(analysisSymType{i},ptr)...
                        ,'.',analysisNodeName{i}...
                        ,extractAfter(analysisSymType{i},ptr-1)];%#ok<AGROW> Merge symType and nodeName (e.g., 'tran./o1', 'acos(tran./o1)').
                        analysisSymType{i}=obj.AnalysisWaveformsText;%#ok<AGROW> Replace symType with "Analysis Waveforms'.
                    end
                end

                obj.performAnalysis(analysisFunction,analysisSymType,analysisNodeName,dialogAnswers);
            end
            analysisMetricData=obj.oldDB.analysisMetricData;
            analysisMetricAnswers=obj.oldDB.analysisMetricAnswers;
            if~isempty(analysisMetricData)






                analysisFunction={};
                analysisSymType={};
                analysisNodeName={};
                dialogAnswers={};
                for i=1:length(analysisMetricData)
                    if analysisMetricData{i}{1}==obj.oldDBindex

                        simName=analysisMetricData{i}{2};
                        nodeName=analysisMetricData{i}{3};
                        simType=analysisMetricData{i}{4};
                        if length(analysisMetricAnswers)>=i
                            answer=analysisMetricAnswers{i};
                        else
                            answer=[];
                        end
                        ptr=strfind(simType,'(');
                        if~isempty(ptr)
                            analysis=extractBefore(simType,ptr(1));
                            simType=extractAfter(simType(1:end-1),ptr(1));
                            ptr=strfind(simType,')');
                            if~isempty(ptr)

                                ptr=ptr(1);
                                nodeName=[extractBefore(simType,ptr),'.',nodeName,extractAfter(simType,ptr-1)];%#ok<AGROW>
                                simType=obj.AnalysisWaveformsText;
                            end
                        else
                            continue;
                        end

                        [analysisFunction,analysisSymType,analysisNodeName,dialogAnswers]=obj.storeUniqueAnalysisData(...
                        simName,analysis,simType,nodeName,answer,...
                        analysisFunction,analysisSymType,analysisNodeName,dialogAnswers);
                    end
                end

                obj.performAnalysis(analysisFunction,analysisSymType,analysisNodeName,dialogAnswers);
            end
        end
        function[analysisFunction,analysisSymType,analysisNodeName,dialogAnswers]=storeUniqueAnalysisData(obj,...
            simName,analysis,simType,nodeName,answer,...
            analysisFunction,analysisSymType,analysisNodeName,dialogAnswers)
            if~strcmp(simName,obj.oldSimName)
                return;
            end

            if~any(strcmp(analysisFunction,analysis))||...
                ~any(strcmp(analysisSymType,simType))||...
                ~any(strcmp(analysisNodeName,nodeName))

                analysisFunction{end+1}=analysis;
                analysisSymType{end+1}=simType;
                analysisNodeName{end+1}=nodeName;
                dialogAnswers{end+1}=answer;
                return;
            end

            for j=1:length(analysisSymType)
                if strcmp(analysisFunction{j},analysis)&&...
                    strcmp(analysisSymType{j},simType)&&...
                    strcmp(analysisNodeName{j},nodeName)
                    return;
                end
            end

            analysisFunction{end+1}=analysis;
            analysisSymType{end+1}=simType;
            analysisNodeName{end+1}=nodeName;
            dialogAnswers{end+1}=answer;
        end
        function performAnalysis(obj,analysisFunction,analysisSymType,analysisNodeName,dialogAnswers)

            tree=obj.DataTree;
            if isempty(tree)||isempty(analysisFunction)||isempty(analysisSymType)||isempty(analysisNodeName)
                return;
            end

            for i=1:length(tree.Children)
                if tree.Children(i).NodeData{1}==obj.oldDBindex

                    for j=1:length(tree.Children(i).Children)
                        if strcmp(tree.Children(i).Children(j).NodeData{2},obj.newSimName)

                            for k=1:length(analysisNodeName)

                                found=false;
                                for m=1:length(tree.Children(i).Children(j).Children)
                                    if strcmp(tree.Children(i).Children(j).Children(m).Text,analysisSymType{k})

                                        for n=1:length(tree.Children(i).Children(j).Children(m).Children)
                                            treeNode=tree.Children(i).Children(j).Children(m).Children(n);
                                            if strcmp(treeNode.NodeData{3},analysisNodeName{k})||...
                                                strcmp(treeNode.Text,analysisNodeName{k})

                                                tree.SelectedNodes=tree.Children(i).Children(j).Children(m).Children(n);
                                                obj.DataTreeWaveformCheckedNodes=tree.SelectedNodes;

                                                functionNew=split(analysisFunction{k},'_');
                                                functionNew=functionNew{1};

                                                path=fullfile(prefdir,'msblks','+msaCustom',[functionNew,'.m']);
                                                if(~isfile(path))
                                                    obj.MixedSignalAnalyzerTool.Controller.runAnalysisFunction(functionNew,dialogAnswers{k});
                                                else
                                                    obj.MixedSignalAnalyzerTool.Controller.runAnalysisCustomFunction(functionNew,dialogAnswers{k});
                                                end
                                                tree=obj.DataTree;
                                                found=true;
                                                break;
                                            end
                                        end
                                        if found
                                            break;
                                        end
                                    end
                                end
                            end
                            break;
                        end
                    end
                    break;
                end
            end
        end
        function updateWaveformPlots(obj)



            obj.oldDBindex;
            obj.oldDB;
            obj.newDB;
            obj.oldSimIndex;
            obj.oldSim;
            obj.newSim;
            obj.oldSimName;
            obj.newSimName;
            obj.oldNodeDB;
            obj.oldNodeSim;
            obj.oldCornerTable;
            obj.oldCornerTableIndex;









            if~isempty(obj.oldCornerTable)&&...
                ~isempty(obj.oldCornerTable.UserData)&&length(obj.oldCornerTable.UserData)==9


                plottedLines=obj.oldCornerTable.UserData{6};
                waveformNames=obj.oldCornerTable.UserData{7};
                plotTags=obj.oldCornerTable.UserData{8};
                plotsVsTreeNodes=obj.oldCornerTable.UserData{9};


                newWaveformNames=obj.newSim.WaveNames;
                analysisWaveforms=obj.newDB.analysisWaveforms;
                offset=length(newWaveformNames);
                if~isempty(analysisWaveforms)

                    newWaveformNames{offset+length(analysisWaveforms)}=[];
                    for i=1:length(analysisWaveforms)

                        type=analysisWaveforms{i}.type;
                        wfName=analysisWaveforms{i}.wfName{1};
                        ptr=strfind(wfName,', ');
                        if length(ptr)==4
                            newWaveformNames{offset+i}=[extractBefore(wfName,ptr(2)+2),type,extractAfter(wfName,ptr(3)-1)];
                        else
                            newWaveformNames{offset+i}=[extractBefore(wfName,ptr(1)+2),type,extractAfter(wfName,ptr(2)-1)];
                        end
                    end
                end


                if isempty(plottedLines)
                    return;
                end


                for i=length(waveformNames):-1:1

                    [~,functionName,nodeName,corner]=unpackWaveformName(waveformNames{i});
                    found=false;
                    for j=1:length(newWaveformNames)
                        [simName2,functionName2,nodeName2,corner2]=unpackWaveformName(newWaveformNames{j});
                        if strcmpi(functionName,functionName2)&&strcmpi(nodeName,nodeName2)&&strcmpi(corner,corner2)
                            found=true;
                            break;
                        end
                    end
                    if found&&~isempty(plottedLines(i))&&isvalid(plottedLines(i))

                        waveformNames{i}=packWaveformName(simName2,functionName2,nodeName2,corner2);
                        if j<=offset

                            [~,~,~,xValues,~]=obj.newSim.getXaxis(waveformNames{i});
                            [~,~,~,yValues,~]=obj.newSim.getYaxis(waveformNames{i});
                        else

                            analysisWaveform=obj.newDB.getAnalysisWaveform(waveformNames{i});
                            xValues=analysisWaveform.x;
                            yValues=analysisWaveform.y;
                        end
                        plottedLines(i).XData=xValues;
                        if isreal(yValues)
                            plottedLines(i).YData=yValues;
                        else
                            plottedLines(i).YData=abs(yValues);
                        end
                    else

                        delete(plottedLines(i));
                        plottedLines(i)=[];
                        waveformNames(i)=[];
                        plotTags(i)=[];
                    end
                    drawnow limitrate;
                end


                newTreeNodes=obj.getNewTreeNodes(obj.oldDBindex,obj.oldSimIndex);
                newPlotsVsTreeNodes{length(plotsVsTreeNodes)}={};
                for i=length(plotsVsTreeNodes):-1:1
                    newPlotsVsTreeNodes{i}{1}=plotsVsTreeNodes{i}{1};
                    newPlotsVsTreeNodes{i}{2}=[];
                    nodes=plotsVsTreeNodes{i}{3};
                    for j=1:length(nodes)
                        for k=1:length(newTreeNodes)
                            if nodes{j}.NodeData{1}==obj.oldDBindex&&...
                                strcmpi(nodes{j}.NodeData{2},obj.oldSimName)&&...
                                strcmpi(nodes{j}.NodeData{3},newTreeNodes{k}.NodeData{3})&&...
                                strcmpi(nodes{j}.NodeData{4},newTreeNodes{k}.NodeData{4})
                                if isempty(newPlotsVsTreeNodes{i}{2})
                                    newPlotsVsTreeNodes{i}{2}=newTreeNodes{k};
                                else
                                    newPlotsVsTreeNodes{i}{2}(end+1)=newTreeNodes{k};
                                end
                            end
                        end
                    end
                    if isempty(newPlotsVsTreeNodes{i}{2})
                        newPlotsVsTreeNodes(i)=[];
                    end
                end


                obj.PlotOptionsTables{obj.oldCornerTableIndex}.UserData{6}=plottedLines;
                obj.PlotOptionsTables{obj.oldCornerTableIndex}.UserData{7}=waveformNames;
                obj.PlotOptionsTables{obj.oldCornerTableIndex}.UserData{8}=plotTags;
                obj.PlotOptionsTables{obj.oldCornerTableIndex}.UserData{9}=newPlotsVsTreeNodes;



                for i=1:length(obj.PlotFigs)
                    isWaveformPlot=false;
                    tables=obj.PlotFigs{i}.UserData;
                    for j=length(tables):-1:1

                        if isa(tables{j},'msblks.internal.apps.mixedsignalanalyzer.uitableStruct')
                            isWaveformPlot=true;
                            plottedWfLines=tables{j}.UserData{6};
                            plottedWfNames=tables{j}.UserData{7};
                            plotTagsPerWf=tables{j}.UserData{8};
                            plotsVsTreeNodes=tables{j}.UserData{9};
                            if isempty(plottedWfLines)||isempty(plottedWfNames)||isempty(plotTagsPerWf)||isempty(plotsVsTreeNodes)

                                obj.PlotFigs{i}.UserData(j)=[];
                            else

                                containsLinesInThisPlot=false;
                                for k=1:length(plotTagsPerWf)
                                    if strcmp(plotTagsPerWf{k},obj.PlotDocs{i}.Tag)&&...
                                        ~isempty(plottedWfLines(k))
                                        containsLinesInThisPlot=true;
                                        break;
                                    end
                                end
                                if~containsLinesInThisPlot

                                    obj.PlotFigs{i}.UserData(j)=[];
                                end
                            end
                        end
                    end
                    if isWaveformPlot

                        figDoc=obj.getFigureHandle(obj.PlotDocs{i}.Title);
                        if~isempty(figDoc)
                            figDoc.Selected=true;
                            drawnow limitrate;
                            obj.updateWaveformPlotTableAndControls('Update');
                        end
                    end
                end
            end
        end
        function newTreeNodes=getNewTreeNodes(obj,dbIndex,simIndex)
            newTreeNodes={};
            if~isempty(obj.DataTree)
                treeNodes=obj.DataTree.Children;
                if~isempty(treeNodes)&&...
                    ~isempty(treeNodes(dbIndex))&&...
                    ~isempty(treeNodes(dbIndex).Children)
                    treeNodes=treeNodes(dbIndex).Children;
                    if~isempty(treeNodes(1).NodeData)

                        treeNodes=treeNodes(simIndex).Children;
                    end
                    for i=1:length(treeNodes)
                        if~strcmpi(treeNodes(i).Text,obj.MetricsText)
                            for j=1:length(treeNodes(i).Children)

                                newTreeNodes{end+1}=treeNodes(i).Children(j);%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end
        function clearOldDataUsedForUpdates(obj)

            isUsed=false;
            for i=1:length(obj.DataDB)
                if obj.DataDB(i)==obj.oldDB
                    isUsed=true;
                    break;
                end
            end
            if~isUsed

                delete(obj.oldDB);
                delete(obj.oldSim);
            end

            obj.oldDBindex=0;
            obj.oldDB=[];
            obj.newDB=[];
            obj.oldSimIndex=0;
            obj.oldSim=[];
            obj.newSim=[];
            obj.oldSimName=[];
            obj.newSimName=[];
            obj.oldNodeDB=[];
            obj.oldNodeSim=[];
            obj.oldCornerTable=[];
            obj.oldCornerTableIndex=0;
        end
        function updateTrendCharts(obj)
            for i=1:length(obj.PlotFigs)
                if length(obj.PlotFigs{i}.UserData)<11||~isa(obj.PlotFigs{i}.UserData{1},'matlab.ui.container.Panel')
                    continue;
                end

                metricTreeNodes=obj.PlotFigs{i}.UserData{11};
                if~isempty(metricTreeNodes)
                    removedIndex{length(metricTreeNodes)}=[];%#ok<AGROW>
                else
                    continue;
                end
                for j=length(metricTreeNodes):-1:1
                    if isvalid(metricTreeNodes(j))
                        removedIndex{j}=0;
                    else
                        removedIndex{j}=j;
                        metricTreeNodes(j)=[];
                    end
                end

                if length(obj.PlotFigs{i}.UserData{11})~=length(metricTreeNodes)

                    yAxisParamNames=obj.PlotFigs{i}.UserData{9};
                    originalTreeNodes=obj.PlotFigs{i}.UserData{12};
                    for j=length(yAxisParamNames):-1:1
                        if removedIndex{j}>0
                            removedTreeNode=originalTreeNodes{removedIndex{j}};
                            yAxisParamNames(j)=[];
                        end
                    end
                    for j=1:length(originalTreeNodes)
                        dbIndex=originalTreeNodes{j}.NodeData{1};

                        simName=originalTreeNodes{j}.UserData;
                        nodeName=originalTreeNodes{j}.NodeData{3};
                        funcName=originalTreeNodes{j}.NodeData{4};
                        if length(originalTreeNodes{j}.NodeData)<5
                            isAnalysisWf=false;
                        else
                            isAnalysisWf=strcmpi(originalTreeNodes{j}.NodeData{5},'Analysis Waveform');
                        end
                        for k=1:length(obj.DataTree.Children(dbIndex).Children)
                            metricsRootNode=[];
                            simNode=obj.DataTree.Children(dbIndex).Children(k);
                            if isempty(simNode.NodeData)

                                if strcmpi(simNode.Text,obj.MetricsText)
                                    metricsRootNode=simNode;
                                end
                            elseif simNode.NodeData{1}==dbIndex&&strcmpi(simNode.NodeData{2},simName)

                                for m=1:length(simNode.Children)
                                    if strcmpi(simNode.Children(m).Text,obj.MetricsText)
                                        metricsRootNode=simNode.Children(m);
                                        break;
                                    end
                                end
                            end
                            if~isempty(metricsRootNode)

                                for n=1:length(metricsRootNode.Children)
                                    metricNode=metricsRootNode.Children(n);
                                    if metricNode.NodeData{1}==dbIndex&&...
                                        strcmpi(metricNode.NodeData{2},simName)&&...
                                        strcmpi(metricNode.NodeData{3},nodeName)&&...
                                        strcmpi(metricNode.NodeData{4},funcName)

                                        yAxisParamNames{end+1}=nodeName;%#ok<AGROW>
                                        metricTreeNodes(end+1)=metricNode;%#ok<AGROW>
                                    elseif strcmpi(metricNode.Text,obj.AnalysisMetricsText)
                                        analysisMetricsRootNode=metricNode;
                                        for p=1:length(analysisMetricsRootNode.Children)
                                            analysisMetricNode=analysisMetricsRootNode.Children(p);
                                            if analysisMetricNode.NodeData{1}==dbIndex&&...
                                                strcmpi(analysisMetricNode.NodeData{2},simName)&&...
                                                strcmpi(analysisMetricNode.NodeData{3},nodeName)&&...
                                                strcmpi(analysisMetricNode.NodeData{4},funcName)

                                                ptr=strfind(funcName,')');
                                                if~isempty(ptr)

                                                    ptr=ptr(1);
                                                    nodeName=[extractBefore(funcName,ptr),'.',nodeName,extractAfter(funcName,ptr-1)];%#ok<AGROW>
                                                end
                                                yAxisParamNames{end+1}=nodeName;%#ok<AGROW>
                                                metricTreeNodes(end+1)=analysisMetricNode;%#ok<AGROW>
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if isempty(metricTreeNodes)
                        metricTreeNodes=[];
                    end
                    obj.PlotFigs{i}.UserData{9}=yAxisParamNames;
                    obj.PlotFigs{i}.UserData{11}=metricTreeNodes;


                    obj.PlotDocs{i}.Selected=true;
                    drawnow limitrate;


                    obj.DataFig.Selected=true;
                    drawnow limitrate;


                    obj.DataTree.SelectedNodes=metricTreeNodes;
                    obj.DataTreeMetricCheckedNodes=metricTreeNodes;

                    drawnow;

                    if isempty(metricTreeNodes)

                        figAxes=obj.PlotFigs{i}.CurrentAxes;
                        cla(figAxes);
                        figAxes.YLabel=[];
                        obj.clearTrendChartWidgets();
                        metricsPanel=obj.PlotFigs{i}.UserData{1};
                        obj.PlotFigs{i}.UserData={metricsPanel,[],[],[],{},{},{},{},{},{},[]};
                    else

                        xAxisParamNames=obj.PlotFigs{i}.UserData{8};
                        yAxisParamNames=obj.PlotFigs{i}.UserData{9};
                        legendParamNames=obj.PlotFigs{i}.UserData{10};


                        obj.MixedSignalAnalyzerTool.Controller.setupTrendChart();


                        [~,~,metricFilterTree,~,~,plotList,xAxisList,legendList]=obj.getTrendChartWidgets();


                        treeNodes=metricFilterTree.Children(1).Children;


                        for j=1:3
                            switch j
                            case 1
                                list=xAxisParamNames;
                            case 2
                                list=yAxisParamNames;
                            case 3
                                list=legendParamNames;
                            end
                            for k=length(list):-1:1
                                found=false;
                                for m=1:length(treeNodes)
                                    if strcmp(list{k},treeNodes(m).Text)
                                        found=true;
                                        break;
                                    end
                                end
                                if~found
                                    list(k)=[];
                                end
                            end
                            switch j
                            case 1
                                xAxisParamNames=list;
                            case 2
                                yAxisParamNames=list;
                            case 3
                                legendParamNames=list;
                            end
                        end

                        checkedTreeNodes=[];
                        for j=1:length(treeNodes)
                            for k=1:3
                                switch k
                                case 1
                                    list=xAxisParamNames;
                                case 2
                                    list=yAxisParamNames;
                                case 3
                                    list=legendParamNames;
                                end
                                wasChecked=false;
                                for m=1:length(list)
                                    if strcmp(treeNodes(j).Text,list{m})
                                        wasChecked=true;
                                        break;
                                    end
                                end
                                if wasChecked
                                    if isempty(checkedTreeNodes)
                                        checkedTreeNodes=treeNodes(j);
                                    else
                                        checkedTreeNodes(end+1)=treeNodes(j);%#ok<AGROW>
                                    end
                                    break;
                                end
                            end
                        end

                        if length(checkedTreeNodes)>1&&~isempty(xAxisParamNames)&&~isempty(yAxisParamNames)
                            metricFilterTree.CheckedNodes=checkedTreeNodes;
                            plotList.Items=yAxisParamNames;
                            xAxisList.Items=xAxisParamNames;
                            legendList.Items=legendParamNames;
                            obj.MixedSignalAnalyzerTool.Controller.showTrendChart();
                        end
                    end
                    drawnow limitrate;
                end

            end
        end




        function addWaveformsAndOrMetricsToDataTree(obj,waveforms,metrics)
            if~isempty(metrics)&&iscell(metrics)&&length(metrics{end})==2&&strcmpi(metrics{end}{1},'AnalysisDialogAnswers')

                dialogAnswers=metrics{end}{2};
                metrics(end)=[];
            else
                dialogAnswers=[];
            end
            if~isempty(waveforms)
                newAnalysisWaveformCount=0;
                newAnalysisMetricCount=0;
                filterNode=[];
                for i=1:length(waveforms)
                    [analysisWaveformRootNode,analysisMetricRootNode]=obj.getAnalysisWaveformAndMetricBranches(waveforms{i});
                    dbIndex=analysisWaveformRootNode.NodeData{1};
                    [symRun,~,nodeName,corner]=unpackWaveformName(waveforms{i}.wfName{1});
                    for j=2:length(waveforms{i}.wfName)
                        [~,~,nodeNameN,~]=unpackWaveformName(waveforms{j}.wfName{1});
                        nodeName=[nodeName,',',nodeNameN];%#ok<AGROW>
                    end


                    if strcmpi(waveforms{i}.type,'Analysis Waveform')

                        [~,simType,~,~]=unpackWaveformName(waveforms{i}.wfName{1});
                        functionName=[waveforms{i}.function,'(',simType];
                        for j=2:length(waveforms{i}.wfName)
                            [~,simType,~,~]=unpackWaveformName(waveforms{i}.wfName{j});
                            functionName=[functionName,',',simType];%#ok<AGROW>
                        end
                        functionName=[functionName,')'];%#ok<AGROW> Function name, e.g., "acos(tran)" or "yPower(tran,tran)".
                        waveforms{i}.type=functionName;


                        treeNodeName=[waveforms{i}.function,'('];
                        for j=1:length(waveforms{i}.wfName)
                            [~,simType,nodeName,~]=unpackWaveformName(waveforms{i}.wfName{j});
                            ptr=strfind(simType,')');
                            if isempty(ptr)
                                treeNodeName=[treeNodeName,simType,'.',nodeName];%#ok<AGROW>
                            else
                                ptr=ptr(1);
                                treeNodeName=[treeNodeName,extractBefore(simType,ptr),'.',nodeName,extractAfter(simType,ptr-1)];%#ok<AGROW>
                            end
                            if j<length(waveforms{i}.wfName)
                                treeNodeName=[treeNodeName,','];%#ok<AGROW> e.g., "acos(tran./01)" or "yPower(tran./01,tran./02)"
                            end
                        end
                        treeNodeName=[treeNodeName,')'];%#ok<AGROW>
                        treeNodeNameExists=false;
                        for j=1:length(analysisWaveformRootNode.Children)
                            if strcmp(analysisWaveformRootNode.Children(j).Text,treeNodeName)
                                treeNodeNameExists=true;
                                break;
                            end
                        end
                        if~treeNodeNameExists
                            newAnalysisWaveformCount=newAnalysisWaveformCount+1;
                            uitreenode(analysisWaveformRootNode,...
                            'Text',treeNodeName,...
                            'NodeData',{dbIndex,symRun,nodeName,functionName,'Analysis Waveform'});
                        end


                        isNewAnalysisWaveform=true;
                        for j=1:length(obj.DataDB(dbIndex).analysisNodeNames)
                            [symRunN,functionNameN,nodeNameN,cornerN]=unpackWaveformName(obj.DataDB(dbIndex).analysisNodeNames{j});
                            if strcmp(symRunN,symRun)&&strcmp(functionNameN,functionName)&&strcmp(nodeNameN,nodeName)&&strcmp(cornerN,corner)

                                obj.DataDB(dbIndex).analysisWaveforms{j}=waveforms{i};
                                obj.DataDB(dbIndex).analysisWfAnswers{j}=dialogAnswers;
                                isNewAnalysisWaveform=false;
                            end
                        end
                        if isNewAnalysisWaveform

                            obj.DataDB(dbIndex).analysisNodeNames{end+1}=packWaveformName(symRun,functionName,nodeName,corner);
                            obj.DataDB(dbIndex).analysisWaveforms{end+1}=waveforms{i};
                            obj.DataDB(dbIndex).analysisWfAnswers{end+1}=dialogAnswers;
                        end
                    end


                    if~isempty(metrics{i})&&~isempty(metrics{i}{1})&&~strcmpi(metrics{i}{1},'empty')

                        if strcmpi(waveforms{i}.type,'Metrics Only')
                            [~,functionName1,~,~]=unpackWaveformName(waveforms{i}.wfName{1});
                            if(strcmp(waveforms{i}.function,metrics{i}{1}))
                                functionName=[metrics{i}{1},'(',functionName1];
                            else
                                functionName=[waveforms{i}.function,'_',metrics{i}{1},'(',functionName1];
                            end
                            for j=2:length(waveforms{i}.wfName)
                                [~,functionNameN,~,~]=unpackWaveformName(waveforms{i}.wfName{j});
                                functionName=[functionName,',',functionNameN];%#ok<AGROW>
                            end
                        else
                            functionName=[metrics{i}{1},'(',waveforms{i}.type];
                        end
                        functionName=[functionName,')'];%#ok<AGROW>


                        ptr=strfind(functionName,')');
                        ptr=ptr(1);
                        treeNodeName=[extractBefore(functionName,ptr),'.',nodeName,extractAfter(functionName,ptr-1)];


                        treeNodeNameExists=false;
                        for j=1:length(analysisMetricRootNode.Children)
                            if strcmp(analysisMetricRootNode.Children(j).Text,treeNodeName)
                                for k=1:length(obj.DataDB(dbIndex).analysisMetricData)

                                    metricData=obj.DataDB(dbIndex).analysisMetricData{k};
                                    if metricData{1}==dbIndex&&...
                                        strcmp(metricData{2},symRun)&&...
                                        strcmp(metricData{3},nodeName)&&...
                                        strcmp(metricData{4},functionName)

                                        obj.DataDB(dbIndex).analysisMetricAnswers{k}=dialogAnswers;
                                        break;
                                    end
                                end
                                node=analysisMetricRootNode.Children(j);
                                treeNodeNameExists=true;
                                break;
                            end
                        end
                        if~treeNodeNameExists
                            newAnalysisMetricCount=newAnalysisMetricCount+1;
                            node=uitreenode(analysisMetricRootNode,...
                            'Text',treeNodeName,...
                            'NodeData',{dbIndex,symRun,nodeName,functionName,'Analysis Waveform'});
                            obj.DataDB(dbIndex).analysisMetricNames{end+1}=node.Text;
                            obj.DataDB(dbIndex).analysisMetricData{end+1}=node.NodeData;
                            obj.DataDB(dbIndex).analysisMetricAnswers{end+1}=dialogAnswers;
                        end


                        for j=1:length(obj.DataDB(dbIndex).analysisMetricData)
                            if obj.DataDB(dbIndex).analysisMetricData{j}{1}==node.NodeData{1}&&...
                                strcmp(obj.DataDB(dbIndex).analysisMetricData{j}{2},node.NodeData{2})&&...
                                strcmp(obj.DataDB(dbIndex).analysisMetricData{j}{3},node.NodeData{3})&&...
                                strcmp(obj.DataDB(dbIndex).analysisMetricData{j}{4},node.NodeData{4})&&...
                                strcmp(obj.DataDB(dbIndex).analysisMetricData{j}{5},node.NodeData{5})
                                if j>length(obj.DataDB(dbIndex).analysisMetricCorners)
                                    obj.DataDB(dbIndex).analysisMetricCorners{j}{1}=corner;
                                    obj.DataDB(dbIndex).analysisMetricValues{j}{1}=metrics{i}{2};
                                else
                                    cornerValueIndex=0;
                                    for k=1:length(obj.DataDB(dbIndex).analysisMetricCorners{j})
                                        if strcmp(obj.DataDB(dbIndex).analysisMetricCorners{j},corner)
                                            obj.DataDB(dbIndex).analysisMetricValues{j}{k}=metrics{i}{2};
                                            cornerValueIndex=k;
                                            break;
                                        end
                                    end
                                    if cornerValueIndex<1
                                        obj.DataDB(dbIndex).analysisMetricCorners{j}{end+1}=corner;
                                        obj.DataDB(dbIndex).analysisMetricValues{j}{end+1}=metrics{i}{2};
                                    end
                                end
                            end
                        end


                        if i==1||waveforms{i}.wfTable{1}~=waveforms{i-1}.wfTable{1}

                            table=waveforms{i}.wfTable{1};
                            columnNames=table.ColumnName;
                            data=table.Data;
                            filterRoot=table.Parent.Children(3).UserData{2}.Children;
                        end
                        columnIndex=0;
                        for j=1:length(columnNames)
                            if strcmp(columnNames{j},treeNodeName)
                                columnIndex=j;
                                break;
                            end
                        end
                        if columnIndex<1

                            columnNames{end+1}=treeNodeName;%#ok<AGROW>
                            columnIndex=length(columnNames);



                            filterNode='dummy';










                        end

                        if~isempty(filterNode)
                            for row=1:size(data,1)
                                if strcmpi(data{row,2},corner)

                                    data{row,columnIndex}=metrics{i}{2};

























                                    break;
                                end
                            end
                        end
                        if i==length(waveforms)||waveforms{i}.wfTable{1}~=waveforms{i+1}.wfTable{1}

                            table.ColumnName=columnNames;
                            try
                                table.Data=data;
                                filterRoot.NodeData{6}=data;
                            catch ex


                                isNotScalarNumber=false;
                                for row=1:size(data,1)
                                    if any(size(data{row,end})~=[1,1])
                                        data{row,end}='NaN';
                                        isNotScalarNumber=true;
                                    end
                                end
                                if~isNotScalarNumber
                                    rethrow(ex);
                                else
                                    table.Data=data;
                                    filterRoot.NodeData{6}=data;
                                end
                            end
                        end
                    end
                end
                drawnow;
                if newAnalysisWaveformCount>0||newAnalysisMetricCount>0
                    obj.setSortedCheckedNodes();
                    obj.MixedSignalAnalyzerTool.Model.IsChanged=true;
                end
            end
        end
        function[analysisWaveformRootNode,analysisMetricRootNode]=getAnalysisWaveformAndMetricBranches(obj,waveform)
            analysisWaveformRootNode=[];
            analysisMetricRootNode=[];
            if~isempty(waveform)&&~isempty(obj.DataTree)&&~isempty(obj.DataTree.Children)

                if length(waveform.wfDBIndex)==1||~any(find([waveform.wfDBIndex{:}]~=waveform.wfDBIndex{1}))

                    if length(waveform.wfTable)==1||~any(find([waveform.wfTable{:}]~=waveform.wfTable{1}))

                        dbIndex=waveform.wfDBIndex{1};
                        tableName=waveform.wfTable{1}.UserData{2};
                        for i=1:length(obj.DataTree.Children)
                            if obj.DataTree.Children(i).NodeData{1}==dbIndex

                                analysisRootNodes=obj.DataTreeAnalysisWaveformsRootNodes{dbIndex};
                                for j=1:length(analysisRootNodes)
                                    if strcmpi(analysisRootNodes{j}.NodeData{3},tableName)
                                        analysisWaveformRootNode=analysisRootNodes{j};
                                        break;
                                    end
                                end
                                analysisRootNodes=obj.DataTreeAnalysisMetricsRootNodes{dbIndex};
                                for j=1:length(analysisRootNodes)
                                    if strcmpi(analysisRootNodes{j}.NodeData{3},tableName)
                                        analysisMetricRootNode=analysisRootNodes{j};
                                        break;
                                    end
                                end
                            end
                        end
                    else

                    end
                else

                end
            end
        end




        function restoreWaveformsAndOrMetricsToDataTree(obj,database)
            waveforms=database.analysisWaveforms;
            newAnalysisWaveformCount=0;
            newAnalysisMetricCount=0;
            if~isempty(waveforms)
                filterNode=[];
                for i=1:length(waveforms)

                    dbIndex=waveforms{i}.wfDBIndex;
                    wfTableName=waveforms{i}.wfTable;
                    [analysisWaveformRootNode,~]=obj.getAnalysisWaveformAndMetricBranchesByIndex(dbIndex,wfTableName);
                    waveforms{i}.wfTable=obj.getCornerTable(wfTableName);
                    [symRun,~,nodeName,corner]=unpackWaveformName(waveforms{i}.wfName{1});
                    for j=2:length(waveforms{i}.wfName)
                        [~,~,nodeNameN,~]=unpackWaveformName(waveforms{j}.wfName{1});
                        nodeName=[nodeName,',',nodeNameN];%#ok<AGROW>
                    end
                    functionName=waveforms{i}.type;


                    treeNodeName=[waveforms{i}.function,'('];
                    for j=1:length(waveforms{i}.wfName)
                        [~,simType,nodeName,~]=unpackWaveformName(waveforms{i}.wfName{j});
                        ptr=strfind(simType,')');
                        if isempty(ptr)
                            treeNodeName=[treeNodeName,simType,'.',nodeName];%#ok<AGROW>
                        else
                            ptr=ptr(1);
                            treeNodeName=[treeNodeName,extractBefore(simType,ptr),'.',nodeName,extractAfter(simType,ptr-1)];%#ok<AGROW>
                        end
                        if j<length(waveforms{i}.wfName)
                            treeNodeName=[treeNodeName,','];%#ok<AGROW> e.g., "acos(tran./01)" or "yPower(tran./01,tran./02)"
                        end
                    end
                    treeNodeName=[treeNodeName,')'];%#ok<AGROW>
                    treeNodeNameExists=false;
                    for j=1:length(analysisWaveformRootNode.Children)
                        if strcmp(analysisWaveformRootNode.Children(j).Text,treeNodeName)
                            treeNodeNameExists=true;
                            break;
                        end
                    end
                    if~treeNodeNameExists
                        newAnalysisWaveformCount=newAnalysisWaveformCount+1;
                        uitreenode(analysisWaveformRootNode,...
                        'Text',treeNodeName,...
                        'NodeData',{dbIndex{1},symRun,nodeName,functionName,'Analysis Waveform'});
                    end


                    isNewAnalysisWaveform=true;
                    for j=1:length(obj.DataDB(dbIndex{1}).analysisNodeNames)
                        [symRunN,functionNameN,nodeNameN,cornerN]=unpackWaveformName(obj.DataDB(dbIndex{1}).analysisNodeNames{j});
                        if strcmp(symRunN,symRun)&&strcmp(functionNameN,functionName)&&strcmp(nodeNameN,nodeName)&&strcmp(cornerN,corner)

                            obj.DataDB(dbIndex{1}).analysisWaveforms{j}=waveforms{i};
                            isNewAnalysisWaveform=false;
                        end
                    end
                    if isNewAnalysisWaveform

                        obj.DataDB(dbIndex{1}).analysisWaveforms{end+1}=waveforms{i};
                        obj.DataDB(dbIndex{1}).analysisNodeNames{end+1}=packWaveformName(symRun,functionName,nodeName,corner);
                    end
                end
            end
            metrics=database.analysisMetricData;
            corners=database.analysisMetricCorners;
            values=database.analysisMetricValues;
            if~isempty(metrics)&&length(metrics)==length(corners)&&length(corners)==length(values)
                for i=1:length(metrics)

                    metric=metrics{i};
                    metricCorners=corners{i};
                    metricValues=values{i};
                    dbIndex=metric{1};
                    wfTableName=metric{2};
                    nodeName=metric{3};
                    functionName=metric{4};
                    [~,analysisMetricRootNode]=obj.getAnalysisWaveformAndMetricBranchesByIndex(dbIndex,wfTableName);
                    symRun=analysisMetricRootNode.NodeData{3};


                    if~isempty(analysisMetricRootNode)

                        ptr=strfind(functionName,')');
                        ptr=ptr(1);
                        treeNodeName=[extractBefore(functionName,ptr),'.',nodeName,extractAfter(functionName,ptr-1)];


                        treeNodeNameExists=false;
                        for j=1:length(analysisMetricRootNode.Children)
                            if strcmp(analysisMetricRootNode.Children(j).Text,treeNodeName)
                                treeNodeNameExists=true;
                                break;
                            end
                        end
                        if~treeNodeNameExists
                            newAnalysisMetricCount=newAnalysisMetricCount+1;
                            uitreenode(analysisMetricRootNode,...
                            'Text',treeNodeName,...
                            'NodeData',{dbIndex,symRun,nodeName,functionName,'Analysis Waveform'});
                        end


                        for j=4:length(obj.PlotOptionsTables)
                            table=obj.PlotOptionsTables{j};
                            if length(table.UserData)==9&&...
                                isnumeric(table.UserData{1})&&isscalar(table.UserData{1})&&table.UserData{1}==dbIndex&&...
                                ischar(table.UserData{2})&&strcmp(table.UserData{2},wfTableName)
                                columnNames=table.ColumnName;
                                data=table.Data;
                                filterRoot=table.Parent.Children(3).UserData{2}.Children;
                                break;
                            end
                        end


                        columnIndex=0;
                        for j=1:length(columnNames)
                            if strcmp(columnNames{j},treeNodeName)
                                columnIndex=j;
                                break;
                            end
                        end
                        if columnIndex<1

                            columnNames{end+1}=treeNodeName;%#ok<AGROW>
                            columnIndex=length(columnNames);



                            filterNode=msblks.internal.apps.mixedsignalanalyzer.uitreenodeStruct(filterRoot);










                        else

                            for j=1:length(filterRoot.Children)
                                if strcmp(filterRoot.Children(j).Text,treeNodeName)
                                    filterNode=filterRoot.Children(j);
                                    break;
                                end
                            end
                        end


                        if~isempty(filterNode)
                            if~isempty(filterNode.Children)

                                delete(filterNode.Children);
                                filterNode.Children=[];
                            end
                            for row=1:size(data,1)
                                for cornerIndex=1:length(metricCorners)
                                    if strcmpi(data{row,2},metricCorners{cornerIndex})

                                        value=metricValues{cornerIndex};


                                        data{row,columnIndex}=value;


























                                        break;
                                    end
                                end
                            end
                        end

                        table.ColumnName=columnNames;
                        table.Data=data;
                        filterRoot.NodeData{6}=data;
                    end
                end
                drawnow limitrate;
                if newAnalysisWaveformCount>0||newAnalysisMetricCount>0
                    obj.setSortedCheckedNodes();
                    obj.MixedSignalAnalyzerTool.Model.IsChanged=true;
                end
            end
        end
        function[analysisWaveformRootNode,analysisMetricRootNode]=getAnalysisWaveformAndMetricBranchesByIndex(obj,wfDBIndex,wfTableName)
            analysisWaveformRootNode=[];
            analysisMetricRootNode=[];
            if~isempty(wfTableName)&&~isempty(obj.DataTree)&&~isempty(obj.DataTree.Children)

                if length(wfDBIndex)==1||~any(find([wfDBIndex{:}]~=wfDBIndex{1}))

                    if~iscell(wfTableName)||...
                        iscell(wfTableName)&&(length(wfTableName)==1||~any(find([wfTableName{:}]~=wfTableName{1})))

                        if iscell(wfTableName)

                            dbIndex=wfDBIndex{1};
                            tableName=wfTableName{1}{2};
                        else

                            dbIndex=wfDBIndex;
                            tableName=wfTableName;
                        end
                        for i=1:length(obj.DataTree.Children)
                            if obj.DataTree.Children(i).NodeData{1}==dbIndex

                                analysisRootNodes=obj.DataTreeAnalysisWaveformsRootNodes{dbIndex};
                                for j=1:length(analysisRootNodes)
                                    if strcmpi(analysisRootNodes{j}.NodeData{3},tableName)
                                        analysisWaveformRootNode=analysisRootNodes{j};
                                        break;
                                    end
                                end

                                analysisRootNodes=obj.DataTreeAnalysisMetricsRootNodes{dbIndex};
                                for j=1:length(analysisRootNodes)
                                    if strcmpi(analysisRootNodes{j}.NodeData{3},tableName)
                                        analysisMetricRootNode=analysisRootNodes{j};
                                        break;
                                    end
                                end
                            end
                        end
                    else

                    end
                else

                end
            end
        end
        function wfTable=getCornerTable(obj,wfTableName)
            wfTable{length(wfTableName)}=[];
            if~isempty(wfTableName)

                for i=1:length(wfTableName)
                    for j=4:length(obj.PlotOptionsTables)
                        if obj.PlotOptionsTables{j}.UserData{1}==wfTableName{1}{1}&&...
                            strcmp(obj.PlotOptionsTables{j}.UserData{2},wfTableName{i}{2})&&...
                            all(strcmp(obj.PlotOptionsTables{j}.UserData{3},wfTableName{i}{3}))
                            wfTable{i}=obj.PlotOptionsTables{j};
                            break;
                        end
                    end
                end
            end
        end




        function createMetricsPlotOptionsTable(obj)
            obj.MixedSignalAnalyzerTool.Model.IsChanged=true;






            IconArrowUp=[fullfile('+msblks','+internal','+apps','+mixedsignalanalyzer'),filesep,'up-arrow-16.png'];
            IconArrowDown=[fullfile('+msblks','+internal','+apps','+mixedsignalanalyzer'),filesep,'down-arrow-16.png'];
            IconArrowLeft=[fullfile('+msblks','+internal','+apps','+mixedsignalanalyzer'),filesep,'left-arrow-16.png'];
            IconArrowRight=[fullfile('+msblks','+internal','+apps','+mixedsignalanalyzer'),filesep,'right-arrow-16.png'];


            header={'Corner'};
            widths={'auto'};
            editable=false(1,length(header));






            cornersPanel=uipanel(obj.OptionsFigLayout,'Tag','CornersPanel_1');
            cornersPanelGridLayout=uigridlayout(cornersPanel,'RowHeight',{24,'1x'},'ColumnWidth',{'1x'},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            titleLabel=uilabel('Parent',cornersPanelGridLayout,'Text',obj.MetricsText);
            table=uitable(cornersPanelGridLayout);
            table.Data={1,2};
            table.ColumnName=header;
            table.ColumnWidth=widths;
            table.ColumnSortable=true;
            table.ColumnEditable=editable;
            table.CellEditCallback=@obj.plotOptionsCellEdited;
            table.DisplayDataChangedFcn=@obj.plotOptionsTableChanged;


            obj.PlotOptionsTables{1}=table;
            obj.PlotOptionsPanels{1}=cornersPanel;
            obj.PlotOptionsTitleLabels{1}=titleLabel;
            obj.PlotOptionsFilters{1}=[];

            obj.PlotOptionsFilterFigures{1}=[];
            obj.PlotOptionsFilterButtons{1}=[];
            obj.PlotOptionsFilterCheckboxes{1}=[];













            metricsPanel=uipanel(obj.OptionsFigLayout,'Tag','MetricsPanel_');
            metricsPanelGridLayout=uigridlayout(metricsPanel,...
            'RowHeight',{24,'1x',20,20,'1x',20,'1x',20,20,'1x',20,'1x',20,20,'1x'},...
            'ColumnWidth',{'1x',20,'1x'},...
            'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            titleLabel=uilabel('Parent',metricsPanelGridLayout,'Text',obj.MetricsText);
            leftPanel=uipanel(metricsPanelGridLayout,'Title','Trend Chart Fields','TitlePosition','centertop','Tag','leftPanel');
            topRightPanel=uipanel(metricsPanelGridLayout,'Title','Plot','TitlePosition','centertop','Tag','topRightPanel');
            midRightPanel=uipanel(metricsPanelGridLayout,'Title','X-Axis','TitlePosition','centertop','Tag','midRightPanel');
            botRightPanel=uipanel(metricsPanelGridLayout,'Title','Legend','TitlePosition','centertop','Tag','botRightPanel');
            top2midRightPanel=uipanel(metricsPanelGridLayout,'BorderType','none');
            bot2midRightPanel=uipanel(metricsPanelGridLayout,'BorderType','none');
            imageParams2Plots=uiimage(metricsPanelGridLayout,'ImageSource',IconArrowRight,'Tag','imageParams2Plot','ImageClickedFcn',@obj.addParamToList);
            imagePlots2Params=uiimage(metricsPanelGridLayout,'ImageSource',IconArrowLeft,'Tag','imagePlot2Params','ImageClickedFcn',@obj.removeParamInList);
            imageParams2Xaxis=uiimage(metricsPanelGridLayout,'ImageSource',IconArrowRight,'Tag','imageParams2Xaxis','ImageClickedFcn',@obj.addParamToList);
            imageXaxis2Params=uiimage(metricsPanelGridLayout,'ImageSource',IconArrowLeft,'Tag','imageXaxis2Params','ImageClickedFcn',@obj.removeParamInList);
            imageParams2Legend=uiimage(metricsPanelGridLayout,'ImageSource',IconArrowRight,'Tag','imageParams2Legend','ImageClickedFcn',@obj.addParamToList);
            imageLegend2Params=uiimage(metricsPanelGridLayout,'ImageSource',IconArrowLeft,'Tag','imageLegend2Params','ImageClickedFcn',@obj.removeParamInList);
            titleLabel.Layout.Row=1;
            leftPanel.Layout.Row=[2,15];
            topRightPanel.Layout.Row=[2,5];
            midRightPanel.Layout.Row=[7,10];
            botRightPanel.Layout.Row=[12,15];
            top2midRightPanel.Layout.Row=6;
            bot2midRightPanel.Layout.Row=11;
            imageParams2Plots.Layout.Row=3;
            imagePlots2Params.Layout.Row=4;
            imageParams2Xaxis.Layout.Row=8;
            imageXaxis2Params.Layout.Row=9;
            imageParams2Legend.Layout.Row=13;
            imageLegend2Params.Layout.Row=14;
            titleLabel.Layout.Column=[1,3];
            leftPanel.Layout.Column=1;
            topRightPanel.Layout.Column=3;
            midRightPanel.Layout.Column=3;
            botRightPanel.Layout.Column=3;
            top2midRightPanel.Layout.Column=3;
            bot2midRightPanel.Layout.Column=3;
            imageParams2Plots.Layout.Column=2;
            imagePlots2Params.Layout.Column=2;
            imageParams2Xaxis.Layout.Column=2;
            imageXaxis2Params.Layout.Column=2;
            imageParams2Legend.Layout.Column=2;
            imageLegend2Params.Layout.Column=2;

            leftPanelGridLayout=uigridlayout(leftPanel,'RowHeight',{'1x',80,'0x'},'ColumnWidth',{'1x'},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');

            metricFilterTree=uitree(leftPanelGridLayout,'checkbox','Tag','metricFilterTree','CheckedNodesChangedFcn',@obj.metricFilterCheckedNodesChanged);
            uitreenode(metricFilterTree,'Text','Add fields to chart','Tag','metricFilterRoot');
            uilistbox(leftPanelGridLayout,'Tag','tablesListBox');
            uitable(leftPanelGridLayout,'Tag','mergedTable');

            plotPanelGridLayout=uigridlayout(topRightPanel,'RowHeight',{20,2,20,'1x'},'ColumnWidth',{'1x',20},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            plotList=uilistbox('Parent',plotPanelGridLayout,'Items',{''},'Tag','plotList');
            imagePlotMoveUp=uiimage(plotPanelGridLayout,'ImageSource',IconArrowUp,'Tag','imagePlotMoveUp','ImageClickedFcn',@obj.moveSelectedParamUpInList);
            imagePlotMoveDown=uiimage(plotPanelGridLayout,'ImageSource',IconArrowDown,'Tag','imagePlotMoveDown','ImageClickedFcn',@obj.moveSelectedParamDownInList);


            plotList.Layout.Row=[1,4];
            imagePlotMoveUp.Layout.Row=1;
            imagePlotMoveDown.Layout.Row=3;
            plotList.Layout.Column=1;
            imagePlotMoveUp.Layout.Column=2;
            imagePlotMoveDown.Layout.Column=2;

            xAxisPanelGridLayout=uigridlayout(midRightPanel,'RowHeight',{20,2,20,'1x'},'ColumnWidth',{'1x',20},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            xAxisList=uilistbox('Parent',xAxisPanelGridLayout,'Items',{''},'Tag','xAxisList');
            imageXaxisMoveUp=uiimage(xAxisPanelGridLayout,'ImageSource',IconArrowUp,'Tag','imageXaxisMoveUp','ImageClickedFcn',@obj.moveSelectedParamUpInList);
            imageXaxisMoveDown=uiimage(xAxisPanelGridLayout,'ImageSource',IconArrowDown,'Tag','imageXaxisMoveDown','ImageClickedFcn',@obj.moveSelectedParamDownInList);
            xAxisList.Layout.Row=[1,4];
            imageXaxisMoveUp.Layout.Row=1;
            imageXaxisMoveDown.Layout.Row=3;
            xAxisList.Layout.Column=1;
            imageXaxisMoveUp.Layout.Column=2;
            imageXaxisMoveDown.Layout.Column=2;

            legendPanelGridLayout=uigridlayout(botRightPanel,'RowHeight',{20,2,20,'1x'},'ColumnWidth',{'1x',20},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            legendList=uilistbox('Parent',legendPanelGridLayout,'Items',{''},'Tag','legendList');
            imageLegendMoveUp=uiimage(legendPanelGridLayout,'ImageSource',IconArrowUp,'Tag','imageLegendMoveUp','ImageClickedFcn',@obj.moveSelectedParamUpInList);
            imageLegendMoveDown=uiimage(legendPanelGridLayout,'ImageSource',IconArrowDown,'Tag','imageLegendMoveDown','ImageClickedFcn',@obj.moveSelectedParamDownInList);
            legendList.Layout.Row=[1,4];
            imageLegendMoveUp.Layout.Row=1;
            imageLegendMoveDown.Layout.Row=3;
            legendList.Layout.Column=1;
            imageLegendMoveUp.Layout.Column=2;
            imageLegendMoveDown.Layout.Column=2;

            top2midRightPanelGridLayout=uigridlayout(top2midRightPanel,'RowHeight',{'1x'},'ColumnWidth',{'1x',20,20,'1x'},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            imageXaxis2Plot=uiimage(top2midRightPanelGridLayout,'ImageSource',IconArrowUp,'Tag','imageXaxis2Plot','ImageClickedFcn',@obj.moveSelectedParamBetweenLists);
            imagePlot2Xaxis=uiimage(top2midRightPanelGridLayout,'ImageSource',IconArrowDown,'Tag','imagePlot2Xaxis','ImageClickedFcn',@obj.moveSelectedParamBetweenLists);
            imageXaxis2Plot.Layout.Column=2;
            imagePlot2Xaxis.Layout.Column=3;

            bot2midRightPanelGridLayout=uigridlayout(bot2midRightPanel,'RowHeight',{'1x'},'ColumnWidth',{'1x',20,20,'1x'},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            imageLegend2Xaxis=uiimage(bot2midRightPanelGridLayout,'ImageSource',IconArrowUp,'Tag','imageLegend2Xaxis','ImageClickedFcn',@obj.moveSelectedParamBetweenLists);
            imageXaxis2Legend=uiimage(bot2midRightPanelGridLayout,'ImageSource',IconArrowDown,'Tag','imageXaxis2Legend','ImageClickedFcn',@obj.moveSelectedParamBetweenLists);
            imageLegend2Xaxis.Layout.Column=2;
            imageXaxis2Legend.Layout.Column=3;

            metricFilterTree.UserData={table,{[]},{[]},plotList,xAxisList,legendList};

            imageParams2Plots.UserData={table,metricFilterTree,plotList,xAxisList,legendList};
            imagePlots2Params.UserData={table,metricFilterTree,plotList,xAxisList,legendList};
            imageParams2Xaxis.UserData={table,metricFilterTree,xAxisList,plotList,legendList};
            imageXaxis2Params.UserData={table,metricFilterTree,xAxisList,plotList,legendList};
            imageParams2Legend.UserData={table,metricFilterTree,legendList,plotList,xAxisList};
            imageLegend2Params.UserData={table,metricFilterTree,legendList,plotList,xAxisList};

            imageXaxis2Plot.UserData={table,xAxisList,plotList};
            imagePlot2Xaxis.UserData={table,plotList,xAxisList};
            imageLegend2Xaxis.UserData={table,legendList,xAxisList};
            imageXaxis2Legend.UserData={table,xAxisList,legendList};

            imagePlotMoveUp.UserData={table,plotList};
            imagePlotMoveDown.UserData={table,plotList};
            imageXaxisMoveUp.UserData={table,xAxisList};
            imageXaxisMoveDown.UserData={table,xAxisList};
            imageLegendMoveUp.UserData={table,legendList};
            imageLegendMoveDown.UserData={table,legendList};


            obj.PlotOptionsTables{2}=table;
            obj.PlotOptionsPanels{2}=metricsPanel;
            obj.PlotOptionsTitleLabels{2}=titleLabel;
            obj.PlotOptionsFilters{2}=[];

            obj.PlotOptionsFilterFigures{2}=[];
            obj.PlotOptionsFilterButtons{2}=[];
            obj.PlotOptionsFilterCheckboxes{2}=[];
        end


        function createWaveformsPlotLegendAndVisibilityTable(obj)
            obj.MixedSignalAnalyzerTool.Model.IsChanged=true;

















            panel=uipanel(obj.OptionsFigLayout,'Tag','LegendPanel');
            panelGridLayout=uigridlayout(panel,'RowHeight',{24,22,'1x'},'ColumnWidth',{50,100,'1x',100},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            titleLabel=uilabel('Parent',panelGridLayout,'Text','Title','FontWeight','bold');
            filterCheckbox=uicheckbox('Parent',panelGridLayout,...
            'Value',1,...
            'Text',getString(message('msblks:mixedsignalanalyzer:SelectText')),...
            'Tooltip',getString(message('msblks:mixedsignalanalyzer:SelectTooltip')),...
            'ValueChangedFcn',@obj.selectAllRows);
            filterButton=uibutton('Parent',panelGridLayout,...
            'Text',getString(message('msblks:mixedsignalanalyzer:FilterText')),...
            'Tooltip',getString(message('msblks:mixedsignalanalyzer:FilterTooltip')),...
            'ButtonPushedFcn',@obj.showFilter);
            table=uitable(panelGridLayout);
            table.Data={1,2};
            table.ColumnSortable=true;
            table.CellEditCallback=@obj.plotOptionsCellEdited;
            table.DisplayDataChangedFcn=@obj.plotOptionsTableChanged;
            titleLabel.Layout.Row=1;
            filterCheckbox.Layout.Row=2;
            filterButton.Layout.Row=2;
            table.Layout.Row=3;
            titleLabel.Layout.Column=[1,4];
            filterCheckbox.Layout.Column=2;
            filterButton.Layout.Column=4;
            table.Layout.Column=[1,4];







            filterFigure=uifigure('Visible','off','Name','Title','CloseRequestFcn',@obj.hideFilter);
            filterGridLayout=uigridlayout(filterFigure,'RowHeight',{'1x',22},'ColumnWidth',{'1x',100,100,100},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            filterTree=uitree(filterGridLayout,'checkbox','CheckedNodesChangedFcn',@obj.filterCheckedNodesChanged);
            uitreenode(filterTree,'Text','Filter','NodeData',{filterFigure,filterTree,titleLabel,filterButton,table,[]});
            applyButton=uibutton('Parent',filterGridLayout,...
            'Text',getString(message('msblks:mixedsignalanalyzer:ApplyText')),...
            'ButtonPushedFcn',@obj.applyFilter);
            okButton=uibutton('Parent',filterGridLayout,...
            'Text',getString(message('msblks:mixedsignalanalyzer:OkText')),...
            'ButtonPushedFcn',@obj.applyAndHideFilter);
            cancelButton=uibutton('Parent',filterGridLayout,...
            'Text',getString(message('msblks:mixedsignalanalyzer:CancelText')),...
            'ButtonPushedFcn',@obj.hideFilter);
            filterTree.Layout.Row=1;
            applyButton.Layout.Row=2;
            okButton.Layout.Row=2;
            cancelButton.Layout.Row=2;
            filterTree.Layout.Column=[1,4];
            applyButton.Layout.Column=2;
            okButton.Layout.Column=3;
            cancelButton.Layout.Column=4;
            filterButton.UserData={filterFigure,filterTree};
            filterFigure.UserData={filterFigure,filterTree};
            applyButton.UserData={filterFigure,filterTree};
            okButton.UserData={filterFigure,filterTree};
            cancelButton.UserData={filterFigure,filterTree};


            obj.PlotOptionsTables{3}=table;
            obj.PlotOptionsPanels{3}=panel;
            obj.PlotOptionsTitleLabels{3}=titleLabel;
            obj.PlotOptionsFilters{3}=filterTree;

            obj.PlotOptionsFilterFigures{3}=filterFigure;
            obj.PlotOptionsFilterButtons{3}=filterButton;
            obj.PlotOptionsFilterCheckboxes{3}=filterCheckbox;
        end














        function addPlotOptionsTable(obj,pathname,fileName,waveformsDatabase,updateRequest)
            obj.MixedSignalAnalyzerTool.Model.IsChanged=true;

            if isempty(waveformsDatabase)||isempty(waveformsDatabase.SimulationResultsObjects)
                if isempty(updateRequest)

                    obj.PlotOptionsTables{end+1}=[];
                    obj.PlotOptionsPanels{end+1}=[];
                    obj.PlotOptionsTitleLabels{end+1}=[];
                    obj.PlotOptionsFilters{end+1}=[];

                    obj.PlotOptionsFilterFigures{end+1}=[];
                    obj.PlotOptionsFilterButtons{end+1}=[];
                    obj.PlotOptionsFilterCheckboxes{end+1}=[];
                end
                return;
            end


            if isempty(updateRequest)
                waveformsDB=waveformsDatabase;
                indexDB=length(obj.DataDB);
                resultsObjectCount=length(waveformsDB.SimulationResultsObjects);
            else

                indexDB=updateRequest{1};


                indexWaveformsSim=updateRequest{4};
                indexPanel2Update=updateRequest{5};



                waveformsDB=waveformsDatabase;

                resultsObject=waveformsDB.SimulationResultsObjects{indexWaveformsSim};
                resultsObjectCount=1;
            end
            for i=1:resultsObjectCount
                if isempty(updateRequest)
                    resultsObject=waveformsDB.SimulationResultsObjects{i};
                end
                tableName=resultsObject.getParamValue('tableName');
                nodesPerTable=resultsObject.getParamValue('nodes');
                cornersPerNode=resultsObject.getParamValue('corners');
                paramValuesPerCorner=resultsObject.getParamValue('paramValues');
                designParamsCountPerTable=resultsObject.getParamValue('designParamsCount');
                paramNamesPerTable_ShortMetrics=resultsObject.getParamValue('paramNames_ShortMetrics');
                metricsNamesPerCorner=obj.getMetricsNames(designParamsCountPerTable,paramNamesPerTable_ShortMetrics);
                title=fileName;
                if length(waveformsDB.SimulationResultsObjects)>1
                    title=[title,', ',tableName];%#ok<AGROW> Add session name to table's title.
                end
                for j=1:length(nodesPerTable)
                    title=[title,', ',nodesPerTable{j}];%#ok<AGROW> Add next node's name to table's title.
                end
                if isempty(paramNamesPerTable_ShortMetrics)

                    if isempty(updateRequest)
                        panel=uipanel(obj.OptionsFigLayout);
                        index=length(obj.OptionsFigLayout.RowHeight);
                    else
                        index=indexPanel2Update;
                        [panel,tableIndicesInPlotsUserData]=obj.getCleanCornerTablePanelForReuse(index);
                    end
                    obj.OptionsFigLayout.RowHeight{index}=0;
                    panel.UserData={indexDB,tableName};
                    panelGridLayout=uigridlayout(panel,'RowHeight',{24,22,'1x'},'ColumnWidth',{'1x'},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
                    titleLabel=uilabel('Parent',panelGridLayout,'Text',title,'Tooltip',pathname);

                    table=msblks.internal.apps.mixedsignalanalyzer.uitableStruct(panelGridLayout);
                    table.ColumnName=getString(message('msblks:mixedsignalanalyzer:NoCornersMessage'));




                    if isempty(updateRequest)

                        obj.PlotOptionsTables{end+1}=table;
                        obj.PlotOptionsPanels{end+1}=panel;
                        obj.PlotOptionsTitleLabels{end+1}=titleLabel;
                        obj.PlotOptionsFilters{end+1}=[];

                        obj.PlotOptionsFilterFigures{end+1}=[];
                        obj.PlotOptionsFilterButtons{end+1}=[];
                        obj.PlotOptionsFilterCheckboxes{end+1}=[];
                    else

                        obj.PlotOptionsTables{index}=table;
                        obj.PlotOptionsPanels{index}=panel;
                        obj.PlotOptionsTitleLabels{index}=titleLabel;
                        obj.PlotOptionsFilters{index}=[];

                        obj.PlotOptionsFilterFigures{index}=[];
                        obj.PlotOptionsFilterButtons{index}=[];
                        obj.PlotOptionsFilterCheckboxes{index}=[];
                    end
                    continue;
                end

                header=[{''},{'Corner'}];
                if~iscell(paramNamesPerTable_ShortMetrics)||length(paramNamesPerTable_ShortMetrics)>1||~isempty(paramNamesPerTable_ShortMetrics{1})
                    for j=1:length(paramNamesPerTable_ShortMetrics)
                        header=[header,paramNamesPerTable_ShortMetrics(j)];%#ok<AGROW> Add next column's name to table's header.
                    end
                end
























                if isempty(updateRequest)
                    panel=uipanel(obj.OptionsFigLayout,'Tag',['CornersPanel_',num2str(length(obj.PlotOptionsTables)+1)]);
                    index=length(obj.OptionsFigLayout.RowHeight);
                else
                    index=indexPanel2Update;
                    [panel,tableIndicesInPlotsUserData]=obj.getCleanCornerTablePanelForReuse(index);
                end
                obj.OptionsFigLayout.RowHeight{index}=0;
                panel.UserData={indexDB,tableName};

                panelGridLayout=uigridlayout(panel);
                titleLabel=uilabel('Parent',panelGridLayout,'Text',title);
                filterCheckbox=uicheckbox('Parent',panelGridLayout,...
                'Value',1,...
                'Text',getString(message('msblks:mixedsignalanalyzer:SelectText')),...
                'Tooltip',getString(message('msblks:mixedsignalanalyzer:SelectTooltip')),...
                'ValueChangedFcn',@obj.selectAllRows);
                filterButton=uibutton('Parent',panelGridLayout,...
                'Text',getString(message('msblks:mixedsignalanalyzer:FilterText')),...
                'Tooltip',getString(message('msblks:mixedsignalanalyzer:FilterTooltip')),...
                'ButtonPushedFcn',@obj.showFilter);
                drawAndPause(2.0);

                table=msblks.internal.apps.mixedsignalanalyzer.uitableStruct(panelGridLayout);
                table.ColumnName=header;















                [data,vals]=obj.getTableDataAndUniqueValues(cornersPerNode,paramValuesPerCorner);
                filterCheckbox.UserData={table,data};





                filterFigure=uifigure('Visible','off','Name',title,'CloseRequestFcn',@obj.hideFilter);

                filterGridLayout=uigridlayout(filterFigure);

                filterTree=msblks.internal.apps.mixedsignalanalyzer.uitreeStruct(filterGridLayout);


                filterRoot=msblks.internal.apps.mixedsignalanalyzer.uitreenodeStruct(filterTree);

                filterRoot.Text='Filter';
                filterRoot.NodeData={filterFigure,filterTree,titleLabel,filterButton,table,data};
                obj.populateFilterTree(filterTree,filterRoot,table,vals,true,metricsNamesPerCorner);

                applyButton=uibutton('Parent',filterGridLayout,...
                'Text',getString(message('msblks:mixedsignalanalyzer:ApplyText')),...
                'ButtonPushedFcn',@obj.applyFilter);
                okButton=uibutton('Parent',filterGridLayout,...
                'Text',getString(message('msblks:mixedsignalanalyzer:OkText')),...
                'ButtonPushedFcn',@obj.applyAndHideFilter);
                cancelButton=uibutton('Parent',filterGridLayout,...
                'Text',getString(message('msblks:mixedsignalanalyzer:CancelText')),...
                'ButtonPushedFcn',@obj.hideFilter);








                filterButton.UserData={filterFigure,filterTree};
                filterFigure.UserData={filterFigure,filterTree};
                applyButton.UserData={filterFigure,filterTree};
                okButton.UserData={filterFigure,filterTree};
                cancelButton.UserData={filterFigure,filterTree};
                plotHandles=[];
                plotWfNames=[];
                plotTitles=[];
                selectedNodes={};
                table.UserData={indexDB,tableName,nodesPerTable,...
                filterCheckbox,filterTree,...
                plotHandles,plotWfNames,plotTitles,...
                selectedNodes};
                table.Data=data;


                if isempty(updateRequest)

                    obj.PlotOptionsTables{end+1}=table;
                    obj.PlotOptionsPanels{end+1}=panel;
                    obj.PlotOptionsTitleLabels{end+1}=titleLabel;
                    obj.PlotOptionsFilters{end+1}=filterTree;

                    obj.PlotOptionsFilterFigures{end+1}=filterFigure;
                    obj.PlotOptionsFilterButtons{end+1}=filterButton;
                    obj.PlotOptionsFilterCheckboxes{end+1}=filterCheckbox;
                else

                    obj.PlotOptionsTables{index}=table;
                    obj.PlotOptionsPanels{index}=panel;
                    obj.PlotOptionsTitleLabels{index}=titleLabel;
                    obj.PlotOptionsFilters{index}=filterTree;

                    obj.PlotOptionsFilterFigures{index}=filterFigure;
                    obj.PlotOptionsFilterButtons{index}=filterButton;
                    obj.PlotOptionsFilterCheckboxes{index}=filterCheckbox;
                    for j=1:length(tableIndicesInPlotsUserData)
                        if tableIndicesInPlotsUserData{j}>0
                            obj.PlotFigs{j}.UserData{tableIndicesInPlotsUserData{j}}=table;
                        end
                    end
                end
            end
        end
        function[cornerTablePanel,tableIndicesInPlotsUserData]=getCleanCornerTablePanelForReuse(obj,index)

            oldTable=obj.PlotOptionsTables{index};
            oldPanel=obj.PlotOptionsPanels{index};
            obj.oldFilterFigure=obj.PlotOptionsFilterFigures{index};


            tableIndicesInPlotsUserData{length(obj.PlotFigs)}=[];
            for i=1:length(obj.PlotFigs)
                tableIndicesInPlotsUserData{i}=0;
                if~isvalid(obj.PlotFigs{i})||isempty(obj.PlotFigs{i}.UserData)
                    continue;
                end
                for j=1:length(obj.PlotFigs{i}.UserData)

                    if isa(obj.PlotFigs{i}.UserData{j},'msblks.internal.apps.mixedsignalanalyzer.uitableStruct')&&...
                        obj.PlotFigs{i}.UserData{j}==oldTable
                        tableIndicesInPlotsUserData{i}=j;
                        break;
                    end
                end
            end

            obj.oldCornerTableIndex=index;
            if~isempty(oldTable)

                obj.oldCornerTable=oldTable;
            end
            if~isempty(obj.oldFilterFigure)



                obj.oldFilterFigure.delete;
            end
            if~isempty(oldPanel)&&~isempty(oldPanel.Children)






                oldPanel.Children.delete;
            end
            cornerTablePanel=oldPanel;
        end
        function index=getExistingCornerTablePanelIndex(obj,dbIndex,simName)
            if~isempty(obj.OptionsFigLayout)
                for i=3:length(obj.OptionsFigLayout.Children)
                    if length(obj.OptionsFigLayout.Children(i).UserData)>1&&...
                        obj.OptionsFigLayout.Children(i).UserData{1}==dbIndex&&...
                        strcmpi(obj.OptionsFigLayout.Children(i).UserData{2},simName)
                        index=i;
                        return;
                    end
                end
            end
            index=0;
        end
        function[data,vals]=getTableDataAndUniqueValues(obj,cornersPerNode,paramValuesPerCorner)
            vals=[];
            data=[];
            if isempty(cornersPerNode)||isempty(paramValuesPerCorner)&&~all(startsWith(cornersPerNode,'Nominal','IgnoreCase',true))
                return;
            end

            if isempty(paramValuesPerCorner)
                data=cell(length(cornersPerNode),0);
            else
                data=cell(length(cornersPerNode),length(paramValuesPerCorner{1}));
            end
            for j=1:length(cornersPerNode)
                row=[true,cornersPerNode(j)];
                if~isempty(paramValuesPerCorner)
                    if~iscell(paramValuesPerCorner)
                        temp{1}=paramValuesPerCorner;
                        paramValuesPerCorner=temp;
                    end
                    for k=1:length(paramValuesPerCorner{j})
                        row=[row,paramValuesPerCorner{j}(k)];%#ok<AGROW> Next column value in current row.
                    end
                end
                for k=1:length(row)
                    data{j,k}=row{k};
                end
                if j==1
                    vals=row;
                else
                    for col=2:length(row)
                        colVal=row{col};
                        if ischar(colVal)&&~any(strcmp(vals{col},colVal))
                            vals{col}=[vals{col},{colVal}];%#ok<AGROW> Append new/unique string for column's popup filter.
                        elseif isnumeric(colVal)&&~any(ismember(vals{col},colVal))
                            vals{col}=[vals{col},colVal];%#ok<AGROW> Append new/unique number for column's popup filter.
                        end
                    end
                end
            end
        end
        function vals=getUniqueTableDataValues(obj,table)
            if isempty(table)||isempty(table.Data)
                vals=[];
                return;
            end

            vals{length(table.ColumnName)}=[];
            data=table.Data;
            for row=1:size(data,1)
                for column=1:size(data,2)
                    value=data{row,column};
                    if~isempty(value)
                        if ischar(value)&&~any(strcmp(vals{column},value))
                            vals{column}=[vals{column},{value}];
                        elseif isnumeric(value)&&(isempty(vals{column})||~any(ismember(vals{column},value)))
                            vals{column}=[vals{column},value];
                        end
                    end
                end
            end
        end
        function metricsNames=getMetricsNames(obj,designParamsCount,paramNames)
            if designParamsCount<length(paramNames)
                metricsNames{length(paramNames)-designParamsCount}=[];
                for i=designParamsCount+1:length(paramNames)
                    metricsNames{i-designParamsCount}=paramNames{i};
                end
            else
                metricsNames=[];
            end
        end
        function populateFilterTree(obj,filterTree,filterRoot,table,vals,skipCorners,excludedColumns)
            if isa(filterTree,'matlab.ui.container.CheckBoxTree')

                obj.populateFilter_uitree(filterTree,filterRoot,table,vals,skipCorners,excludedColumns);
            elseif isa(filterTree,'msblks.internal.apps.mixedsignalanalyzer.uitreeStruct')

                obj.populateFilter_uitreeStruct(filterTree,filterRoot,table,vals,skipCorners,excludedColumns);
            end
        end
        function populateFilter_uitree(obj,filterTree,filterRoot,table,vals,skipCorners,excludedColumns)





            filterTreeParent=filterTree.Parent;
            filterTree.Parent=[];

            if isempty(vals)

                for j=1:length(table.ColumnName)
                    colNam=table.ColumnName{j};
                    if obj.isIncludeColumn(colNam,skipCorners,excludedColumns)
                        uitreenode(filterRoot,'Text',colNam,'NodeData',{colNam});
                    end
                end
            else

                for j=1:length(vals)
                    colNam=table.ColumnName{j};
                    if obj.isIncludeColumn(colNam,skipCorners,excludedColumns)
                        filterColumnName=uitreenode(filterRoot,'Text',colNam,'NodeData',{colNam});
                        columnValues=convertCharsToStrings(vals{j});
                        total=length(columnValues);
                        if total>0


                            if isnumeric(columnValues)
                                colVal=num2str(columnValues(1));
                            else
                                colVal=columnValues{1};
                            end
                            nodes(total)=uitreenode(filterColumnName,'Text',colVal,'NodeData',{colNam,columnValues(1)});%#ok<AGROW>
                        end
                        for k=2:total


                            if isnumeric(columnValues)
                                colVal=num2str(columnValues(k));
                            else
                                colVal=columnValues{k};
                            end
                            nodes(k-1)=uitreenode(filterColumnName,'Text',colVal,'NodeData',{colNam,columnValues(k)});
                        end
                    end
                end
            end
            expand(filterTree);
            filterTree.CheckedNodes=filterRoot;
            filterTree.Parent=filterTreeParent;
        end
        function populateFilter_uitreeStruct(obj,filterTree,filterRoot,table,vals,skipCorners,excludedColumns)




            filterTree.Children=filterRoot;
            if isempty(table.ColumnName)
                return;
            end


            count=0;
            for j=1:length(table.ColumnName)
                colNam=table.ColumnName{j};
                if obj.isIncludeColumn(colNam,skipCorners,excludedColumns)
                    count=count+1;
                    if count==1
                        filterRoot.Children=msblks.internal.apps.mixedsignalanalyzer.uitreenodeStruct(filterRoot);
                    else
                        filterRoot.Children(count)=msblks.internal.apps.mixedsignalanalyzer.uitreenodeStruct(filterRoot);
                    end
                    filterRoot.Children(count).Text=colNam;
                    filterRoot.Children(count).NodeData={colNam};
                end
            end
            if count==0
                return;
            end


            count=0;
            for j=1:length(vals)
                colNam=table.ColumnName{j};
                if obj.isIncludeColumn(colNam,skipCorners,excludedColumns)
                    count=count+1;
                    columnNode=filterRoot.Children(count);
                    columnValues=convertCharsToStrings(vals{j});
                    total=length(columnValues);
                    for k=1:total

                        if isnumeric(columnValues)
                            colVal=num2str(columnValues(k));
                        else
                            colVal=columnValues{k};
                        end
                        if k==1
                            columnNode.Children=msblks.internal.apps.mixedsignalanalyzer.uitreenodeStruct(columnNode);
                        else
                            columnNode.Children(k)=msblks.internal.apps.mixedsignalanalyzer.uitreenodeStruct(columnNode);
                        end
                        columnNode.Children(k).Text=colVal;
                        columnNode.Children(k).NodeData={colNam,columnValues(k)};
                    end
                end
            end
        end
        function include=isIncludeColumn(obj,colNam,skipCorners,excludedColumns)
            include=~isempty(deblank(colNam))&&...
            ~strcmpi(colNam,obj.ColumnCheckboxText)&&...
            ~strcmpi(colNam,obj.ColumnWaveformNameText)&&...
            ~(skipCorners&&strcmpi(colNam,'Corner'));
            if include
                for i=1:length(excludedColumns)
                    if strcmpi(excludedColumns{i},colNam)
                        include=false;
                        return;
                    end
                end
            end
        end
        function enableFilterButtons(obj,enable)
            if~isempty(obj.PlotOptionsFilterButtons)
                for i=1:length(obj.PlotOptionsFilterButtons)
                    obj.PlotOptionsFilterButtons{i}.Enable=enable;
                end
            end
        end
        function selectAllRows(obj,src,event)
            if isempty(src)||~isvalid(src)
                return;
            end
            if src==obj.PlotOptionsFilterCheckboxes{3}

                selectedPlot=obj.getSelectedPlot();
                fullTable=selectedPlot.UserData{1}{1};
                fullData=fullTable.Data;

                displayedTable=obj.PlotOptionsTables{3};
                displayedData=displayedTable.Data;
                for displayedRow=1:getRowCount(displayedData)
                    displayedData{displayedRow,1}=src.Value;


                    for fullRow=1:getRowCount(fullData)

                        matchedFullRow=fullRow;
                        for column=2:length(fullTable.ColumnName)
                            if isnumeric(fullData{fullRow,column})
                                if~strcmp(num2str(fullData{fullRow,column}),num2str(displayedData{displayedRow,column}))
                                    matchedFullRow=0;
                                    break;
                                end
                            else
                                if~strcmp(fullData{fullRow,column},displayedData{displayedRow,column})
                                    matchedFullRow=0;
                                    break;
                                end
                            end
                        end

                        if matchedFullRow>0
                            fullData{matchedFullRow,1}=src.Value;


                            if src.Value
                                set(fullTable.UserData{matchedFullRow},'visible','on');
                            else
                                set(fullTable.UserData{matchedFullRow},'visible','off');
                            end
                            break;
                        end
                    end
                end
                if src.Value
                    obj.addPlotMargins();
                end
                displayedTable.Data=displayedData;
                if~isempty(selectedPlot)&&isvalid(selectedPlot)
                    fullTable.Data=fullData;
                    selectedPlot.UserData{1}{1}=fullTable;
                end
            elseif length(src.UserData)==2
                if~isempty(src.UserData{2})

                    table=src.UserData{1};
                    temp=table.Data;
                    for row=1:getRowCount(temp)
                        temp{row,1}=src.Value;
                        if~isempty(table.UserData{6})&&~isempty(table.UserData{7})

                            for wf=1:length(table.UserData{6})
                                commasCount=length(strfind(table.UserData{7}{wf},', '));
                                if commasCount>=3&&endsWith(table.UserData{7}{wf},[', ',temp{row,2}])||...
                                    commasCount==1&&strcmp(table.UserData{7}{wf},temp{row,2})
                                    if src.Value
                                        set(table.UserData{6}(wf),'visible','on');
                                    else
                                        set(table.UserData{6}(wf),'visible','off');
                                    end
                                end
                            end
                        end
                    end
                    if src.Value
                        obj.addPlotMargins();
                    end
                    table.Data=temp;
                end
            end
        end
        function applyAndHideFilter(obj,src,event)
            obj.applyFilter(src,event);
            obj.hideFilter(src,event);
        end
        function applyFilter(obj,src,event)
            if isempty(src)
                return;
            end
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyFiltering')));
                if src.Parent.Parent==obj.ToolstripFilterFigure

                    obj.MixedSignalAnalyzerTool.Model.IsChanged=true;
                    tree=obj.ToolstripFilterTree;
                    checked=tree.CheckedNodes;
                    for i=1:length(tree.Children)
                        dbNode=tree.Children(i);
                        for j=1:length(dbNode.Children)
                            simNode=dbNode.Children(j);
                            for k=1:length(simNode.Children)
                                listNode=simNode.Children(k);
                                index=listNode.NodeData;
                                cornerTableDialog=obj.PlotOptionsFilterFigures{index};
                                cornerTableFilter=obj.PlotOptionsFilters{index};
                                cornerTableChecked=[];
                                if~isempty(listNode.Children)

                                    for m=1:length(listNode.Children)
                                        paramNode=listNode.Children(m);
                                        for n=1:length(paramNode.Children)
                                            valNode=paramNode.Children(n);
                                            if~isempty(find(checked==valNode,1))

                                                cornerTableValueNode=valNode.NodeData;
                                                if isempty(cornerTableChecked)
                                                    cornerTableChecked=cornerTableValueNode;
                                                else
                                                    cornerTableChecked(end+1)=cornerTableValueNode;%#ok<AGROW>
                                                end
                                            end
                                        end
                                    end
                                elseif~isempty(find(checked==listNode,1))

                                    cornerTableChecked=listNode;
                                end

                                cornerTableOkButton=cornerTableDialog.Children.Children(3);
                                cornerTableFilter.CheckedNodes=cornerTableChecked;
                                obj.PlotOptionsFilterCheckedNodesChanged=true;
                                obj.applyFilter(cornerTableOkButton,[]);
                            end
                        end
                    end

                    obj.MixedSignalAnalyzerTool.Controller.showSelectedWaveforms();
                    obj.updateWaveformPlotTableAndControls([]);


                    for index=4:length(obj.PlotOptionsFilterFigures)
                        cornerTableDialog=obj.PlotOptionsFilterFigures{index};
                        cornerTableFilter=obj.PlotOptionsFilters{index};

                        cornerTableFilter.CheckedNodes=[];
                        if~isempty(cornerTableFilter.Children(1).Children)

                            for columnIndex=1:length(cornerTableFilter.Children(1).Children)
                                for valueIndex=1:length(cornerTableFilter.Children(1).Children(columnIndex).Children)
                                    if isempty(cornerTableFilter.CheckedNodes)
                                        cornerTableFilter.CheckedNodes=cornerTableFilter.Children(1).Children(columnIndex).Children(valueIndex);
                                    else
                                        cornerTableFilter.CheckedNodes(end+1)=cornerTableFilter.Children(1).Children(columnIndex).Children(valueIndex);
                                    end
                                end
                            end
                        else

                            cornerTableFilter.CheckedNodes=cornerTableFilter.Children(1);
                        end
                        cornerTableOkButton=cornerTableDialog.Children.Children(3);
                        obj.PlotOptionsFilterCheckedNodesChanged=true;
                        obj.applyFilter(cornerTableOkButton,[]);
                    end
                elseif src.Parent.Parent==obj.PlotOptionsFilterFigures{3}

                    obj.MixedSignalAnalyzerTool.Model.IsChanged=true;
                    obj.PlotOptionsFilterCheckedNodesChanged=false;
                    selectedPlot=obj.getSelectedPlot();
                    if~isempty(selectedPlot)&&...
                        iscell(selectedPlot.UserData{1})&&...
                        isstruct(selectedPlot.UserData{1}{1})&&...
                        strcmpi(selectedPlot.UserData{1}{1}.Type,'uitable')

                        table=selectedPlot.UserData{1}{1};
                        data=table.Data;
                        columnNames=table.ColumnName;
                    else
                        obj.MixedSignalAnalyzerTool.setStatus('');
                        return;
                    end
                    temp=[];
                    tree=[];
                    for child=1:length(obj.PlotOptionsFilterFigures{3}.Children(1).Children)
                        if strcmpi(obj.PlotOptionsFilterFigures{3}.Children(1).Children(child).Type,'uicheckboxtree')
                            tree=obj.PlotOptionsFilterFigures{3}.Children(1).Children(child);
                        end
                    end
                    if isempty(tree)
                        obj.MixedSignalAnalyzerTool.setStatus('');
                        return;
                    end
                    checked=tree.CheckedNodes;
                    obj.PlotOptionsFilterCheckedNodes=checked;
                    drawnow;
                    if~isempty(data)&&~isempty(checked)

                        for row=1:size(data,1)
                            include=true;
                            for column=3:length(columnNames)
                                colNam=columnNames{column};
                                colVal=data{row,column};
                                if isnumeric(colVal)
                                    colVal=num2str(colVal);
                                end

                                ignoreTableColumn=true;
                                for i=1:length(src.UserData{2}.Children.Children)
                                    if strcmp(src.UserData{2}.Children.Children(i).Text,colNam)
                                        ignoreTableColumn=false;
                                        break;
                                    end
                                end
                                if ignoreTableColumn
                                    continue;
                                end

                                found=false;
                                for i=1:length(checked)
                                    if checked(i).Parent~=tree&&...
                                        checked(i).Parent.Parent~=tree&&...
                                        strcmp(checked(i).Parent.Text,colNam)&&...
                                        (strcmp(checked(i).Text,colVal)||...
                                        isempty(colVal))
                                        found=true;
                                        break;
                                    end
                                end
                                if~found
                                    include=false;
                                    break;
                                end
                            end
                            if include

                                table.Data{row,1}=true;
                                obj.setLineVisible(table.UserData{row},true);


                                data{row,1}=true;
                                temp=[temp;data(row,:)];%#ok<AGROW> Append row to temp (filtered data).
                            else

                                table.Data{row,1}=false;
                                obj.setLineVisible(table.UserData{row},false);
                            end
                        end
                        [treeCheckedColumnNames,treeCheckedUniqueValues]=obj.getLegendVisibiltyFilterTreeCheckedData();
                        legendData={table,treeCheckedColumnNames,treeCheckedUniqueValues};
                        selectedPlot.UserData{1}=legendData;
                        obj.PlotOptionsTables{3}.Data=temp;
                        obj.addPlotMargins();
                    end
                elseif~isempty(src)&&length(src.UserData)==2&&obj.PlotOptionsFilterCheckedNodesChanged

                    obj.MixedSignalAnalyzerTool.Model.IsChanged=true;
                    obj.PlotOptionsFilterCheckedNodesChanged=false;
                    obj.PlotOptionsFilterCheckedNodes=src.UserData{2}.Children(1).NodeData{2}.CheckedNodes;
                    columnNames=src.UserData{2}.Children(1).NodeData{5}.ColumnName;
                    temp=[];
                    table=src.UserData{2}.Children(1).NodeData{5};
                    data=src.UserData{2}.Children(1).NodeData{6};
                    if~isempty(data)&&~isempty(obj.PlotOptionsFilterCheckedNodes)

                        for row=1:size(data,1)
                            include=true;
                            for column=1:length(columnNames)
                                if~isempty(deblank(columnNames{column}))

                                    ignoreTableColumn=true;
                                    for i=1:length(src.UserData{2}.Children.Children)
                                        if strcmp(src.UserData{2}.Children.Children(i).Text,columnNames{column})
                                            ignoreTableColumn=false;
                                            break;
                                        end
                                    end
                                    if ignoreTableColumn
                                        continue;
                                    end

                                    found=false;
                                    for i=1:length(obj.PlotOptionsFilterCheckedNodes)
                                        if length(obj.PlotOptionsFilterCheckedNodes(i).NodeData)==3&&...
                                            strcmpi(obj.PlotOptionsFilterCheckedNodes(i).NodeData{2},'Analysis Waveform')
                                            wf=obj.PlotOptionsFilterCheckedNodes(i).NodeData{3};
                                            wfName=wf.wfName;
                                            if strcmpi(data{row,column},wfName)
                                                found=true;
                                                break;
                                            end
                                        elseif~ischar(obj.PlotOptionsFilterCheckedNodes(i).NodeData)&&...
                                            length(obj.PlotOptionsFilterCheckedNodes(i).NodeData)==2
                                            name=obj.PlotOptionsFilterCheckedNodes(i).NodeData{1};
                                            value=obj.PlotOptionsFilterCheckedNodes(i).NodeData{2};
                                            if strcmpi(columnNames{column},name)&&...
                                                (isnumeric(value)&&data{row,column}==value||strcmpi(data{row,column},value))
                                                found=true;
                                                break;
                                            end
                                        end
                                    end
                                    if~found
                                        include=false;
                                        break;
                                    end
                                end
                            end
                            if include
                                temp=[temp;data(row,:)];%#ok<AGROW> Append row to temp (filtered data).
                            end
                        end
                    end
                    for i=1:getRowCount(table.Data)

                        for j=1:getRowCount(temp)
                            if strcmp(temp{j,2},table.Data{i,2})
                                temp{j,1}=table.Data{i,1};%#ok<AGROW> Get check/unchecked.
                                break;
                            end
                        end

                        for j=1:getRowCount(data)
                            if strcmp(data{j,2},table.Data{i,2})
                                data{j,1}=table.Data{i,1};
                                break;
                            end
                        end
                    end
                    table.Data=temp;
                    src.UserData{2}.Children(1).NodeData{6}=data;
                end
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            drawnow limitrate;
            obj.MixedSignalAnalyzerTool.setStatus('');
        end
        function showFilter(obj,src,event)
            if~isempty(src)&&length(src.UserData)==2&&strcmpi(src.UserData{1}.Visible,'off')
                if~isempty(src.UserData{2})

                end
                set(src.UserData{1},'WindowStyle','modal');
                obj.PlotOptionsFilterCheckedNodesChanged=false;
                obj.PlotOptionsFilterCheckedNodes=src.UserData{2}.Children(1).NodeData{2}.CheckedNodes;

                src.UserData{1}.Visible='on';
                src.UserData{2}.Children(1).NodeData{2}.FontColor='blue';
                src.UserData{2}.Children(1).NodeData{3}.FontColor='blue';
                src.UserData{2}.Children(1).NodeData{4}.FontColor='blue';
                src.UserData{2}.Children(1).NodeData{5}.ForegroundColor='blue';
            end
        end
        function hideFilter(obj,src,event)
            if isempty(src)
                return;
            end
            if~isempty(obj.ToolstripFilterFigure)&&...
                (obj.ToolstripFilterFigure==src||...
                ~isempty(src.Parent)&&~isempty(src.Parent.Parent)&&...
                obj.ToolstripFilterFigure==src.Parent.Parent)

                obj.ToolstripFilterFigure.Visible='off';
                return;
            end
            if length(src.UserData)==2&&strcmpi(src.UserData{1}.Visible,'on')

                if obj.PlotOptionsFilterCheckedNodesChanged

                    selection=uiconfirm(src.UserData{1},'Exit without applying changes?','Confirm Close','Icon','warning');
                    if strcmpi(selection,'Cancel')
                        return;
                    end
                end
                set(src.UserData{1},'WindowStyle','normal');
                obj.enableFilterButtons('on');
                src.UserData{1}.Visible='off';
                src.UserData{2}.Children(1).NodeData{2}.CheckedNodes=obj.PlotOptionsFilterCheckedNodes;
                src.UserData{2}.Children(1).NodeData{2}.FontColor='black';
                src.UserData{2}.Children(1).NodeData{3}.FontColor='black';
                src.UserData{2}.Children(1).NodeData{4}.FontColor='black';
                src.UserData{2}.Children(1).NodeData{5}.ForegroundColor='black';
            end
        end
        function filterCheckedNodesChanged(obj,src,event)
            obj.PlotOptionsFilterCheckedNodesChanged=true;
        end
        function metricFilterCheckedNodesChanged(obj,src,event)

            if isa(src,'matlab.ui.container.CheckBoxTree')&&length(src.UserData)>=6
                obj.MixedSignalAnalyzerTool.Model.IsChanged=true;

                table=src.UserData{1};
                cornerParams=src.UserData{2};
                metricParams=src.UserData{3};
                plotList=src.UserData{4};
                xAxisList=src.UserData{5};
                legendList=src.UserData{6};
                oldxAxisList=xAxisList.Items;
                if isempty(event.CheckedNodes)

                    plotList.Items={''};
                    xAxisList.Items={''};
                    legendList.Items={''};
                else

                    checkedParams={};
                    obj.setSortedCheckedNodes();
                    sortedCheckedNodes=src.CheckedNodes;
                    for i=1:2
                        switch i
                        case 1
                            params=metricParams;
                        case 2
                            params=cornerParams;
                        otherwise
                            break;
                        end
                        for j=1:length(params)
                            if obj.isChecked(sortedCheckedNodes,params{j})
                                checkedParams{end+1}=params{j};%#ok<AGROW>
                            end
                        end
                    end
                    for i=1:3
                        switch i
                        case 1
                            list=plotList;
                        case 2
                            list=xAxisList;
                        case 3
                            list=legendList;
                        otherwise
                            break;
                        end
                        for j=length(list.Items):-1:1

                            if~ismember(checkedParams,list.Items{j})
                                switch j
                                case length(list.Items)
                                    list.Items=list.Items(1:end-1);
                                case 1
                                    list.Items=list.Items(2:end);
                                otherwise
                                    list.Items={list.Items{1:j-1},list.Items{j+1:end}};
                                end
                            end
                        end
                    end
                    for i=1:length(checkedParams)

                        if(isempty(plotList.Items)||isempty(plotList.Items{1})||~any(ismember(plotList.Items,checkedParams{i})))&&...
                            (isempty(xAxisList.Items)||isempty(xAxisList.Items{1})||~any(ismember(xAxisList.Items,checkedParams{i})))&&...
                            (isempty(legendList.Items)||isempty(legendList.Items{1})||~any(ismember(legendList.Items,checkedParams{i})))
                            if any(ismember(metricParams,checkedParams{i}))
                                plotList.Items{end+1}=checkedParams{i};
                            else
                                xAxisList.Items{end+1}=checkedParams{i};
                            end
                        end
                    end
                end


                if obj.isChangedxAxisFromCsvOrXlxs(table.UserData,oldxAxisList,xAxisList.Items)
                    obj.updateTrendPlotTableAndControlsWrapper(table.UserData,xAxisList.Items);
                end

                obj.MixedSignalAnalyzerTool.Controller.showTrendChart();
            end
        end
        function checked=isChecked(obj,checkedTreeNodes,nodeName)
            checked=false;
            for i=1:length(checkedTreeNodes)
                if strcmpi(checkedTreeNodes(i).Text,nodeName)
                    checked=true;
                    return;
                end
            end
        end
        function plotOptionsCellEdited(obj,src,event)



            if event.Indices(2)==1
                obj.MixedSignalAnalyzerTool.Model.IsChanged=true;

                obj.editedIsChecked=event.EditData;
                obj.editedRowNumber=event.Indices(1);
                obj.editedRowCorner=src.Data{event.Indices(1),2};
                obj.editedRowCorner2=src.Data{event.Indices(1),3};
            end
        end
        function plotOptionsTableChanged(obj,src,event)
            if~isempty(src)&&...
                isprop(src,'Data')&&~isempty(src.Data)&&...
                isprop(src,'UserData')&&~isempty(src.UserData)

                if event.InteractionColumn==1

                    checked=src.Data{1,1};
                    for row=2:getRowCount(src.Data)
                        if src.Data{row,1}~=checked

                            checked=[];
                            break;
                        end
                    end
                    if~isempty(checked)

                        if src==obj.PlotOptionsTables{3}
                            obj.PlotOptionsFilterCheckboxes{3}.Value=checked;
                        elseif strcmpi(src.UserData{1},obj.AnalysisWaveformsText)
                            src.UserData{2}.Value=checked;
                        else
                            src.UserData{4}.Value=checked;
                        end
                    end

                    if~isempty(obj.editedRowNumber)&&obj.editedRowNumber>0



                        firstRow=obj.editedRowNumber;
                    else

                        firstRow=1;
                    end

                    if src==obj.PlotOptionsTables{3}

                        selectedPlot=obj.getSelectedPlot();
                        if~isempty(selectedPlot)&&isvalid(selectedPlot)

                            fullTableRow=0;
                            fullTable=selectedPlot.UserData{1}{1}.Data;
                            for row=firstRow:size(fullTable,1)
                                if strcmp(fullTable{row,2},obj.editedRowCorner)&&...
                                    strcmp(fullTable{row,3},obj.editedRowCorner2)
                                    fullTableRow=row;
                                    break;
                                end
                            end

                            if fullTableRow>0
                                obj.setLineVisible(src.UserData{fullTableRow},obj.editedIsChecked);
                            end

                            selectedPlot.UserData{1}{1}.Data{fullTableRow,1}=obj.editedIsChecked;
                        end
                    elseif~isempty(src.UserData{6})&&~isempty(src.UserData{7})&&~isempty(obj.editedRowCorner)

                        obj.MixedSignalAnalyzerTool.Model.IsChanged=true;
                        for wf=firstRow:length(src.UserData{6})
                            if strcmpi(src.UserData{1},obj.AnalysisWaveformsText)
                                if strcmp(src.UserData{7}(wf,:),obj.editedRowCorner)
                                    obj.setLineVisible(src.UserData{6}(wf),obj.editedIsChecked);
                                end
                            elseif endsWith(src.UserData{7}{wf},[', ',obj.editedRowCorner])
                                obj.setLineVisible(src.UserData{6}(wf),obj.editedIsChecked);
                            end
                        end
                    end
                end
            end
        end
        function setLineVisible(obj,lineHandle,isVisible)
            if~isempty(lineHandle)&&isvalid(lineHandle)&&islogical(isVisible)
                if isVisible
                    set(lineHandle,'visible','on');
                else
                    set(lineHandle,'visible','off');
                end
            end
        end


        function treeCheckedNodeChanged(obj,src,event)
            obj.MixedSignalAnalyzerTool.Model.IsChanged=true;
            obj.setSortedCheckedNodes();
            obj.enableFilterActions(~isempty(obj.DataTreeWaveformCheckedNodes));
            obj.enableAnalysisActions(~isempty(obj.DataTreeWaveformCheckedNodes));
            obj.enableMetricsActions(~isempty(obj.DataTreeMetricCheckedNodes));

        end
        function setSortedCheckedNodes(obj)




            obj.DataTreeCheckedNodes=[];
            obj.DataTreeMetricCheckedNodes=[];
            obj.DataTreeWaveformCheckedNodes=[];
            tree=obj.DataTree;

            checkedNodes=tree.SelectedNodes;
            if~isempty(obj.DataTree)&&~isempty(checkedNodes)
                isMetricSection=false;
                metricsSectionLevel=NaN;
                for i=1:length(tree.Children)
                    obj.addMatchedNode(tree.Children(i),checkedNodes,isMetricSection);
                    for j=1:length(tree.Children(i).Children)
                        if strcmpi(tree.Children(i).Children(j).Text,obj.MetricsText)

                            isMetricSection=true;
                            metricsSectionLevel=2;
                        end
                        obj.addMatchedNode(tree.Children(i).Children(j),checkedNodes,isMetricSection);
                        for k=1:length(tree.Children(i).Children(j).Children)
                            if strcmpi(tree.Children(i).Children(j).Children(k).Text,obj.MetricsText)

                                isMetricSection=true;
                                metricsSectionLevel=3;
                            end
                            obj.addMatchedNode(tree.Children(i).Children(j).Children(k),checkedNodes,isMetricSection);
                            for m=1:length(tree.Children(i).Children(j).Children(k).Children)
                                obj.addMatchedNode(tree.Children(i).Children(j).Children(k).Children(m),checkedNodes,isMetricSection);
                                for n=1:length(tree.Children(i).Children(j).Children(k).Children(m).Children)
                                    obj.addMatchedNode(tree.Children(i).Children(j).Children(k).Children(m).Children(n),checkedNodes,isMetricSection);
                                end
                            end
                        end
                        if metricsSectionLevel==3
                            isMetricSection=false;
                            metricsSectionLevel=NaN;
                        end
                    end
                    if metricsSectionLevel==2
                        isMetricSection=false;
                        metricsSectionLevel=NaN;
                    end
                end
            end
            obj.DataTreeCheckedNodes=obj.DataTreeCheckedNodes';
            obj.DataTreeMetricCheckedNodes=obj.DataTreeMetricCheckedNodes';
            obj.DataTreeWaveformCheckedNodes=obj.DataTreeWaveformCheckedNodes';
        end
        function addMatchedNode(obj,node,checkedNodes,isMetricSection)
            if~isempty(node)&&~isempty(checkedNodes)
                if length(node.NodeData)<=3
                    return;
                end
                for i=1:length(checkedNodes)
                    if checkedNodes(i)==node
                        if isempty(obj.DataTreeCheckedNodes)
                            obj.DataTreeCheckedNodes=checkedNodes(i);
                        else
                            obj.DataTreeCheckedNodes(end+1)=checkedNodes(i);
                        end
                        if isMetricSection
                            if isempty(obj.DataTreeMetricCheckedNodes)
                                obj.DataTreeMetricCheckedNodes=checkedNodes(i);
                            else
                                obj.DataTreeMetricCheckedNodes(end+1)=checkedNodes(i);
                            end
                        else
                            if isempty(obj.DataTreeWaveformCheckedNodes)
                                obj.DataTreeWaveformCheckedNodes=checkedNodes(i);
                            else
                                obj.DataTreeWaveformCheckedNodes(end+1)=checkedNodes(i);
                            end
                        end
                        return;
                    end
                end
            end
        end
        function updatePlotOptions(obj,tree)

            if isempty(tree)
                return;
            end

            nodes=tree.SelectedNodes;
            tablesAndNodes=[];
            for i=1:length(nodes)
                if length(nodes(i).NodeData)>=3&&...
                    (strcmp(nodes(i).NodeData{2},'Analysis Waveform')||...
                    strcmp(nodes(i).NodeData{2},'Analysis Metric'))
                    if isempty(tablesAndNodes)

                        tablesAndNodes=[nodes(i).NodeData(1),nodes(i).NodeData(2),nodes(i).NodeData(3)];
                    else

                        tablesAndNodes=[tablesAndNodes;[nodes(i).NodeData(1),nodes(i).NodeData(2),nodes(i).NodeData(3)]];%#ok<AGROW>
                    end
                elseif length(nodes(i).NodeData)==5||...
                    length(nodes(i).NodeData)==4

                    if isempty(tablesAndNodes)
                        tablesAndNodes=[nodes(i).NodeData(1),nodes(i).NodeData(2),nodes(i).NodeData(3)];
                    else
                        tablesAndNodesIndex=-1;
                        for j=1:size(tablesAndNodes,1)
                            if tablesAndNodes{j,1}==nodes(i).NodeData{1}&&...
                                strcmp(tablesAndNodes{j,2},nodes(i).NodeData{2})
                                tablesAndNodesIndex=j;
                                break;
                            end
                        end
                        if tablesAndNodesIndex==-1

                            tablesAndNodes=[tablesAndNodes;[nodes(i).NodeData(1),nodes(i).NodeData(2),nodes(i).NodeData(3)]];%#ok<AGROW>
                        elseif~any(contains(tablesAndNodes{tablesAndNodesIndex,3},nodes(i).NodeData{3}))

                            tablesAndNodes{tablesAndNodesIndex,3}=[tablesAndNodes{tablesAndNodesIndex,3},nodes(i).NodeData(3)];%#ok<AGROW>
                        end
                    end
                end
            end
            obj.DataTree_SelectedTablesAndNodes=tablesAndNodes;
            if obj.isChangedTables(tablesAndNodes)
                obj.clearPlotOptions();
                obj.setPlotOptions(tablesAndNodes);
            end
        end
        function isChanged=isChangedTables(obj,tablesAndNodes)

            isChanged=true;
            if size(tablesAndNodes,1)==size(obj.DisplayedTablesAndNodes,1)
                for i=1:size(tablesAndNodes,1)
                    if tablesAndNodes{i,1}~=obj.DisplayedTablesAndNodes{i,1}||...
                        ~strcmp(tablesAndNodes{i,2},obj.DisplayedTablesAndNodes{i,2})
                        return;
                    end
                end
                isChanged=false;
            end
        end
        function clearPlotOptions(obj)

            if~isempty(obj.OptionsFigLayout)
                for i=length(obj.PlotOptionsPanels):-1:1
                    if~isempty(obj.PlotOptionsPanels{i})
                        obj.OptionsFigLayout.RowHeight{i}=0;
                    end
                end
            end
        end
        function showTrendChartPlotOptions(obj)

            obj.OptionsFigLayout.RowHeight{1}='1x';
            obj.OptionsFigLayout.RowHeight{2}='1x';
        end
        function showWaveformPlotOptions(obj)

            obj.OptionsFigLayout.RowHeight{3}='1x';
        end
        function setPlotOptions(obj,tablesAndNodes)

            for i=4:length(obj.PlotOptionsPanels)
                for j=1:size(tablesAndNodes,1)
                    if obj.PlotOptionsPanels{i}.UserData{1}==tablesAndNodes{j,1}&&...
                        strcmp(obj.PlotOptionsPanels{i}.UserData{2},tablesAndNodes{j,2})
                        obj.OptionsFigLayout.RowHeight{i}='1x';
                        break;
                    end
                end
            end
            obj.DisplayedTablesAndNodes=tablesAndNodes;
        end
        function showPlotOptions(obj,tables)

            for i=1:2
                for j=1:length(tables)
                    if j==1&&iscell(tables{j})
                        continue;
                    end
                    if tables{j}==obj.PlotOptionsPanels{i}||tables{j}==obj.PlotOptionsTables{i}
                        obj.showTrendChartPlotOptions();
                        obj.DisplayedTablesAndNodes=[];
                        return;
                    end
                end
            end
            obj.showWaveformPlotOptions();
            obj.DisplayedTablesAndNodes=[];

























        end
        function synchronizeDataTreeWithPlot(obj,selectedFigure)

            checkedNodes=[];
            tables=selectedFigure.UserData;
            for i=1:length(tables)
                table=tables{i};
                if isempty(tables{i})||~isvalid(tables{i})
                    continue;
                end
                figHandles=table.UserData{9};
                for j=1:length(figHandles)
                    if figHandles{j}{1}==selectedFigure

                        nodes=figHandles{j}{2};
                        for k=1:length(nodes)
                            if isvalid(nodes(k))
                                if isempty(checkedNodes)
                                    checkedNodes=nodes(k);
                                else
                                    checkedNodes(end+1)=nodes(k);%#ok<AGROW>
                                end
                            end
                        end
                    end
                end
            end


        end


        function[wfNames,wfValues,wfTables,wfDbIndices]=getSelectedMetrics(obj)
            wfNames=[];
            wfValues=[];
            wfTables=[];
            wfDbIndices=[];
            if~isempty(obj.DataTreeMetricCheckedNodes)&&~isempty(obj.PlotOptionsPanels{2})
                for nodeIndex=1:length(obj.DataTreeMetricCheckedNodes)
                    node=obj.DataTreeMetricCheckedNodes(nodeIndex);
                    if length(node.NodeData)>=4
                        dbIndex=node.NodeData{1};
                        symRun=node.NodeData{2};
                        wfName=node.NodeData{3};


                    end
                    for tableIndex=4:length(obj.PlotOptionsTables)
                        table=obj.PlotOptionsTables{tableIndex};
                        if isnumeric(table.UserData{1})&&...
                            table.UserData{1}==dbIndex&&...
                            strcmpi(table.UserData{2},symRun)
                            wfNames{end+1}=wfName;%#ok<AGROW>
                            wfValues{end+1}=[];%#ok<AGROW> Metric values are in table.
                            wfTables{end+1}=table;%#ok<AGROW>
                            wfDbIndices{end+1}=dbIndex;%#ok<AGROW>
                        end
                    end
                end
            end
        end


        function[wfNames,wfValues,wfTables,wfDbIndices]=getPlottedWaveforms(obj,plot)
            wfNames=[];
            wfValues=[];
            wfTables=[];
            wfDbIndices=[];
            if~isempty(obj.DataDB)&&~isempty(obj.OptionsDoc)
                wfTotal=0;
                for i=1:length(plot.Tables)
                    wfTotal=wfTotal+length(plot.Tables{i}.wfNames);
                end
                if wfTotal>0
                    wfNames{wfTotal}=[];
                    wfValues{wfTotal}=[];
                    wfTables{wfTotal}=[];
                    wfDbIndices{wfTotal}=[];
                    wfCount=0;
                    obj.DataTreeWaveformCheckedNodes=[];
                    for i=1:length(plot.Tables)
                        dbIndex=plot.Tables{i}.dbIndex;
                        tableName=plot.Tables{i}.tableName;
                        [simulationResults,table]=obj.getSimulationResults(dbIndex,tableName);
                        for j=1:length(plot.Tables{i}.wfNames)
                            wfCount=wfCount+1;
                            wfNames{wfCount}=plot.Tables{i}.wfNames{j};
                            wfValues{wfCount}=simulationResults.getWaveform(wfNames{wfCount});
                            wfTables{wfCount}=table;
                            wfDbIndices{wfCount}=dbIndex;
                            if isempty(wfValues{wfCount})

                                wfValues{wfCount}=obj.DataDB(dbIndex).getAnalysisWaveform(wfNames{wfCount});
                            end
                            treeNode=obj.getTreeNode(dbIndex,wfNames{wfCount});
                            if~isempty(treeNode)
                                if isempty(obj.DataTreeWaveformCheckedNodes)

                                    obj.DataTreeWaveformCheckedNodes=treeNode;
                                else

                                    obj.DataTreeWaveformCheckedNodes(end+1)=treeNode;
                                end
                            end
                        end
                    end
                end
            end
        end
        function[simulationResults,table]=getSimulationResults(obj,dbIndex,tableName)

            simulationResults=[];
            table=[];
            if length(obj.DataDB)>=dbIndex
                for i=1:length(obj.DataDB(dbIndex).SimulationResultsNames)
                    if strcmp(obj.DataDB(dbIndex).SimulationResultsNames{i},tableName)

                        simulationResults=obj.DataDB(dbIndex).SimulationResultsObjects{i};
                        break;
                    end
                end
            end
            if~isempty(obj.OptionsFig)&&...
                ~isempty(obj.OptionsFig.Children)&&...
                ~isempty(obj.OptionsFig.Children.Children)
                for i=4:length(obj.OptionsFig.Children.Children)
                    if~isempty(obj.OptionsFig.Children.Children(i).Children)&&...
                        ~isempty(obj.OptionsFig.Children.Children(i).Children.Children)
                        for j=1:length(obj.OptionsFig.Children.Children(i).Children.Children)










                            if strcmpi(obj.OptionsFig.Children.Children(i).Children.Children(j).Type,'uicheckbox')



                                tableTemp=obj.OptionsFig.Children.Children(i).Children.Children(j).UserData{1};
                                userData=tableTemp.UserData;
                                if userData{1}==dbIndex&&strcmp(userData{2},tableName)

                                    table=tableTemp;
                                    return;
                                end
                                break;
                            end
                        end
                    end
                end
            end
        end
        function treeNode=getTreeNode(obj,dbIndex,wfName)



            treeNode=[];
            if~isempty(obj.DataTree)&&length(obj.DataTree.Children)>=dbIndex
                dbRootNode=obj.DataTree.Children(dbIndex);
                [simName,simType,nodeName,~]=unpackWaveformName(wfName);
                for i=1:length(dbRootNode.Children)
                    temp=dbRootNode.Children(i);
                    if obj.isMatchedTreeNode(temp,dbIndex,simName,simType,nodeName)
                        treeNode=temp;
                        return;
                    end
                    for j=1:length(dbRootNode.Children(i).Children)
                        temp=dbRootNode.Children(i).Children(j);
                        if obj.isMatchedTreeNode(temp,dbIndex,simName,simType,nodeName)
                            treeNode=temp;
                            return;
                        end
                        for k=1:length(dbRootNode.Children(i).Children(j).Children)
                            temp=dbRootNode.Children(i).Children(j).Children(k);
                            if obj.isMatchedTreeNode(temp,dbIndex,simName,simType,nodeName)
                                treeNode=temp;
                                return;
                            end
                            for m=1:length(dbRootNode.Children(i).Children(j).Children(k).Children)
                                temp=dbRootNode.Children(i).Children(j).Children(k).Children(m);
                                if obj.isMatchedTreeNode(temp,dbIndex,simName,simType,nodeName)
                                    treeNode=temp;
                                    return;
                                end
                            end
                        end
                    end
                end
            end
        end
        function matched=isMatchedTreeNode(obj,treeNode,dbIndex,simName,simType,nodeName)


            matched=~isempty(treeNode)&&...
            length(treeNode.NodeData)>=5&&...
            treeNode.NodeData{1}==dbIndex&&...
            strcmp(treeNode.NodeData{2},simName)&&...
            strcmp(treeNode.NodeData{4},simType)&&...
            strcmp(treeNode.NodeData{3},nodeName);
        end


        function[wfNames,wfValues,wfTables,wfDbIndices]=getSelectedWaveforms(obj)
            wfNames=[];
            wfValues=[];
            wfTables=[];
            wfDbIndices=[];
            if~isempty(obj.DataTreeWaveformCheckedNodes)&&~isempty(obj.PlotOptionsTables)
                for nodeIndex=1:length(obj.DataTreeWaveformCheckedNodes)
                    node=obj.DataTreeWaveformCheckedNodes(nodeIndex);
                    if length(node.NodeData)==5
                        dbIndex=node.NodeData{1};
                        symRun=node.NodeData{2};
                        wfName=node.NodeData{3};
                        simType=node.NodeData{4};

                        simulationsDB=obj.DataDB(dbIndex);
                        if isempty(simulationsDB)
                            continue;
                        end
                        simulationResults=simulationsDB.getSimulationResults(symRun);
                        if isempty(simulationResults)
                            continue;
                        end
                        for tableIndex=4:length(obj.PlotOptionsTables)
                            table=obj.PlotOptionsTables{tableIndex};
                            if isnumeric(table.UserData{1})&&...
                                table.UserData{1}==dbIndex&&...
                                strcmpi(table.UserData{2},symRun)
                                for tableRowIndex=1:getRowCount(table.Data)
                                    corner=table.Data{tableRowIndex,2};
                                    waveformName=packWaveformName(symRun,simType,wfName,corner);
                                    waveform=simulationResults.getWaveform(waveformName);
                                    if isempty(waveform)
                                        waveform=simulationsDB.getAnalysisWaveform(waveformName);
                                    end
                                    if~isempty(waveform)
                                        wfNames{end+1}=waveformName;%#ok<AGROW>
                                        wfValues{end+1}=waveform;%#ok<AGROW>
                                        wfTables{end+1}=table;%#ok<AGROW>
                                        wfDbIndices{end+1}=dbIndex;%#ok<AGROW>
                                    end
                                end
                                break;
                            end
                        end
                    end
                end
            end
        end


        function updateWaveformPlotTableAndControls(obj,updateRequest)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyCreatingPlotOptions')));
                [selectedPlot,doc]=obj.getSelectedPlot();
                if isempty(selectedPlot)||~obj.isWaveformPlot(selectedPlot)
                    obj.MixedSignalAnalyzerTool.setStatus('');
                    return;
                end
                wfTables=selectedPlot.UserData;
                if isempty(wfTables)||...
                    length(obj.PlotOptionsTables)<=3||...
                    iscell(wfTables)&&length(wfTables)==1&&length(wfTables{1})==3&&isstruct(wfTables{1}{1})
                    selectedPlot.UserData=[];
                    obj.clearPlotOptions();
                    drawnow limitrate;
                    obj.MixedSignalAnalyzerTool.setStatus('');
                    return;
                end
                obj.MixedSignalAnalyzerTool.Model.IsChanged=true;


                legendTable=obj.PlotOptionsTables{3};


                plotTag=obj.getPlotTag(selectedPlot);
                if isempty(plotTag)
                    obj.MixedSignalAnalyzerTool.setStatus('');
                    return;
                end

                obj.PlotOptionsTitleLabels{3}.Text=doc.Title;
                obj.PlotOptionsFilterFigures{3}.Name=doc.Title;
                obj.clearPlotOptions();
                if length(wfTables)>1

                    uniqueTables=[];
                    for i=1:length(wfTables)
                        if i==1&&iscell(wfTables{i})
                            continue;
                        end
                        if~any(ismember(uniqueTables,wfTables{i}))
                            if isempty(uniqueTables)
                                uniqueTables=wfTables{i};
                            else
                                uniqueTables(end+1)=wfTables{i};%#ok<AGROW>
                            end
                        end
                    end
                    wfTables=num2cell(uniqueTables);
                end
                if length(wfTables)==1



                    table=wfTables{1};
                    columnNames=table.ColumnName;
                    tableValues=table.Data;
                    indexDB=table.UserData{1};
                    wfLines=table.UserData{6};
                    wfNames=table.UserData{7};
                    wfTags=table.UserData{8};


                    if length(obj.DataDB)==1
                        waveformsDB=obj.DataDB;
                    else
                        waveformsDB=obj.DataDB(indexDB);
                    end
                    dbName=waveformsDB.matFileName;


                    header{length(columnNames)+2}=[];
                    header{1}=obj.ColumnCheckboxText;
                    header{2}=obj.ColumnWaveformNameText;
                    header{3}=obj.ColumnCornerText;
                    header{4}=obj.ColumnDataPointText;
                    for i=3:length(columnNames)
                        header{i+2}=columnNames{i};
                    end


                    rowCount=0;
                    for i=1:length(wfTags)
                        if strcmpi(wfTags{i},plotTag)
                            rowCount=rowCount+1;
                        end
                    end
                    if~iscell(selectedPlot.UserData{1})||~isempty(updateRequest)
                        oldRowCount=0;
                    else
                        data=selectedPlot.UserData{1}{1}.Data;
                        plotLines=selectedPlot.UserData{1}{1}.UserData;
                        oldRowCount=length(plotLines);
                    end
                    if rowCount>0
                        data{rowCount,length(header)}=[];
                        plotLines{rowCount}=[];
                    else
                        data={};
                        plotLines={};
                    end


                    rowCount=0;
                    for i=1:length(wfTags)
                        if strcmpi(wfTags{i},plotTag)
                            rowCount=rowCount+1;
                            if rowCount<=oldRowCount
                                continue;
                            end
                            plotLines{rowCount}=wfLines(i);
                            name=wfNames{i};
                            ptrs=strfind(name,', ');
                            if~isempty(ptrs)

                                ptr=ptrs(end);
                                corner=extractAfter(name,ptr+1);
                                name=extractBefore(name,ptr);
                                ptr2=strfind(name,')');
                                if length(ptr2)>1
                                    ptr2=ptr2(1);
                                end
                                if length(ptrs)>1
                                    ptr=ptrs(end-1);
                                    if ptr2>1



                                        name=[extractBefore(name,ptr2),'.',extractAfter(name,ptr+1),')'];
                                    else



                                        name=[extractBefore(name,ptr),'.',extractAfter(name,ptr+1)];
                                    end
                                end

                                data{rowCount,1}=true;
                                data{rowCount,2}=[dbName,', ',name];
                                for j=1:size(tableValues,1)
                                    if strcmp(tableValues{j,2},corner)
                                        ptr3=strfind(corner,'<DataPoint>');
                                        if isempty(ptr3)
                                            dataPoint='';
                                        else
                                            dataPoint=extractAfter(corner,ptr3+10);
                                            corner=extractBefore(corner,ptr3);
                                        end
                                        data{rowCount,3}=corner;
                                        data{rowCount,4}=dataPoint;
                                        for k=3:length(columnNames)
                                            data{rowCount,k+2}=tableValues{j,k};
                                        end
                                        break;
                                    end
                                end
                            end
                        end
                    end
                else



                    mergedCornerParams=[];
                    mergedCornerMetrics=[];
                    for tableIndex=1:length(wfTables)

                        table=wfTables{tableIndex};
                        columnNames=table.ColumnName;
                        indexDB=table.UserData{1};
                        symRun=table.UserData{2};


                        if length(obj.DataDB)==1
                            waveformsDB=obj.DataDB;
                        else
                            waveformsDB=obj.DataDB(indexDB);
                        end
                        cornerParams=[];
                        metricParams=[];
                        for i=1:length(waveformsDB.SimulationResultsNames)
                            if strcmp(waveformsDB.SimulationResultsNames{i},symRun)
                                cornerParams=waveformsDB.SimulationResultsObjects{i}.getShortParamNames();
                                metricParams=columnNames(length(cornerParams)+3:end);
                                break;
                            end
                        end
                        for i=1:length(cornerParams)
                            if isempty(mergedCornerParams)
                                mergedCornerParams=cornerParams(i);
                            elseif~any(contains(mergedCornerParams,cornerParams(i)))
                                mergedCornerParams(end+1)=cornerParams(i);%#ok<AGROW> Save next unique corner param name (shared/merged between tables).
                            end
                        end
                        for i=1:length(metricParams)
                            if isempty(mergedCornerMetrics)
                                mergedCornerMetrics=metricParams(i);
                            elseif~any(contains(mergedCornerMetrics,metricParams(i)))
                                mergedCornerMetrics(end+1)=metricParams(i);%#ok<AGROW> Save next unique metric name (shared/merged between tables).
                            end
                        end
                    end


                    paramsTotal=length(mergedCornerParams);
                    metricsTotal=length(mergedCornerMetrics);
                    header{paramsTotal+metricsTotal+3}=[];
                    header{1}=obj.ColumnCheckboxText;
                    header{2}=obj.ColumnWaveformNameText;
                    header{3}=obj.ColumnCornerText;
                    header{4}=obj.ColumnDataPointText;
                    offset=4;
                    for i=1:paramsTotal
                        header{i+offset}=mergedCornerParams{i};
                    end
                    offset=4+paramsTotal;
                    for i=1:metricsTotal
                        header{i+offset}=mergedCornerMetrics{i};
                    end


                    rowCount=0;
                    for tableIndex=1:length(wfTables)
                        table=wfTables{tableIndex};
                        wfTags=table.UserData{8};
                        for i=1:length(wfTags)
                            if strcmpi(wfTags{i},plotTag)
                                rowCount=rowCount+1;
                            end
                        end
                    end
                    if rowCount>0
                        data{rowCount,length(header)}=[];
                        plotLines{rowCount}=[];
                    else
                        data={};
                        plotLines={};
                    end


                    rowCount=0;
                    for tableIndex=1:length(wfTables)

                        table=wfTables{tableIndex};
                        columnNames=table.ColumnName;
                        tableValues=table.Data;
                        indexDB=table.UserData{1};
                        wfLines=table.UserData{6};
                        wfNames=table.UserData{7};
                        wfTags=table.UserData{8};


                        if length(obj.DataDB)==1
                            waveformsDB=obj.DataDB;
                        else
                            waveformsDB=obj.DataDB(indexDB);
                        end
                        dbName=waveformsDB.matFileName;

                        for i=1:length(wfTags)
                            if strcmpi(wfTags{i},plotTag)
                                rowCount=rowCount+1;
                                plotLines{rowCount}=wfLines(i);
                                name=wfNames{i};
                                ptrs=strfind(name,', ');
                                if~isempty(ptrs)

                                    ptr=ptrs(end);
                                    corner=extractAfter(name,ptr+1);
                                    name=extractBefore(name,ptr);
                                    ptr2=strfind(name,')');
                                    if length(ptr2)>1
                                        ptr2=ptr2(1);
                                    end
                                    if length(ptrs)>1
                                        ptr=ptrs(end-1);
                                        if ptr2>1



                                            name=[extractBefore(name,ptr2),'.',extractAfter(name,ptr+1),')'];
                                        else



                                            name=[extractBefore(name,ptr),'.',extractAfter(name,ptr+1)];
                                        end
                                    end

                                    data{rowCount,1}=true;
                                    data{rowCount,2}=[dbName,', ',name];
                                    for j=1:size(tableValues,1)
                                        if strcmp(tableValues{j,2},corner)
                                            ptr3=strfind(corner,'<DataPoint>');
                                            if isempty(ptr3)
                                                dataPoint='';
                                            else
                                                dataPoint=extractAfter(corner,ptr3+10);
                                                corner=extractBefore(corner,ptr3);
                                            end
                                            data{rowCount,3}=corner;
                                            data{rowCount,4}=dataPoint;
                                            for k=3:length(columnNames)
                                                for m=1:length(header)
                                                    if strcmp(columnNames{k},header{m})
                                                        data{rowCount,m}=tableValues{j,k};
                                                        break;
                                                    end
                                                end
                                            end
                                            break;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if~isempty(table)

                    editable=false(1,length(header));
                    editable(1)=true;
                    legendTable.Data=data;
                    legendTable.UserData=plotLines;
                    legendTable.ColumnName=header;
                    legendTable.ColumnWidth='auto';
                    legendTable.ColumnSortable=true;
                    legendTable.ColumnEditable=editable;


                    filterForUpdate=obj.populateLegendVisibiltyFilterTree(selectedPlot,legendTable,updateRequest);


                    [treeCheckedColumnNames,treeCheckedUniqueValues]=obj.getLegendVisibiltyFilterTreeCheckedData();
                    legendData={legendTable.get,treeCheckedColumnNames,treeCheckedUniqueValues};
                    if iscell(selectedPlot.UserData{1})
                        selectedPlot.UserData{1}=legendData;
                    else
                        selectedPlot.UserData={legendData,selectedPlot.UserData{1:end}};
                    end

                    obj.showWaveformPlotOptions();
                    if~isempty(updateRequest)&&filterForUpdate
                        obj.applyFilter(obj.PlotOptionsFilterFigures{3}.Children(1).Children(3),[]);
                    end
                end
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            drawnow limitrate;
            obj.MixedSignalAnalyzerTool.setStatus('');
        end
        function plotTag=getPlotTag(obj,selectedPlot)
            for i=1:length(obj.PlotFigs)
                if obj.PlotFigs{i}==selectedPlot

                    plotTag=obj.PlotDocs{i}.Tag;
                    return;
                end
            end
            plotTag=[];
        end
        function filterForUpdate=populateLegendVisibiltyFilterTree(obj,selectedPlot,legendTable,updateRequest)
            filterForUpdate=false;
            if~isempty(legendTable)
                if~isempty(updateRequest)

                    if isempty(obj.PlotOptionsFilters{3})||isempty(obj.PlotOptionsFilters{3}.CheckedNodes)
                        checkedNodeText=[];
                    else
                        checkedNodeText{length(obj.PlotOptionsFilters{3}.CheckedNodes)}=[];
                        for i=1:length(checkedNodeText)
                            checkedNodeText{i}=obj.PlotOptionsFilters{3}.CheckedNodes(i).Text;
                        end
                    end
                end

                excludedColumns={};
                for i=1:length(legendTable.ColumnName)
                    columnName=legendTable.ColumnName{i};
                    excluded=true;
                    for j=1:length(selectedPlot.UserData)
                        if length(selectedPlot.UserData{j})>1
                            continue;
                        end
                        if strcmpi(selectedPlot.UserData{j}.Type,'uitable')&&...
                            strcmpi(selectedPlot.UserData{j}.UserData{5}.Type,'uicheckboxtree')
                            for k=1:length(selectedPlot.UserData{j}.UserData{5}.Children(1).Children)
                                if strcmp(selectedPlot.UserData{j}.UserData{5}.Children(1).Children(k).Text,columnName)
                                    excluded=false;
                                    break;
                                end
                            end
                        end
                        if~excluded
                            break;
                        end
                    end
                    if excluded
                        excludedColumns{end+1}=columnName;%#ok<AGROW>
                    end
                end

                filterTree=obj.PlotOptionsFilters{3};
                filterRoot=obj.PlotOptionsFilters{3}.Children(1);
                if~isempty(filterRoot.Children)&&any(isvalid(filterRoot.Children))

                    delete(filterRoot.Children);
                    filterRoot.Children=[];
                end
                vals=obj.getUniqueTableDataValues(legendTable);
                obj.populateFilterTree(filterTree,filterRoot,legendTable,vals,true,excludedColumns);
                if~isempty(updateRequest)&&~isempty(checkedNodeText)
                    valuesCheckedCount=0;
                    checkedNodes=[];
                    for i=1:length(filterRoot.Children)
                        columnNodeChecked=false;
                        for j=1:length(checkedNodeText)
                            if strcmpi(filterRoot.Children(i).Text,checkedNodeText{j})

                                if isempty(checkedNodes)
                                    checkedNodes=filterRoot.Children(i);
                                else
                                    checkedNodes(end+1)=filterRoot.Children(i);%#ok<AGROW>
                                end
                                columnNodeChecked=true;
                                break;
                            end
                        end
                        if~columnNodeChecked
                            valueNodeChecked=false;
                            for j=1:length(filterRoot.Children(i).Children)
                                for k=1:length(checkedNodeText)
                                    if strcmpi(filterRoot.Children(i).Children(j).Text,checkedNodeText{k})

                                        if isempty(checkedNodes)
                                            checkedNodes=filterRoot.Children(i).Children(j);
                                        else
                                            checkedNodes(end+1)=filterRoot.Children(i).Children(j);%#ok<AGROW>
                                        end
                                        valueNodeChecked=true;
                                        valuesCheckedCount=valuesCheckedCount+1;
                                        break;
                                    end
                                end
                            end
                            if~valueNodeChecked

                                if isempty(checkedNodes)
                                    checkedNodes=filterRoot.Children(i);
                                else
                                    checkedNodes(end+1)=filterRoot.Children(i);%#ok<AGROW>
                                end
                            end
                        end
                    end
                    if~isempty(checkedNodes)&&valuesCheckedCount>0



                        filterTree.CheckedNodes=checkedNodes;
                        filterForUpdate=true;
                    end
                end
            end
        end
        function[columnNames,uniqueValues]=getLegendVisibiltyFilterTreeCheckedData(obj)
            tree=obj.PlotOptionsFilters{3};
            checked=tree.CheckedNodes;
            count=0;
            for i=1:length(checked)
                if checked(i).Parent~=tree&&...
                    checked(i).Parent.Parent~=tree
                    count=count+1;
                end
            end
            if count==0
                columnNames=[];
                uniqueValues=[];
                return;
            end
            columnNames{count}=[];
            uniqueValues{count}=[];
            count=0;
            for i=1:length(checked)
                if checked(i).Parent~=tree&&...
                    checked(i).Parent.Parent~=tree
                    count=count+1;
                    columnNames{count}=checked(i).Parent.Text;
                    uniqueValues{count}=checked(i).Text;
                end
            end
        end


        function updateTrendPlotTableAndControlsWrapper(obj,wfTables,xAxisListItems)




            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyUpdatingTrendChartPlotOptions')));
                obj.updateTrendPlotTableAndControls(wfTables,xAxisListItems);
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
        end
        function updateTrendPlotTableAndControls(obj,wfTables,xAxisListItems)
            drawAndPause(1.0);
            if isempty(wfTables)||length(obj.PlotOptionsTables)<=3


                return;
            end
            if~isempty(xAxisListItems)&&length(wfTables)==1



                return;
            end
            obj.MixedSignalAnalyzerTool.Model.IsChanged=true;


            [mergedTable,metricsPanel,metricFilterTree,metricFilterRoot,tablesListBox,...
            plotList,xAxisList,legendList]=obj.getTrendChartWidgets();

            if~isempty(xAxisListItems)







                lastTableColumnNames=metricFilterTree.UserData{1}.ColumnName;
                plotListItems=plotList.Items;
                legendListItems=legendList.Items;
                xAxisListItemsMorphed=xAxisListItems;
                [namesInXAxisList,namesInCsvOrXlsx]=obj.getCsvOrXlxsMetricsInXAxisList(wfTables,xAxisListItems);
            end

            obj.clearPlotOptions();
            if length(wfTables)>1

                uniqueTables(1)=wfTables{1};
                for i=2:length(wfTables)
                    if~any(ismember(uniqueTables,wfTables{i}))
                        uniqueTables(end+1)=wfTables{i};%#ok<AGROW>
                    end
                end
                wfTables=num2cell(uniqueTables);
            end
            selectedMetrics={};
            excludedMetrics={};
            if length(wfTables)==1

                table=wfTables{1};
                indexDB=table.UserData{1};
                if length(obj.DataDB)==1
                    waveformsDB=obj.DataDB;
                else
                    waveformsDB=obj.DataDB(indexDB);
                end
                symRun=table.UserData{2};
                for i=1:length(waveformsDB.SimulationResultsNames)
                    if strcmp(waveformsDB.SimulationResultsNames{i},symRun)
                        [cornerParams,metricParams]=waveformsDB.SimulationResultsObjects{i}.getShortParamNames();
                        if~isempty(cornerParams)
                            [selectedMetrics,excludedMetrics]=obj.splitMetricParams(indexDB,symRun,metricParams);
                        else



                            [selectedMetrics,~]=obj.splitMetricParams(indexDB,symRun,metricParams);
                            excludedMetrics={};
                        end
                        checkedAnalysisMetricNames=obj.getAnalysisMetricNames(indexDB,symRun,true);
                        for j=1:length(checkedAnalysisMetricNames)

                            selectedMetrics{end+1}=checkedAnalysisMetricNames{j};%#ok<AGROW>
                            metricParams{end+1}=checkedAnalysisMetricNames{j};%#ok<AGROW>
                        end
                        uncheckedAnalysisMetricNames=obj.getAnalysisMetricNames(indexDB,symRun,false);
                        for j=1:length(uncheckedAnalysisMetricNames)

                            excludedMetrics{end+1}=uncheckedAnalysisMetricNames{j};%#ok<AGROW>
                        end
                        plotList.Items=metricParams;
                        xAxisList.Items=cornerParams;
                        legendList.Items={''};
                        tablesListBox.Items={[waveformsDB.matFileName,', ',symRun]};
                        columnNames=table.ColumnName;
                        break;
                    end
                end
            else

                dataIDs{length(wfTables)}=[];
                symRuns{length(wfTables)}=[];
                tablesListBox.Items={};
                mergedCornerParams=[];
                mergedSelectedMetrics={};
                mergedExcludedMetrics={};
                for tableIndex=1:length(wfTables)
                    table=wfTables{tableIndex};
                    indexDB=table.UserData{1};
                    if length(obj.DataDB)==1
                        waveformsDB=obj.DataDB;
                    else
                        waveformsDB=obj.DataDB(indexDB);
                    end
                    symRun=table.UserData{2};
                    for i=1:length(waveformsDB.SimulationResultsNames)
                        if strcmp(waveformsDB.SimulationResultsNames{i},symRun)
                            dataIDs{tableIndex}=table.UserData{1};
                            symRuns{tableIndex}=symRun;
                            [cornerParams,metricParams]=waveformsDB.SimulationResultsObjects{i}.getShortParamNames();
                            if~isempty(cornerParams)
                                [selectedMetrics,excludedMetrics]=obj.splitMetricParams(indexDB,symRun,metricParams);
                            else



                                [selectedMetrics,~]=obj.splitMetricParams(indexDB,symRun,metricParams);
                                excludedMetrics={};
                                if~isempty(xAxisListItems)

                                    postfix=['(',num2str(tableIndex),')'];





                                    for j=1:length(metricParams)
                                        if~any(strcmp(lastTableColumnNames,[metricParams{j},postfix]))&&...
                                            any(strcmp(lastTableColumnNames,metricParams{j}))&&...
                                            any(strcmp(xAxisListItems,metricParams{j}))
                                            cornerParams{end+1}=metricParams{j};%#ok<AGROW> Add non-postfixed .csv/.xlsx Metric to corner parameters list.
                                            metricParams{j}=[];
                                        end
                                    end
                                    for j=length(metricParams):-1:1
                                        if isempty(metricParams{j})
                                            metricParams(j)=[];
                                        end
                                    end







                                    for j=1:length(namesInXAxisList)
                                        if endsWith(namesInXAxisList{j},postfix)

                                            cornerParams{end+1}=namesInCsvOrXlsx{j};%#ok<AGROW> Add .csv/.xlsx Metric to corner parameter list.
                                            for k=1:length(metricParams)
                                                if strcmp(namesInCsvOrXlsx{j},metricParams{k})
                                                    metricParams(k)=[];
                                                    break;
                                                end
                                            end

                                            nameInCsvOrXlsxFoundInXaxisList=false;
                                            for k=1:length(xAxisListItemsMorphed)
                                                if strcmp(namesInCsvOrXlsx{j},xAxisListItemsMorphed{k})
                                                    nameInCsvOrXlsxFoundInXaxisList=true;
                                                    break;
                                                end
                                            end

                                            for k=1:length(xAxisListItemsMorphed)
                                                if strcmp(namesInXAxisList{j},xAxisListItemsMorphed{k})
                                                    if nameInCsvOrXlsxFoundInXaxisList

                                                        xAxisListItemsMorphed(k)=[];
                                                    else

                                                        xAxisListItemsMorphed{k}=namesInCsvOrXlsx{j};
                                                    end
                                                    break;
                                                end
                                            end
                                        end
                                    end
                                    if~isempty(cornerParams)

                                        table=obj.moveTableMetricsRight(table,metricParams);
                                    end
                                end
                            end
                            checkedAnalysisMetricNames=obj.getAnalysisMetricNames(indexDB,symRun,true);
                            for j=1:length(checkedAnalysisMetricNames)

                                selectedMetrics{end+1}=checkedAnalysisMetricNames{j};%#ok<AGROW>
                                metricParams{end+1}=checkedAnalysisMetricNames{j};%#ok<AGROW>
                            end
                            uncheckedAnalysisMetricNames=obj.getAnalysisMetricNames(indexDB,symRun,false);
                            for j=1:length(uncheckedAnalysisMetricNames)

                                excludedMetrics{end+1}=uncheckedAnalysisMetricNames{j};%#ok<AGROW>
                            end
                            for j=1:length(selectedMetrics)

                                selectedMetrics{j}=[selectedMetrics{j},'(',num2str(tableIndex),')'];
                            end
                            for j=1:length(excludedMetrics)

                                excludedMetrics{j}=[excludedMetrics{j}{1},'(',num2str(tableIndex),')'];
                            end

                            for j=length(cornerParams)+length(metricParams)+3:length(table.ColumnName)

                                metricParams{end+1}=table.ColumnName{j};%#ok<AGROW>
                            end
                            cornerParamsCount=length(cornerParams);
                            metricParamsCount=length(metricParams);
                            for j=1:metricParamsCount

                                metricParams{j}=[metricParams{j},'(',num2str(tableIndex),')'];
                            end
                            tablesListBox.Items{end+1}=['(',num2str(tableIndex),') ',waveformsDB.matFileName,', ',symRun];
                            if tableIndex==1||isempty(mergedCornerParams)&&isempty(mergedMetricParams)

                                mergedTable.Data=table.Data;
                                mergedTable.ColumnName=table.ColumnName;
                                mergedCornerParams=cornerParams;
                                mergedMetricParams=metricParams;
                                mergedSelectedMetrics=selectedMetrics;
                                mergedExcludedMetrics=excludedMetrics;


                                for j=1:metricParamsCount
                                    mergedTable.ColumnName(end-metricParamsCount+j)=metricParams(j);
                                end
                            else





                                mergedSelectedMetrics=[mergedSelectedMetrics,selectedMetrics];%#ok<AGROW>
                                mergedExcludedMetrics=[mergedExcludedMetrics,excludedMetrics];%#ok<AGROW>


                                cornerParamIndices=zeros(1,cornerParamsCount);
                                foundCount=0;
                                for j=1:cornerParamsCount
                                    for k=1:length(mergedCornerParams)
                                        if strcmpi(cornerParams{j},mergedCornerParams{k})
                                            cornerParamIndices(j)=k+2;
                                            foundCount=foundCount+1;
                                            break;
                                        end
                                    end
                                end
                                if foundCount==length(mergedCornerParams)&&foundCount==cornerParamsCount





                                    data=table.Data;
                                    mergedData=mergedTable.Data;
                                    mergedData{size(mergedData,1),size(mergedData,2)+metricParamsCount}=[];
                                    for dataRow=1:size(table.Data,1)
                                        if isempty(cornerParamIndices)||isempty(mergedCornerParams)



                                            isSameCorner=false;
                                        else
                                            isSameCorner=true;
                                            for mergedRow=1:size(mergedData,1)
                                                isSameCorner=true;
                                                for j=1:length(cornerParamIndices)
                                                    x=data(dataRow,j+2);
                                                    if iscell(x)
                                                        x=x{1};
                                                    end
                                                    if isnumeric(x)
                                                        x=num2str(x);
                                                    end
                                                    y=mergedData(mergedRow,cornerParamIndices(j));
                                                    if iscell(y)
                                                        y=y{1};
                                                    end
                                                    if isnumeric(y)
                                                        y=num2str(y);
                                                    end
                                                    if cornerParamIndices(j)==0||...
                                                        ~strcmpi(x,y)
                                                        isSameCorner=false;
                                                        break;
                                                    end
                                                end
                                                if isSameCorner
                                                    break;
                                                end
                                            end
                                        end
                                        if isSameCorner

                                            for j=1:metricParamsCount
                                                mergedData{mergedRow,end-metricParamsCount+j}=data{dataRow,2+cornerParamsCount+j};
                                            end
                                        else

                                            [rowCount,columnCount]=size(mergedData);
                                            rowCount=rowCount+1;
                                            mergedData{rowCount,columnCount}=[];
                                            for j=1:length(cornerParamIndices)

                                                mergedData{rowCount,cornerParamIndices(j)}=data{dataRow,j+2};
                                            end
                                            for j=1:metricParamsCount

                                                mergedData{rowCount,end-metricParamsCount+j}=data{dataRow,j+2+cornerParamsCount};
                                            end
                                        end
                                    end
                                else




                                    data=table.Data;
                                    mergedData=mergedTable.Data;
                                    mergedRowCount=size(mergedData,1);
                                    mergedColumnCount=size(mergedData,2);
                                    mergedColumnNames=mergedTable.ColumnName;
                                    newCornerParamsCount=cornerParamsCount-foundCount;
                                    mergedData{mergedRowCount+size(data,1),...
                                    mergedColumnCount+metricParamsCount+newCornerParamsCount}=[];

                                    mergedCornerParamsCount=length(mergedCornerParams);
                                    mergedMetricParamsCount=length(mergedMetricParams);
                                    if newCornerParamsCount>0
                                        for mergedRow=1:mergedRowCount
                                            for mergedColumn=mergedCornerParamsCount+mergedMetricParamsCount+2:-1:mergedCornerParamsCount+3
                                                mergedData{mergedRow,mergedColumn+newCornerParamsCount}=mergedData{mergedRow,mergedColumn};
                                                mergedData{mergedRow,mergedColumn}=[];
                                            end
                                        end
                                    end

                                    for dataRow=1:size(data,1)
                                        newParamCount=0;
                                        newMetricCount=0;
                                        for dataColumn=3:size(data,2)
                                            if dataColumn-2<=cornerParamsCount&&cornerParamIndices(dataColumn-2)>0

                                                mergedColumn=cornerParamIndices(dataColumn-2);
                                            else

                                                if dataColumn-2<=cornerParamsCount

                                                    newParamCount=newParamCount+1;
                                                    mergedColumn=mergedCornerParamsCount+newParamCount+2;
                                                else

                                                    newMetricCount=newMetricCount+1;
                                                    mergedColumn=mergedColumnCount+newCornerParamsCount+newMetricCount;
                                                end
                                            end

                                            mergedData{mergedRowCount+dataRow,mergedColumn}=data{dataRow,dataColumn};
                                        end
                                    end

                                    if newCornerParamsCount>0
                                        for mergedColumn=mergedCornerParamsCount+mergedMetricParamsCount+2:-1:mergedCornerParamsCount+3

                                            mergedColumnNames{mergedColumn+newCornerParamsCount}=mergedColumnNames{mergedColumn};
                                            mergedColumnNames{mergedColumn}=[];
                                        end
                                        newParamCount=0;
                                        for dataColumn=3:cornerParamsCount+2
                                            if cornerParamIndices(dataColumn-2)<1

                                                newParamCount=newParamCount+1;
                                                mergedColumn=mergedCornerParamsCount+newParamCount+2;
                                                mergedColumnNames{mergedColumn}=table.ColumnName{dataColumn};
                                                mergedCornerParams{end+1}=table.ColumnName{dataColumn};%#ok<AGROW>
                                            end
                                        end
                                        mergedTable.ColumnName=mergedColumnNames;
                                    end
                                end

                                for j=1:metricParamsCount
                                    mergedMetricParams{end+1}=metricParams{j};%#ok<AGROW>
                                end

                                for j=1:metricParamsCount
                                    mergedTable.ColumnName(end+1)=metricParams(j);
                                end
                                mergedTable.Data=mergedData;
                            end
                        end
                    end
                end
                selectedMetrics=mergedSelectedMetrics;
                excludedMetrics=mergedExcludedMetrics;
                plotList.Items=mergedMetricParams;
                xAxisList.Items=mergedCornerParams;
                legendList.Items={''};
                table=mergedTable;
                columnNames=table.ColumnName;
            end
            if~isempty(table)
                columnNames{1}=' ';
                tableForDisplay=cell2table(table.Data,'VariableNames',columnNames);
                tableForDisplay=removevars(tableForDisplay,{' ','Corner'});
                for j=1:length(excludedMetrics)
                    tableForDisplay=removevars(tableForDisplay,excludedMetrics{j});
                end
                cellsForDisplay=table2cell(tableForDisplay);
                for row=1:size(cellsForDisplay,1)
                    for column=1:size(cellsForDisplay,2)
                        if~iscell(cellsForDisplay{row,column})&&isnumeric(cellsForDisplay{row,column})
                            cellsForDisplay{row,column}=num2str(cellsForDisplay{row,column});
                        end
                    end
                end
                columnNames=columnNames(3:end);
                for j=length(columnNames):-1:1
                    for k=1:length(excludedMetrics)
                        if strcmp(excludedMetrics{k},columnNames{j})
                            columnNames(j)=[];
                            break;
                        end
                    end
                end
                for j=(length(plotList.Items)+length(xAxisList.Items)+1):length(columnNames)
                    plotList.Items{end+1}=columnNames{j};
                end
                tableForDisplay=cell2table(cellsForDisplay,'VariableNames',columnNames);
                for j=1:length(columnNames)
                    columnNames{j}=[' ',columnNames{j},' '];
                end
                tableForSorting=table2cell(tableForDisplay);
                for row=1:size(tableForSorting,1)
                    for column=1:size(tableForSorting,2)
                        if ischar(tableForSorting{row,column})

                            tableForSorting{row,column}=msblks.utilities.str2doubleSI(tableForSorting{row,column});
                        end
                    end
                end
                tableForSorting=cell2table(tableForSorting,'VariableNames',columnNames);
                for column=1:size(tableForSorting,2)
                    if iscell(tableForSorting{1,column})
                        for row=1:size(tableForSorting,1)
                            value=tableForSorting{row,column}{1};
                            if isnan(value)
                                tableForSorting(row,column)={' '};
                            end
                        end
                    end
                end
                T=[tableForDisplay,tableForSorting];
                plotHandles=[];
                plotWfNames=[];
                plotTitles=[];
                metricsPanel.UserData={indexDB,waveformsDB.SimulationResultsNames{i},...
                waveformsDB.SimulationResultsObjects{i}.getParamValue('nodes'),T,...
                plotHandles,plotWfNames,plotTitles};
                mergedTable.Data=table2cell(tableForDisplay);
                mergedTable.ColumnName=tableForDisplay.Properties.VariableNames;
                if~isempty(metricFilterRoot.Children)

                    delete(metricFilterRoot.Children);
                    metricFilterRoot.Children=[];
                end
                vals=[];
                obj.populateFilterTree(metricFilterTree,metricFilterRoot,table,vals,true,excludedMetrics);
                obj.showTrendChartPlotOptions();
                metricFilterTree.UserData{1}=table;
                metricFilterTree.UserData{2}=xAxisList.Items;
                metricFilterTree.UserData{3}=plotList.Items;
                metricFilterTree.UserData{4}=plotList;
                metricFilterTree.UserData{5}=xAxisList;
                metricFilterTree.UserData{6}=legendList;
                if~isempty(selectedMetrics)


                    plotList.Items=selectedMetrics;
                end


                vals=obj.getUniqueTableDataValues(table);
                if~isempty(xAxisList.Items)
                    cornerParams{length(xAxisList.Items)}=[];
                    cornerParamsUniqueValuesCount{length(xAxisList.Items)}=[];
                    for j=1:length(xAxisList.Items)
                        cornerParams{j}=xAxisList.Items{j};

                        cornerParamsUniqueValuesCount{j}=length(vals{j+2});



                    end
                    for j=1:length(cornerParams)-1
                        for k=j+1:length(cornerParams)
                            if cornerParamsUniqueValuesCount{j}<cornerParamsUniqueValuesCount{k}
                                temp=cornerParamsUniqueValuesCount{j};
                                cornerParamsUniqueValuesCount{j}=cornerParamsUniqueValuesCount{k};
                                cornerParamsUniqueValuesCount{k}=temp;
                                temp=cornerParams{j};
                                cornerParams{j}=cornerParams{k};
                                cornerParams{k}=temp;
                            end
                        end
                    end
                    xAxisList.Items=cornerParams(1:min(3,length(cornerParams)));
                end
                obj.updateMetricFilterTree(metricFilterTree,plotList,xAxisList,legendList);


                for tableIndex=1:length(wfTables)
                    table=wfTables{tableIndex};
                    indexDB=table.UserData{1};
                    if length(obj.DataDB)==1
                        waveformsDB=obj.DataDB;
                    else
                        waveformsDB=obj.DataDB(indexDB);
                    end
                    symRun=table.UserData{2};
                    for i=1:length(waveformsDB.SimulationResultsNames)
                        if strcmp(waveformsDB.SimulationResultsNames{i},symRun)
                            simulationResults=waveformsDB.SimulationResultsObjects{i};
                            params_ShortVsLongNames=simulationResults.getParamValue('params_ShortVsLongNames');
                            for j=1:length(params_ShortVsLongNames)
                                shortName=params_ShortVsLongNames{j}{1};
                                if obj.isIncludeColumn(shortName,false,excludedMetrics)
                                    originalName=params_ShortVsLongNames{j}{2};
                                    if length(wfTables)==1
                                        tablesListBox.Items{end+1}=['* ',shortName,' = ',originalName];
                                    else
                                        tablesListBox.Items{end+1}=['* ',shortName,'(',num2str(tableIndex),') = ',originalName];
                                    end
                                end
                            end
                        end
                    end
                end

                for tableIndex=1:length(wfTables)
                    table=wfTables{tableIndex};
                    indexDB=table.UserData{1};
                    if length(obj.DataDB)==1
                        waveformsDB=obj.DataDB;
                    else
                        waveformsDB=obj.DataDB(indexDB);
                    end
                    symRun=table.UserData{2};
                    for i=1:length(waveformsDB.SimulationResultsNames)
                        if strcmp(waveformsDB.SimulationResultsNames{i},symRun)
                            simulationResults=waveformsDB.SimulationResultsObjects{i};
                            corModelSpecPerTable_ShortVsLongValues=simulationResults.getParamValue('corModelSpec_ShortVsLongValues');
                            for j=1:length(corModelSpecPerTable_ShortVsLongValues)
                                shortName=corModelSpecPerTable_ShortVsLongValues{j}{1};
                                originalName=corModelSpecPerTable_ShortVsLongValues{j}{2};
                                if length(wfTables)==1
                                    tablesListBox.Items{end+1}=['> ',shortName,' = ',originalName];
                                else
                                    tablesListBox.Items{end+1}=['> ',shortName,'(',num2str(tableIndex),') = ',originalName];
                                end
                            end
                        end
                    end
                end
                mergedTable.UserData=wfTables;
                obj.OptionsFigLayout.RowHeight{1}='1x';
                obj.OptionsFigLayout.RowHeight{2}='1x';
            end
            if~isempty(xAxisListItems)






                plotList.Items=plotListItems;
                xAxisList.Items=xAxisListItemsMorphed;
                legendList.Items=legendListItems;
                obj.MixedSignalAnalyzerTool.Controller.showTrendChart();
            end
        end
        function analysisMetricNames=getAnalysisMetricNames(obj,indexDB,symRun,getCheckedAnalysisMetrics)
            analysisMetricNames={};
            names=obj.DataDB(indexDB).analysisMetricNames;
            data=obj.DataDB(indexDB).analysisMetricData;
            for i=1:length(data)
                if data{i}{1}==indexDB&&strcmp(data{i}{2},symRun)
                    isChecked=false;
                    for k=1:length(obj.DataTreeMetricCheckedNodes)
                        if isequal(data{i},obj.DataTreeMetricCheckedNodes(k).NodeData)

                            isChecked=true;
                            break;
                        end
                    end



                    if isChecked==getCheckedAnalysisMetrics
                        analysisMetricNames{end+1}=names{i};%#ok<AGROW>
                    end
                end
            end
        end
        function[selectedMetrics,excludedMetrics]=splitMetricParams(obj,dbIndex,symRun,metricParams)



            selectedMetrics={};
            excludedMetrics={};
            for i=1:length(metricParams)
                include=false;
                for j=1:length(obj.DataTreeMetricCheckedNodes)
                    if dbIndex==obj.DataTreeMetricCheckedNodes(j).NodeData{1}&&...
                        strcmp(symRun,obj.DataTreeMetricCheckedNodes(j).NodeData{2})&&...
                        strcmp(metricParams{i},obj.DataTreeMetricCheckedNodes(j).NodeData{3})
                        include=true;
                        break;
                    end
                end
                if include
                    selectedMetrics{end+1}=metricParams{i};%#ok<AGROW> Add to cell array of chars.
                else
                    excludedMetrics{end+1}=metricParams(i);%#ok<AGROW> Add to cell array of cells.
                end
            end
        end
        function tableOut=moveTableMetricsRight(obj,tableIn,metricParams)

            tableOut.ColumnName=tableIn.ColumnName;
            tableOut.Data=tableIn.Data;
            for i=1:length(metricParams)
                for j=1:length(tableOut.ColumnName)-1
                    if strcmp(metricParams{i},tableOut.ColumnName{j})
                        if j==1
                            tableOut.ColumnName=[tableOut.ColumnName(j+1:end),tableOut.ColumnName(j)];
                            tableOut.Data=[tableOut.Data(:,j+1:end),tableOut.Data(:,j)];
                        else
                            tableOut.ColumnName=[tableOut.ColumnName(1:j-1),tableOut.ColumnName(j+1:end),tableOut.ColumnName(j)];
                            tableOut.Data=[tableOut.Data(:,1:j-1),tableOut.Data(:,j+1:end),tableOut.Data(:,j)];
                        end
                        break;
                    end
                end
            end
        end
        function isChanged=isChangedxAxisFromCsvOrXlxs(obj,wfTables,oldxAxisList,newxAxisList)

            isChanged=false;




            xAxisListChanges={};
            list1=oldxAxisList;
            list2=newxAxisList;
            for i=1:2
                for j=1:length(list1)
                    found=false;
                    for k=1:length(list2)
                        if strcmp(list1{j},list2{k})
                            found=true;
                            break;
                        end
                    end
                    if~found
                        xAxisListChanges{end+1}=list1{j};%#ok<AGROW>
                    end
                end
                list1=newxAxisList;
                list2=oldxAxisList;
            end
            if isempty(xAxisListChanges)
                return;
            end


            for i=1:length(wfTables)
                table=wfTables{i};
                if~isa(table,'msblks.internal.apps.mixedsignalanalyzer.uitableStruct')
                    continue;
                end
                tableName=table.UserData{2};
                simulationsDB=obj.DataDB(table.UserData{1});
                simulation=[];
                for j=1:length(simulationsDB.SimulationResultsNames)
                    if strcmp(tableName,simulationsDB.SimulationResultsNames{j})
                        simulation=simulationsDB.SimulationResultsObjects{j};
                        break;
                    end
                end
                if~isempty(simulation)&&simulation.getParamValue('designParamsCount')==0
                    postfix=['(',num2str(i),')'];
                    paramNames=simulation.getParamValue('paramNames');
                    for j=1:length(xAxisListChanges)
                        if length(wfTables)>1&&endsWith(xAxisListChanges{j},postfix)
                            change=extractBefore(xAxisListChanges{j},postfix);
                        else
                            change=xAxisListChanges{j};
                        end
                        for k=1:length(paramNames)
                            if strcmpi(paramNames{k},change)
                                isChanged=true;
                                return;
                            end
                        end
                    end
                end
            end
        end
        function[namesInXAxisList,namesInCsvOrXlsx]=getCsvOrXlxsMetricsInXAxisList(obj,wfTables,xAxisListItems)

            namesInXAxisList={};
            namesInCsvOrXlsx={};
            if isempty(wfTables)||isempty(xAxisListItems)
                return;
            end


            for i=1:length(wfTables)
                table=wfTables{i};
                tableName=table.UserData{2};
                simulationsDB=obj.DataDB(table.UserData{1});
                simulation=[];
                for j=1:length(simulationsDB.SimulationResultsNames)
                    if strcmp(tableName,simulationsDB.SimulationResultsNames{j})
                        simulation=simulationsDB.SimulationResultsObjects{j};
                        break;
                    end
                end
                if~isempty(simulation)&&simulation.getParamValue('designParamsCount')==0
                    postfix=['(',num2str(i),')'];
                    paramNames=simulation.getParamValue('paramNames');
                    for j=1:length(xAxisListItems)
                        if length(wfTables)>1&&endsWith(xAxisListItems{j},postfix)
                            originalMetricName=extractBefore(xAxisListItems{j},postfix);
                        else

                            continue;
                        end
                        for k=1:length(paramNames)
                            if strcmpi(paramNames{k},originalMetricName)
                                namesInXAxisList{end+1}=xAxisListItems{j};%#ok<AGROW> Metric name in Trend Chart's X-Axis list.
                                namesInCsvOrXlsx{end+1}=originalMetricName;%#ok<AGROW> Original Metric name in .csv or .xlsx file.
                            end
                        end
                    end
                end
            end
        end


        function clearTrendChartWidgets(obj)

            [mergedTable,metricsPanel,metricFilterTree,metricFilterRoot,tablesListBox,...
            plotList,xAxisList,legendList]=obj.getTrendChartWidgets();


            mergedTable.Data=[];
            mergedTable.ColumnName=[];
            tablesListBox.Items={};
            xAxisList.Items={};
            plotList.Items={};
            legendList.Items={};
            metricsPanel.UserData{4}=[];

            if~isempty(metricFilterRoot.Children)

                delete(metricFilterRoot.Children);
                metricFilterRoot.Children=[];
            end


            metricFilterTree.UserData{1}=mergedTable;
            metricFilterTree.UserData{2}=[];
            metricFilterTree.UserData{3}=[];
            metricFilterTree.UserData{4}=plotList;
            metricFilterTree.UserData{5}=xAxisList;
            metricFilterTree.UserData{6}=legendList;
        end


        function loadWaveformLegendAndVisibilityTable(obj,savedData)

            [selectedPlot,doc]=obj.getSelectedPlot();
            if~isempty(doc)
                if strcmp(obj.PlotOptionsTitleLabels{3}.Text,doc.Title)

                    return;
                else

                    obj.PlotOptionsTitleLabels{3}.Text=doc.Title;
                    obj.PlotOptionsFilterFigures{3}.Name=doc.Title;
                end
            end

            savedTable=savedData{1};
            legendTable=obj.PlotOptionsTables{3};
            legendTable.Data=savedTable.Data;
            legendTable.UserData=savedTable.UserData;
            legendTable.ColumnName=savedTable.ColumnName;
            legendTable.ColumnWidth=savedTable.ColumnWidth;
            legendTable.ColumnSortable=savedTable.ColumnSortable;
            legendTable.ColumnEditable=savedTable.ColumnEditable;


            obj.populateLegendVisibiltyFilterTree(selectedPlot,legendTable,[]);
            treeCheckedColumnNames=savedData{2};
            treeCheckedUniqueValues=savedData{3};
            tree=obj.PlotOptionsFilters{3};
            treeRoot=tree.Children(1);
            if~isempty(treeCheckedUniqueValues)

                checkedNodes(length(treeCheckedUniqueValues))=treeRoot;
                count=0;
                for i=1:length(treeRoot.Children)
                    columnName=treeRoot.Children(i).Text;
                    for j=1:length(treeRoot.Children(i).Children)
                        uniqueValue=treeRoot.Children(i).Children(j).Text;
                        for k=1:length(checkedNodes)
                            if strcmp(treeCheckedColumnNames{k},columnName)&&strcmp(treeCheckedUniqueValues{k},uniqueValue)
                                count=count+1;
                                checkedNodes(count)=treeRoot.Children(i).Children(j);
                                break;
                            end
                        end
                    end
                end
            else

                checkedNodes=treeRoot;
            end
            if isempty(checkedNodes)
                tree.CheckedNodes=[];
            else
                tree.CheckedNodes=checkedNodes;
            end
            obj.applyFilter(obj.PlotOptionsFilterFigures{3}.Children(1).Children(3),[]);
        end


        function loadTrendChartWidgets(obj,...
            T,...
            tableData,...
            tableColumnName,...
            symRunNames,...
            cornerParams,...
            metricParams,...
            xAxisParams,...
            yAxisParams,...
            legendParams,...
            checkedNodes)


            [mergedTable,metricsPanel,metricFilterTree,metricFilterRoot,tablesListBox,...
            plotList,xAxisList,legendList]=obj.getTrendChartWidgets();


            mergedTable.Data=tableData;
            mergedTable.ColumnName=tableColumnName;
            tablesListBox.Items=symRunNames;
            xAxisList.Items=xAxisParams;
            plotList.Items=yAxisParams;
            legendList.Items=legendParams;
            metricsPanel.UserData{4}=T;

            if~isempty(metricFilterRoot.Children)

                delete(metricFilterRoot.Children);
                metricFilterRoot.Children=[];
            end



            vals=[];
            obj.populateFilterTree(metricFilterTree,metricFilterRoot,mergedTable,vals,true,[]);
            metricFilterTree.UserData{1}=mergedTable;
            metricFilterTree.UserData{2}=cornerParams;
            metricFilterTree.UserData{3}=metricParams;
            metricFilterTree.UserData{4}=plotList;
            metricFilterTree.UserData{5}=xAxisList;
            metricFilterTree.UserData{6}=legendList;


            obj.updateMetricFilterTree(metricFilterTree,plotList,xAxisList,legendList);

            if~isempty(checkedNodes)


                obj.DataTreeMetricCheckedNodes=[];
                for i=1:length(checkedNodes)
                    dbIndex=checkedNodes(i).NodeData{1};
                    simName=checkedNodes(i).NodeData{2};
                    metricName=checkedNodes(i).Text;
                    treeNode=obj.getMetricTreeNode(dbIndex,simName,metricName);
                    if~isempty(treeNode)
                        if isempty(obj.DataTreeMetricCheckedNodes)

                            obj.DataTreeMetricCheckedNodes=treeNode;
                        else

                            obj.DataTreeMetricCheckedNodes(end+1)=treeNode;
                        end
                    end
                end
            end
        end
        function treeNode=getMetricTreeNode(obj,dbIndex,simName,metricName)



            treeNode=[];
            if~isempty(obj.DataTree)&&length(obj.DataTree.Children)>=dbIndex
                dbRootNode=obj.DataTree.Children(dbIndex);
                for i=1:length(dbRootNode.Children)
                    temp=dbRootNode.Children(i);
                    if obj.isMatchedMetricTreeNode(temp,dbIndex,simName,metricName)
                        treeNode=temp;
                        return;
                    end
                    for j=1:length(dbRootNode.Children(i).Children)
                        temp=dbRootNode.Children(i).Children(j);
                        if obj.isMatchedMetricTreeNode(temp,dbIndex,simName,metricName)
                            treeNode=temp;
                            return;
                        end
                        for k=1:length(dbRootNode.Children(i).Children(j).Children)
                            temp=dbRootNode.Children(i).Children(j).Children(k);
                            if obj.isMatchedMetricTreeNode(temp,dbIndex,simName,metricName)
                                treeNode=temp;
                                return;
                            end
                            for m=1:length(dbRootNode.Children(i).Children(j).Children(k).Children)
                                temp=dbRootNode.Children(i).Children(j).Children(k).Children(m);
                                if obj.isMatchedMetricTreeNode(temp,dbIndex,simName,metricName)
                                    treeNode=temp;
                                    return;
                                end
                            end
                        end
                    end
                end
            end
        end
        function matched=isMatchedMetricTreeNode(obj,treeNode,dbIndex,simName,metricName)


            matched=~isempty(treeNode)&&...
            length(treeNode.NodeData)>=4&&...
            treeNode.NodeData{1}==dbIndex&&...
            strcmp(treeNode.NodeData{2},simName)&&...
            strcmp(treeNode.Text,metricName);
        end


        function[mergedTable,metricsPanel,metricFilterTree,metricFilterRoot,tablesListBox,...
            plotList,xAxisList,legendList]=getTrendChartWidgets(obj)
            mergedTable=obj.PlotOptionsPanels{1}.Children.Children(2);
            metricsPanel=obj.PlotOptionsPanels{2};
            metricFilterTree=obj.getTaggedChildItem(metricsPanel,'metricFilterTree');
            metricFilterRoot=obj.getTaggedChildItem(metricsPanel,'metricFilterRoot');
            tablesListBox=obj.getTaggedChildItem(metricsPanel,'tablesListBox');
            plotList=obj.getTaggedChildItem(metricsPanel,'plotList');
            xAxisList=obj.getTaggedChildItem(metricsPanel,'xAxisList');
            legendList=obj.getTaggedChildItem(metricsPanel,'legendList');
        end


        function item=getTaggedChildItem(obj,parentObject,tag)




            if~isempty(parentObject)&&~isempty(tag)
                item=parentObject;
                if strcmpi(item.Tag,tag)
                    return;
                end
                if isprop(item,'Children')
                    for i=1:length(parentObject.Children)
                        item=parentObject.Children(i);
                        if strcmpi(item.Tag,tag)
                            return;
                        end
                        if isprop(item,'Children')
                            for j=1:length(parentObject.Children(i).Children)
                                item=parentObject.Children(i).Children(j);
                                if strcmpi(item.Tag,tag)
                                    return;
                                end
                                if isprop(item,'Children')
                                    for k=1:length(parentObject.Children(i).Children(j).Children)
                                        item=parentObject.Children(i).Children(j).Children(k);
                                        if strcmpi(item.Tag,tag)
                                            return;
                                        end
                                        if isprop(item,'Children')
                                            for m=1:length(parentObject.Children(i).Children(j).Children(k).Children)
                                                item=parentObject.Children(i).Children(j).Children(k).Children(m);
                                                if strcmpi(item.Tag,tag)
                                                    return;
                                                end
                                                if isprop(item,'Children')
                                                    for n=1:length(parentObject.Children(i).Children(j).Children(k).Children(m).Children)
                                                        item=parentObject.Children(i).Children(j).Children(k).Children(m).Children(n);
                                                        if strcmpi(item.Tag,tag)
                                                            return;
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            item=[];
        end
    end

    methods(Hidden)

        function moveSelectedParamBetweenLists(obj,src,event)
            [~,~,selected]=obj.getItemsAndSelectedItemWithinFirstList(src);
            if~isempty(selected)
                [~,~,~,~,~,~,xAxisList,~]=obj.getTrendChartWidgets();
                oldxAxisList=xAxisList.Items;

                obj.removeSelectedItemWithinFirstList(src);
                obj.addItemsToTargetList(src,{selected});




                if(strcmpi(src.Tag,'imagePlot2Xaxis')||strcmpi(src.Tag,'imageLegend2Xaxis')||...
                    strcmpi(src.Tag,'imageXaxis2Plot')||strcmpi(src.Tag,'imageXaxis2Legend'))&&...
                    obj.isChangedxAxisFromCsvOrXlxs(src.UserData{1}.UserData,oldxAxisList,xAxisList.Items)
                    obj.updateTrendPlotTableAndControlsWrapper(src.UserData{1}.UserData,xAxisList.Items);
                end

                obj.refreshTrendChart(src);
            end
        end


        function moveSelectedParamUpInList(obj,src,event)
            [index,items,selected]=obj.getItemsAndSelectedItemWithinFirstList(src);
            if~isempty(selected)&&~isempty(items)&&~strcmp(selected,items(1))
                for i=length(items):-1:2
                    if strcmp(selected,items{i})

                        items{i}=items{i-1};
                        items{i-1}=selected;
                        src.UserData{index}.Items=items;
                        if strcmp(src.Tag,'imageXaxisMoveUp')
                            obj.refreshTrendChart(src);
                        end
                        return;
                    end
                end
            end
        end
        function moveSelectedParamDownInList(obj,src,event)
            [index,items,selected]=obj.getItemsAndSelectedItemWithinFirstList(src);
            if~isempty(selected)&&~isempty(items)&&~strcmp(selected,items(end))
                for i=1:length(items)-1
                    if strcmp(selected,items{i})

                        items{i}=items{i+1};
                        items{i+1}=selected;
                        src.UserData{index}.Items=items;
                        if strcmp(src.Tag,'imageXaxisMoveDown')
                            obj.refreshTrendChart(src);
                        end
                        return;
                    end
                end
            end
        end


        function addParamToList(obj,src,event)
            if obj.isDataForMovingItemsBetweenTreeAndLists(src)&&~isempty(src.UserData{2}.SelectedNodes)
                [~,~,~,~,~,~,xAxisList,~]=obj.getTrendChartWidgets();
                oldxAxisList=xAxisList.Items;

                selectedItems=[];
                for i=1:length(src.UserData{1}.ColumnName)
                    for j=1:length(src.UserData{2}.SelectedNodes)
                        if strcmp(src.UserData{1}.ColumnName{i},src.UserData{2}.SelectedNodes(1).Text)
                            selectedItems{end+1}=src.UserData{1}.ColumnName{i};%#ok<AGROW> Add parameter name to cell array of selected items.
                        end
                    end
                end
                if~isempty(selectedItems)&&...
                    obj.addItemsToTargetList(src,selectedItems)

                    for i=4:5
                        obj.removeItemsFromTargetList(src.UserData{i},selectedItems);
                    end


                    metricsPanel=obj.PlotOptionsPanels{2};
                    metricFilterTree=obj.getTaggedChildItem(metricsPanel,'metricFilterTree');
                    for i=1:length(metricFilterTree.Children.Children)
                        if strcmp(metricFilterTree.Children.Children(i).Text,selectedItems{1})
                            if isempty(metricFilterTree.CheckedNodes)
                                metricFilterTree.CheckedNodes=metricFilterTree.Children.Children(i);
                            else
                                metricFilterTree.CheckedNodes(end+1)=metricFilterTree.Children.Children(i);
                            end
                            break;
                        end
                    end


                    if strcmpi(src.Tag,'imageParams2Xaxis')&&...
                        obj.isChangedxAxisFromCsvOrXlxs(src.UserData{1}.UserData,oldxAxisList,xAxisList.Items)
                        obj.updateTrendPlotTableAndControlsWrapper(src.UserData{1}.UserData,xAxisList.Items);
                    end


                    obj.refreshTrendChart(src);
                end
            end
        end
        function removeParamInList(obj,src,event)
            [~,~,~,~,~,~,xAxisList,~]=obj.getTrendChartWidgets();
            oldxAxisList=xAxisList.Items;

            [~,~,selected]=obj.getItemsAndSelectedItemWithinFirstList(src);
            if obj.removeSelectedItemWithinFirstList(src)


                metricsPanel=obj.PlotOptionsPanels{2};
                metricFilterTree=obj.getTaggedChildItem(metricsPanel,'metricFilterTree');
                checkedNodes=[];
                for i=1:length(metricFilterTree.CheckedNodes)
                    if~strcmp(metricFilterTree.CheckedNodes(i).Text,selected)&&...
                        ~strcmp(metricFilterTree.CheckedNodes(i).Tag,'metricFilterRoot')
                        if isempty(checkedNodes)
                            checkedNodes=metricFilterTree.CheckedNodes(i);
                        else
                            checkedNodes(end+1)=metricFilterTree.CheckedNodes(i);%#ok<AGROW>
                        end
                    end
                end
                metricFilterTree.CheckedNodes=checkedNodes;


                if strcmpi(src.Tag,'imageXaxis2Params')&&...
                    obj.isChangedxAxisFromCsvOrXlxs(src.UserData{1}.UserData,oldxAxisList,xAxisList.Items)
                    obj.updateTrendPlotTableAndControlsWrapper(src.UserData{1}.UserData,xAxisList.Items);
                end


                obj.refreshTrendChart(src);
            end
        end


        function added=addItemsToTargetList(obj,src,items)
            added=false;
            if iscell(items)&&~isempty(items)
                index=obj.getIndexOfFirstListInUserData(src);
                if index>0
                    if obj.isDataForMovingItemsBetweenLists(src)
                        index=index+1;
                    end
                    for i=1:length(items)
                        if isempty(src.UserData{index}.Items)||isempty(src.UserData{index}.Items{1})
                            src.UserData{3}.Items{1}=items{i};
                        elseif~any(contains(src.UserData{3}.Items,items{i}))
                            src.UserData{3}.Items{end+1}=items{i};
                        end
                    end
                    added=true;
                end
            end
        end


        function removed=removeItemsFromTargetList(obj,listBox,itemsToDelete)
            removed=false;
            if isa(listBox,'matlab.ui.control.ListBox')&&~isempty(listBox.Items)&&...
                iscell(itemsToDelete)&&~isempty(itemsToDelete)
                items=listBox.Items;
                for i=1:length(items)
                    for j=1:length(itemsToDelete)
                        if strcmp(items{i},itemsToDelete{j})
                            items{i}=[];
                            removed=true;
                        end
                    end
                end
                if removed
                    items=items(~cellfun('isempty',items));
                    listBox.Items=items;
                    return;
                end
            end
            removed=false;
        end


        function removed=removeSelectedItemWithinFirstList(obj,src)
            removed=false;
            [index,~,selected]=obj.getItemsAndSelectedItemWithinFirstList(src);
            if~isempty(selected)
                removed=obj.removeItemsFromTargetList(src.UserData{index},{selected});
            end
        end


        function[index,items,selected]=getItemsAndSelectedItemWithinFirstList(obj,src)
            index=obj.getIndexOfFirstListInUserData(src);
            if index>0
                items=src.UserData{index}.Items;
                selected=src.UserData{index}.Value;
            else
                items=[];
                selected=[];
            end
        end


        function index=getIndexOfFirstListInUserData(obj,src)
            if obj.isDataForMovingItemsBetweenLists(src)
                index=2;
            elseif obj.isDataForReorderingItemsWithinList(src)
                index=2;
            elseif obj.isDataForMovingItemsBetweenTreeAndLists(src)
                index=3;
            else
                index=NaN;
            end
        end


        function isOK=isDataForMovingItemsBetweenLists(obj,src)
            isOK=isa(src,'matlab.ui.control.Image')&&...
            iscell(src.UserData)&&length(src.UserData)==3&&...
            isa(src.UserData{1},'matlab.ui.control.Table')&&...
            isa(src.UserData{2},'matlab.ui.control.ListBox')&&...
            isa(src.UserData{3},'matlab.ui.control.ListBox');
        end
        function isOK=isDataForReorderingItemsWithinList(obj,src)
            isOK=isa(src,'matlab.ui.control.Image')&&...
            iscell(src.UserData)&&length(src.UserData)==2&&...
            isa(src.UserData{1},'matlab.ui.control.Table')&&...
            isa(src.UserData{2},'matlab.ui.control.ListBox');
        end
        function isOK=isDataForMovingItemsBetweenTreeAndLists(obj,src)
            isOK=isa(src,'matlab.ui.control.Image')&&...
            iscell(src.UserData)&&length(src.UserData)==5&&...
            isa(src.UserData{1},'matlab.ui.control.Table')&&...
            isa(src.UserData{2},'matlab.ui.container.CheckBoxTree')&&...
            isa(src.UserData{3},'matlab.ui.control.ListBox')&&...
            isa(src.UserData{4},'matlab.ui.control.ListBox')&&...
            isa(src.UserData{5},'matlab.ui.control.ListBox');
        end


        function refreshTrendChart(obj,src)
            if~isempty(src)
                metricsPanel=obj.PlotOptionsPanels{2};
                if~isempty(metricsPanel)&&~isempty(metricsPanel.UserData{5})
                    oldLineHandles=metricsPanel.UserData{5};

                    obj.MixedSignalAnalyzerTool.Controller.showTrendChart();

                    for i=1:length(oldLineHandles)
                        if~ischar(oldLineHandles(i))&&isvalid(oldLineHandles(i))
                            delete(oldLineHandles(i));
                        end
                    end
                end
            end
        end

    end

    methods(Static)
        function setXAxisLabels(figAxes,xAxisLabelsString)



            figAxes.OuterPosition=[0,0,1,1];
            drawnow;
            [xt,yt]=msblks.internal.apps.mixedsignalanalyzer.getTickLabelRowCoordinates(figAxes);


            xAxisLabels=gobjects(1,numel(xt));
            for i=1:numel(xt)
                xAxisLabels(i)=text(figAxes,xt(i),yt(i),xAxisLabelsString{i},...
                'FontSize',figAxes.XAxis.FontSize,...
                'VerticalAlignment','middle',...
                'HorizontalAlignment','left');
            end


            maxLabelsWidthNormalized=0;
            for i=1:numel(xt)
                xAxisLabels(i).Units='normalized';
                if xAxisLabels(i).Extent(3)>maxLabelsWidthNormalized
                    maxLabelsWidthNormalized=xAxisLabels(i).Extent(3);
                end
            end


            rightBorderWidthNormalized=figAxes.OuterPosition(1)+figAxes.OuterPosition(3)...
            -figAxes.InnerPosition(1)-figAxes.InnerPosition(3);
            figAxes.InnerPosition(3)=figAxes.InnerPosition(3)+rightBorderWidthNormalized-maxLabelsWidthNormalized;


            for i=1:numel(xt)
                xAxisLabels(i).Units='pixels';
                xAxisLabels(i).Position(1)=xAxisLabels(i).Position(1)+5;
            end




            figAxes.UserData={xAxisLabels,xAxisLabelsString};
        end
    end

end


function waveformName=packWaveformName(simName,simType,nodeName,simCorner)
    waveformName=msblks.internal.mixedsignalanalysis.SimulationResults.packWaveformName(simName,simType,nodeName,simCorner);
end
function[simName,simType,nodeName,simCorner]=unpackWaveformName(waveformName)
    [simName,simType,nodeName,simCorner]=msblks.internal.mixedsignalanalysis.SimulationResults.unpackWaveformName(waveformName);
end


function rowCount=getRowCount(matrixOrVectorOrScalar)
    if ismatrix(matrixOrVectorOrScalar)
        rowCount=size(matrixOrVectorOrScalar,1);
    elseif isvector(matrixOrVectorOrScalar)
        rowCount=1;
    else
        rowCount=0;
    end
end
function drawAndPause(timeInSeconds)
    drawnow;
    pause(timeInSeconds);
end
