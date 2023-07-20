







classdef LVAppContainer<handle




    properties
        SliderPanel matlab.ui.internal.FigurePanel
        SliderFigure matlab.ui.Figure

        DataBrowserPanel matlab.ui.internal.FigurePanel
        DataBrowserFigure matlab.ui.Figure

        AnalysisPanel matlab.ui.internal.FigurePanel
        AnalysisFigure matlab.ui.Figure

        EditPanel matlab.ui.internal.FigurePanel
        EditFigure matlab.ui.Figure

        HistoryPanel matlab.ui.internal.FigurePanel
        HistoryFigure matlab.ui.Figure

DataDocument
DataFigure

        UndoButton matlab.ui.internal.toolstrip.qab.QABUndoButton
        RedoButton matlab.ui.internal.toolstrip.qab.QABRedoButton

App
    end

    events


UndoRequest



RedoRequest


AppResized


AppClosed


EscPressed
    end

    properties
        DataIdInView=1

        IsEditMode=false

        CanClose=true
    end

    properties(Constant)
        DataDocumentGroupTag='DataDocGrp'
    end

    methods



        function this=LVAppContainer()
            createApp(this);
        end


        function addTabs(this,tabs)
            addTabGroup(this.App,tabs);
        end


        function wait(this)
            if this.App.Busy
                return;
            end
            this.App.Busy=true;
        end


        function resume(this)
            this.App.Busy=false;
        end


        function setUndoRedo(this,isUndoStackEmpty,isRedoStackEmpty)
            this.UndoButton.Enabled=~isUndoStackEmpty;
            this.RedoButton.Enabled=~isRedoStackEmpty;
        end
    end




    methods(Access=private)

        function s=getDefaultLayout(this)

            if this.IsEditMode

                layoutFileName='LVDefLayoutEditMode.json';
                toAdjust=true;
            else
                if this.DataIdInView>1

                    layoutFileName='LVDefLayoutSingleGrid.json';
                    toAdjust=true;
                else

                    layoutFileName='LVDefLayoutEmptyApp.json';
                    toAdjust=false;
                end
            end


            layoutJSON=fileread(fullfile(matlabroot,'toolbox',...
            'lidar','lidar','+lidar','+internal',...
            '+lidarViewer','+view',layoutFileName));

            s=jsondecode(layoutJSON);

            if toAdjust
                s=this.adjustLayout(s);
            end
        end


        function openApp(this)
            this.App.CanCloseFcn=@(~,~)canAppClose(this);

            this.App.Visible=true;
            waitfor(this.App,'State',...
            matlab.ui.container.internal.appcontainer.AppState.RUNNING);

            addAppComponents(this);

            addUndoRedoButtons(this);

            addKeyboardShortcut(this);

            addEscapeKeyboardShortcut(this);

            drawnow();
        end


        function createApp(this)

            appOptions.Tag='LV_'+matlab.lang.internal.uuid;
            appOptions.Title=getString(message('lidar:lidarViewer:AppName'));

            appOptions.DefaultLayout=getDefaultLayout(this);
            [x,y,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition();
            appOptions.WindowBounds=[x,y,width,height];
            appOptions.Product="Lidar Toolbox";
            appOptions.Scope="Lidar Viewer";
            this.App=matlab.ui.container.internal.AppContainer(appOptions);




        end


        function addUndoRedoButtons(this)

            this.UndoButton=matlab.ui.internal.toolstrip.qab.QABUndoButton();
            this.UndoButton.ButtonPushedFcn=@(~,~)this.undoRequest();

            this.RedoButton=matlab.ui.internal.toolstrip.qab.QABRedoButton();
            this.RedoButton.ButtonPushedFcn=@(~,~)this.redoRequest();

            this.App.add(this.UndoButton);
            this.App.add(this.RedoButton);

            this.setUndoRedo(true,true);
        end


        function addKeyboardShortcut(this)
            this.EditFigure.WindowKeyPressFcn=@(src,evt)reactToKeyboardShortcut(this,src,evt);
            this.HistoryFigure.WindowKeyPressFcn=@(src,evt)reactToKeyboardShortcut(this,src,evt);
        end


        function addEscapeKeyboardShortcut(this)
            this.SliderFigure.WindowKeyPressFcn=@(src,evt)reactToEscapeButtonShortcut(this,src,evt);
            this.DataBrowserFigure.WindowKeyPressFcn=@(src,evt)reactToEscapeButtonShortcut(this,src,evt);
            this.AnalysisFigure.WindowKeyPressFcn=@(src,evt)reactToEscapeButtonShortcut(this,src,evt);
            this.EditFigure.WindowKeyPressFcn=@(src,evt)reactToEscapeButtonShortcut(this,src,evt);
            this.HistoryFigure.WindowKeyPressFcn=@(src,evt)reactToEscapeButtonShortcut(this,src,evt);
        end


        function addAppComponents(this)




            [panel,panelFigure]=addPanelFigure(this,...
            getString(message('lidar:lidarViewer:DataBrowser')),'dataList','left',0.2,true);
            this.DataBrowserPanel=panel;
            this.DataBrowserFigure=panelFigure;


            [panel,panelFigure]=addPanelFigure(this,...
            getString(message('lidar:lidarViewer:PCInformation')),'analysis','left',0.2,true);
            this.AnalysisPanel=panel;
            this.AnalysisFigure=panelFigure;



            [panel,panelFigure]=addPanelFigure(this,...
            getString(message('lidar:lidarViewer:SliderPanel')),'slider','bottom',0.2,false);
            this.SliderPanel=panel;
            this.SliderFigure=panelFigure;


            [panel,panelFigure]=addPanelFigure(this,...
            getString(message('lidar:lidarViewer:EditPanel')),'editPanel','right',0.2,false);
            this.EditPanel=panel;
            this.addUIGridLayoutToEditPanel(panelFigure);
            this.EditFigure=panelFigure;


            [panel,panelFigure]=addPanelFigure(this,...
            getString(message('lidar:lidarViewer:HistoryPanel')),'historyPanel','right',0.2,false);
            this.HistoryPanel=panel;
            this.addUIGridLayoutToHistoryPanel(panelFigure);
            this.HistoryFigure=panelFigure;

            this.addDataDocumentGroup();


            this.addDocumentFigures(getString(message('lidar:lidarViewer:PCDisplay')));

            drawnow();
        end


        function reactToAppResize(this)
            drawnow();
            notify(this,'AppResized');
            focus(this.DataBrowserFigure);
        end


        function TF=canAppClose(this)
            notify(this,'AppClosed');
            TF=this.CanClose;


            this.CanClose=true;
        end


        function undoRequest(this)

            if~this.UndoButton.Enabled

                return;
            end
            notify(this,'UndoRequest');
        end


        function redoRequest(this)

            if~this.RedoButton.Enabled

                return;
            end
            notify(this,'RedoRequest');
        end


        function reactToKeyboardShortcut(this,~,evt)

            if~isempty(evt.Modifier)

                if strcmp(evt.Modifier{1},'control')
                    switch evt.Key
                    case 'z'

                        this.undoRequest();
                    case 'y'

                        this.redoRequest();
                    otherwise
                        return;
                    end
                end
            end
        end


        function reactToEscapeButtonShortcut(this,~,evt)


            if strcmp(evt.Key,'escape')
                notify(this,'EscPressed');
            end
        end
    end




    methods

        function open(this)

            openApp(this);

            drawnow();
        end


        function fig=addDocumentFigures(this,name)


            docOptions.Title=name;
            docOptions.DocumentGroupTag=this.DataDocumentGroupTag;

            doc=matlab.ui.internal.FigureDocument(docOptions);
            doc.Closable=false;
            doc.Figure.AutoResizeChildren='off';

            this.App.add(doc);
            drawnow();

            this.DataDocument{end+1}=doc;
            this.DataFigure{end+1}=doc.Figure;
            fig=doc.Figure;
            fig.Tag=name;
            fig.AutoResizeChildren='on';


            fig.WindowKeyPressFcn=@(src,evt)reactToKeyboardShortcut(this,src,evt);
            fig.WindowKeyPressFcn=@(src,evt)reactToEscapeButtonShortcut(this,src,evt);
        end


        function setSingleGridLayout(this)

            this.setPanelOpened(this.SliderPanel,true);
            this.setDefaultLayout();
            drawnow();
        end


        function setDefaultLayout(this)

            s=this.getDefaultLayout();

            if isempty(s)
                return;
            end

            this.App.Layout=s;
            figure(this.DataBrowserFigure);
            drawnow();
        end




        function changeToEditMode(this)

            this.setPanelOpened(this.DataBrowserPanel,false);
            this.setPanelOpened(this.AnalysisPanel,false);
            this.setPanelOpened(this.EditPanel,true);
            this.EditFigure.Scrollable='on';
            this.setPanelOpened(this.HistoryPanel,true);
            this.IsEditMode=true;
            this.setDefaultLayout();
            pause(1);
        end


        function revertFromEditMode(this)

            this.setPanelOpened(this.DataBrowserPanel,true);
            this.setPanelOpened(this.AnalysisPanel,true);


            this.EditFigure.Scrollable='off';
            drawnow();
            this.setPanelOpened(this.EditPanel,false);
            this.setPanelOpened(this.HistoryPanel,false);
            this.IsEditMode=false;
            this.setDefaultLayout();
            pause(1);
        end




        function toggleDataDocument(this,id)

            if id<=0||id>numel(this.DataFigure)
                return
            end

            this.setPhantom(this.DataDocument{this.DataIdInView},true);
            this.DataIdInView=id;
            this.setPhantom(this.DataDocument{this.DataIdInView},false);
        end




        function resetDataFigures(this)
            for id=numel(this.DataFigure):-1:2
                close(this.DataDocument{id});
                this.DataDocument(id)=[];
                this.DataFigure(id)=[];
            end
            this.DataIdInView=1;
            this.setPhantom(this.DataDocument{this.DataIdInView},false);
        end

        function resetThisView(this)
            id=numel(this.DataBrowserFigure);
            this.deleteDataFigure(id);
        end


        function deleteDataFigure(this,id)



            close(this.DataDocument{id});
            this.DataDocument(id)=[];
            this.DataFigure(id)=[];

            if this.DataIdInView>id


                this.DataIdInView=this.DataIdInView-1;
            elseif this.DataIdInView==id

                this.DataIdInView=numel(this.DataDocument);
                this.setPhantom(this.DataDocument{this.DataIdInView},false);
            end
        end


        function vetoAppClose(this)
            this.CanClose=false;
        end


        function TF=isVisible(this,id)
            TF=~this.DataDocument{id}.Phantom;
        end


        function fig=getVisibleDataFig(this)


            fig=this.DataBrowserFigure;
        end


        function numDisp=getNumOfVisibleDisplay(this)
            numDisp=0;
            for i=1:numel(this.DataDocument)
                if~this.DataDocument{i}.Phantom
                    numDisp=numDisp+1;
                end
            end
        end
    end




    methods(Access=private)

        function[panel,panelFig]=addPanelFigure(this,title,tag,region,...
            width,isVisible)



            panelOptions.Title=title;
            panelOptions.Tag=tag;
            panelOptions.Region=region;
            panelOptions.PreferredWidth=width;

            panel=matlab.ui.internal.FigurePanel(panelOptions);

            panel.Closable=false;
            panel.Maximizable=false;
            panel.Collapsible=false;
            panel.Opened=isVisible;

            this.App.add(panel);
            drawnow();

            panelFig=panel.Figure;
            panelFig.AutoResizeChildren='off';
            panelFig.SizeChangedFcn=@(~,~)reactToAppResize(this);
        end


        function addDataDocumentGroup(this)

            figDocGrp=matlab.ui.internal.FigureDocumentGroup();
            figDocGrp.Tag=this.DataDocumentGroupTag;
            figDocGrp.Maximizable=false;

            this.App.add(figDocGrp);
            drawnow();
        end


        function setPhantom(this,documentH,TF)

            if~isequal(documentH.Phantom,TF)
                documentH.Phantom=TF;
            end
        end


        function setPanelOpened(this,panelH,TF)

            if~isequal(panelH.Opened,TF)
                panelH.Opened=TF;
            end
            if TF
                pause(1);
            end
        end


        function s=adjustLayout(this,s)



            s.documentLayout.tileOccupancy.showingChildId=...
            char(this.DataDocument{this.DataIdInView}.Tag);
            s.documentLayout.tileOccupancy.children.id=...
            char(this.DataDocument{this.DataIdInView}.Tag);
        end


        function addUIGridLayoutToEditPanel(this,panelFigure)




            baseGrid=uigridlayout(panelFigure,[2,1]);
            baseGrid.RowHeight={'1x',125};
            baseGrid.Padding=[0,0,0,0];
            baseGrid.ColumnSpacing=0;
            baseGrid.RowSpacing=0;


            algoGrid=uigridlayout(baseGrid,'Tag','algorithmGrid');


            bottomGrid=uigridlayout(baseGrid,'Tag','bottomGrid');

            bottomGrid.ColumnWidth={'1x',5,'1x'};

            bottomGrid.RowHeight={25,25,25};


            panelFigure.UserData={algoGrid;bottomGrid};
        end

        function addUIGridLayoutToHistoryPanel(this,panelFigure)




            baseGrid=uigridlayout(panelFigure,[2,1]);
            baseGrid.RowHeight={'1x',75};
            baseGrid.Padding=[0,0,0,0];
            baseGrid.ColumnSpacing=0;
            baseGrid.RowSpacing=0;


            historyGrid=uigridlayout(baseGrid,'Tag','historyGrid');


            historyBottomGrid=uigridlayout(baseGrid,'Tag','historyBottomGrid');

            historyBottomGrid.ColumnWidth={'1x',5,'1x'};
            historyBottomGrid.RowHeight={'1x'};


            panelFigure.UserData={historyGrid;historyBottomGrid};
        end
    end
end