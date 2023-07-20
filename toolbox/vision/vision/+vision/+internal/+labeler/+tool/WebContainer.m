classdef WebContainer<vision.internal.labeler.tool.Container




    properties(Access=private)

        CanClose(1,1)logical=true;


        ROILabelPanel matlab.ui.internal.FigurePanel
        FrameLabelPanel matlab.ui.internal.FigurePanel
        OverviewPanel matlab.ui.internal.FigurePanel


        SignalNavPanel matlab.ui.internal.FigurePanel


        InstructionPanel matlab.ui.internal.FigurePanel
        AttribSublabelPanel matlab.ui.internal.FigurePanel
        MetadataPanel matlab.ui.internal.FigurePanel

        NoneSignalDocument matlab.ui.internal.FigureDocument

DocGroupTag

    end


    properties(Access=protected)
StatusBar
StatusLabel

    end

    methods



        function this=WebContainer(title,name)

            this@vision.internal.labeler.tool.Container(title,name);
            this.SignalsMap=containers.Map;
        end

        function tmpWaitFor(this)
            waitfor(this.App,'State',...
            matlab.ui.container.internal.appcontainer.AppState.RUNNING);
        end

        function fig=getSignalFigureByName(this,figName)
            assert(isKey(this.SignalsMap,figName))
            val=this.SignalsMap(figName);
            fig=val{2};
        end

        function removeClientTabGroup(this,hFig,figName)

            removeDocumentTab(this,hFig,figName);
        end

        function removeDocumentTab(this,~,figName)
            if isKey(this.SignalsMap,figName)
                val=this.SignalsMap(figName);
                fig=val{2};
                figDoc=val{3};
                if~isempty(figDoc)
                    setPhantom(figDoc,'Phantom',true);
                    delete(fig);
                    delete(figDoc);
                    remove(this.SignalsMap,figName);
                end


            end
        end

        function addContainerListeners(this)
            this.App.CanCloseFcn=@(~,~)canTheAppClose(this);
        end



        function addTabs(this,tabs)

            addTabGroup(this.App,tabs);

        end

        function tab=getSelectedTab(this)
            tab=this.App.SelectedTab;

        end




        function loc=getLocation(this)

            loc=imageslib.internal.app.utilities.ScreenUtilities.getToolCenter(this.App);
        end




        function clear(this)
            clearTitleBarName(this);
            clearQuickAccessBar(this);
        end




        function wait(this)
            this.App.Busy=true;
        end




        function resume(this)
            this.App.Busy=false;
        end


        function enableQABUndo(this,TF)


            this.UndoButton.Enabled=TF;
        end


        function enableQABRedo(this,TF)


            this.RedoButton.Enabled=TF;
        end




        function enableQuickAccessBar(this)

            this.UndoListener.Enabled=true;
            this.RedoListener.Enabled=true;

        end




        function disableQuickAccessBar(this)

            this.UndoListener.Enabled=false;
            this.RedoListener.Enabled=false;

        end




        function clearQuickAccessBar(this)

            enableUndo(this,false);
            enableRedo(this,false);

        end




        function enableUndo(this,TF)
            this.UndoButton.Enabled=TF;
        end




        function enableRedo(this,TF)
            this.RedoButton.Enabled=TF;
        end




        function enableCut(~,~)

        end




        function enableCopy(~,~)

        end




        function enablePaste(~,~)

        end




        function approveClose(this)

            this.CanClose=true;

        end




        function vetoClose(this)

            this.CanClose=false;

        end




        function showLabels(this,TF)

            this.LabelDocument.Phantom=~TF;

            if TF
                this.LabelVisible=true;
            else
                this.LabelVisible=false;
            end

            updateAppLayout(this);

        end




        function showVolume(this,TF)

            if~this.VolumeSupported
                return;
            end

            this.VolumeDocument.Phantom=~TF;

            if TF
                this.VolumeVisible=true;
            else
                this.VolumeVisible=false;
            end

            updateAppLayout(this);

        end




        function close(this)
            cleanUpBeforeClosing(this);
            if isprop(this,'App')

                delete(this.App);
            end
        end


        function name=getGroupName(this)
            name=this.App.Tag;
        end


        function setStatusText(this,text)
            this.StatusLabel.Text=text;
        end


        function makeVisibleAtPos(this)

            this.App.Visible=true;

            [x,y,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition();
            this.App.WindowBounds=[x,y,width,height];
        end

        function setTabName(this,displayClassName,name)
        end


        function hideTabXCloseButton(this,displayClassName)
        end


        function showTearOffDialog(this,tearOff,invoker)
        end

        function makeSignalVisible(this,display)
            assert(isKey(this.SignalsMap,display.Name));

            val=this.SignalsMap(display.Name);
            figDoc=val{3};
            if~isempty(figDoc)
                setPhantom(figDoc,'Phantom',false);
            end
        end

        function makeSignalInvisible(this,display)
            assert(isKey(this.SignalsMap,display.Name));

            val=this.SignalsMap(display.Name);




            figDoc=val{3};
            if~isempty(figDoc)
                setPhantom(figDoc,'Phantom',true);
            end
        end

        function addNewSignalFigure(this,title)
            assert(isempty(this.SignalsMap)||(~isKey(this.SignalsMap,title)));

            figDoc=createAndAddDocument(this,title);
            fig=setDocFigure(this,title,figDoc);
            id=length(this.SignalsMap)+1;
            this.SignalsMap(title)={id,fig,figDoc};
        end


        function addFigures(this,addOverviewFigure,addMetadataFigure)

            group=matlab.ui.internal.FigureDocumentGroup();
            group.Title="Figures";
            this.App.add(group);
            this.DocGroupTag=group.Tag;




            title='ROI Labels';
            this.ROILabelPanel=createAndAddPanel(this,title,"left",true);
            this.ROILabelFigure=setDocFigure(this,title,this.ROILabelPanel);


            title='Scene Labels';
            this.FrameLabelPanel=createAndAddPanel(this,title,"left",true);
            this.FrameLabelFigure=setDocFigure(this,title,this.FrameLabelPanel);


            title='Signal Navigation';
            this.SignalNavPanel=createAndAddPanel(this,title,"bottom",false);
            this.SignalNavFigure=setDocFigure(this,title,this.SignalNavPanel);


            title='Instructions';
            this.InstructionPanel=createAndAddPanel(this,title,"right",false);
            this.InstructionFigure=setDocFigure(this,title,this.InstructionPanel);


            title='Attrib Sublabel';
            this.AttribSublabelPanel=createAndAddPanel(this,title,"right",false);
            this.AttribSublabelFigure=setDocFigure(this,title,this.AttribSublabelPanel);


            title='Signal';
            this.NoneSignalDocument=createAndAddDocument(this,title);
            this.NoneSignalFigure=setDocFigure(this,title,this.NoneSignalDocument);


            if addOverviewFigure
                title='Overview';
                this.OverviewPanel=createAndAddPanel(this,title,"left",true);
                this.OverviewFigure=setDocFigure(this,title,this.OverviewPanel);
            end


            if addMetadataFigure
                title='Metadata';
                this.MetadataPanel=createAndAddPanel(this,title,"right",false);
                this.MetadataFigure=setDocFigure(this,title,this.MetadataPanel);
            end

        end



        function makeDefaultFiguresVisible(this,showNavControlTab)
            if~showNavControlTab
                setPhantom(this.NoneSignalDocument,'Phantom',false);
            end

            drawnow()
        end


        function makeUnusedFiguresInvisible(this,showInstructionTab,...
            showAttributeTab,showNavControlTab,showMetadataTab)



            if~showInstructionTab
                set(this.InstructionFigure,'Visible','off');
                set(this.InstructionPanel,'Opened',false);
            end

            if~showAttributeTab
                set(this.AttribSublabelFigure,'Visible','off');
                set(this.AttribSublabelPanel,'Opened',false);
            end

            if~showNavControlTab
                set(this.SignalNavFigure,'Visible','off');
                set(this.SignalNavPanel,'Opened',false);
            end

            if~showMetadataTab
                if isvalid(this.MetadataFigure)
                    set(this.MetadataFigure,'Visible','off');
                    set(this.MetadataPanel,'Opened',false);
                end
            end

            drawnow()
        end


        function adjustFigurePanelWidth(this)
            this.App.LeftWidth=this.App.LeftWidth+1;
        end

        function makeNonDisplayInvisible(this)
            setPhantom(this.NoneSignalDocument,'Phantom',true);
        end

        function makeSignalNavVisible(this)
            set(this.SignalNavFigure,'Visible','on');
            set(this.SignalNavPanel,'Opened',true);
        end

        function makeSignalNavInvisible(this)
            set(this.SignalNavFigure,'Visible','off');
            set(this.SignalNavPanel,'Opened',false);
        end

        function makeAttribSublabelVisible(this)
            set(this.AttribSublabelFigure,'Visible','on');
            set(this.AttribSublabelPanel,'Opened',true);
        end

        function makeAttribSublabelInvisible(this)
            set(this.AttribSublabelFigure,'Visible','off');
            set(this.AttribSublabelPanel,'Opened',false);
        end

        function makeInstructionVisible(this)
            set(this.InstructionFigure,'Visible','on');
            set(this.InstructionPanel,'Opened',true);
        end

        function makeInstructionInvisible(this)
            set(this.InstructionFigure,'Visible','off');
            set(this.InstructionPanel,'Opened',false);
        end

        function makeOverviewVisible(this)
            set(this.OverviewFigure,'Visible','on');
            set(this.OverviewPanel,'Opened',true);
        end

        function makeOverviewInvisible(this)
            set(this.OverviewFigure,'Visible','off');
            set(this.OverviewPanel,'Opened',false);
        end

        function makeMetadataVisible(this)
            set(this.MetadataFigure,'Visible','on');
            set(this.MetadataPanel,'Opened',true);
        end

        function makeMetadataInvisible(this)
            set(this.MetadataFigure,'Visible','off');
            set(this.MetadataPanel,'Opened',false);
        end


        function str=getTitleBar(this)
            str=char(this.App.Title);
        end


        function setTitleBar(this,str)
            this.App.Title=str;
        end

        function removeInstructionsPanelWC(this)
            this.InstructionPanel.Opened=false;
        end

        function setClosingApprovalNeeded(this,~)


        end




        function delete(this)

        end

    end

    methods
        function setAppLayoutFromFileName(this,jsonFileName)

        end

        function resetAppFigDocLayout(this,numRows,numCols)
            hasVisualSummary=false;
            createXMLandGenerateLayout(this,numRows,numCols,hasVisualSummary);
        end


        function xmlString=createXMLandGenerateLayout(this,displayGridNumRows,...
            displayGridNumCols,hasVisualSummary)
            xmlString=[];

            curDims=this.App.DocumentGridDimensions;
            curNumRows=curDims(1);
            curNumCols=curDims(2);


            if(curNumRows==displayGridNumRows)&&(curNumCols==displayGridNumCols)
                return;
            else



                this.App.DocumentGridDimensions=[displayGridNumRows,displayGridNumCols];



            end
        end


        function out=getTilingLayout(this)


            out.DocumentGridDimensions=this.App.DocumentGridDimensions;
            out.LayoutJSON=this.App.LayoutJSON;
        end

        function tf=isNoneSignalDocVisible(this)
            tf=(~this.NoneSignalDocument.Phantom);
        end

        function showNoneSignalDisplay(this)
            setPhantom(this.NoneSignalDocument,'Phantom',false);
            set(this.NoneSignalFigure,'Visible','on');
        end


        function tf=hasLayoutAttributePanel(this,~)
            tf=this.AttribSublabelPanel.Opened;
        end


        function tf=hasLayoutSignalNavPanel(this,~)
            tf=this.SignalNavPanel.Opened;
        end


        function setAppLayout(this,layoutInfo)
            this.App.DocumentGridDimensions=layoutInfo.DocumentGridDimensions;
            this.App.LayoutJSON=layoutInfo.LayoutJSON;
            drawnow();
            hideSignalNavTabBarIfAny(this);
        end


        function hideSignalNavTabBarIfAny(this)

        end

        function restoreDocFigureLayout(this,varargin)

            if nargin==1
                return;
            end

            assert(nargin>1)

            curDims=this.App.DocumentGridDimensions;
            curNumRows=curDims(1);
            curNumCols=curDims(2);

            displayGridNumRows=varargin{1}(1);
            displayGridNumCols=varargin{1}(2);

            if(curNumRows==displayGridNumRows)&&(curNumCols==displayGridNumCols)
                return;
            else



                this.App.DocumentGridDimensions=[displayGridNumRows,displayGridNumCols];



            end
        end

        function tf=hasOneSignalDoc(this)
            tf=length(this.SignalsMap)==1;
        end

        function serializeLayoutToFile(~,layoutStr,fullFileName)
            jsonStr=jsonencode(layoutStr);





...
...
...
...
...
...
...
            fileID=fopen(fullFileName,'w');
            if fileID==-1,error('Cannot create JSON file');end

            fwrite(fileID,jsonStr,'char');

            fclose(fileID);

        end


        function layoutStr=deserializeLayoutFromFile(~,fullFileName)
            layoutStr=jsondecode(fileread(fullFileName{:}));
        end


        function xmlLayout=serializeLayout(~,layout)
            xmlLayout=jsonencode(layout);
        end


        function layout=deserializeLayout(~,xmlLayout)
            layout=jsondecode(xmlLayout);
        end


        function[numRows,numCols]=getGridLayout(this)



            numRows=this.App.DocumentGridDimensions(1);
            numCols=this.App.DocumentGridDimensions(2);
        end
    end

    methods(Access=protected)


        function TF=canTheAppClose(this)

            notify(this,'AppClosed');
            if(1)
                TF=this.CanClose;

                if TF
                    cleanUpBeforeClosing(this);
                end
            else
                TF=true;
                if isvalid(this)
                    TF=this.CanClose;

                    if TF
                        cleanUpBeforeClosing(this);
                    end
                end
            end

        end


        function cleanUpBeforeClosing(this)

        end


        function layout=getLayout(~)
            layout=[];
        end


        function s=getDefaultLayout(this,appWidth,appHeight)



            roiLabelsPanelId='WorkingArea_ROI Labels';
            sceneLabelsPanelId='WorkingArea_Scene Labels';
            signalLabelsPanelId='WorkingArea_Signal';

            s=struct;
            s.majorVersion=2;
            s.minorVersion=1;
            s.panelLayout=struct('referenceWidth',appWidth,'referenceHeight',appHeight,'centerExpanded',false,'centerCollapsed',false);
            s.toolstripCollapsed=false;
            s.documentLayout.referenceWidth=appWidth;
            s.documentLayout.referenceHeight=appHeight;



            s.panelLayout.left.portion=0.2;
            s.panelLayout.left.children=[struct('id',roiLabelsPanelId);...
            struct('id',sceneLabelsPanelId)];

            s.documentLayout.gridDimensions=struct('w',1,'h',1);
            s.documentLayout.tileCount=1;
            s.documentLayout.tileCoverage=1;

            s.documentLayout.columnWeights=[1];
            s.documentLayout.rowWeights=[1];

            s.documentLayout.tileOccupancy=struct('children',struct('showOrder',0,'id',signalLabelsPanelId),...
            'showingChildId',signalLabelsPanelId);
            s.documentLayout.emptyTileCount=0;


        end


        function setLayoutToFile(~,~,~)

        end


        function layout=getLayoutFromFile(~,~)

            layout=[];
        end


        function openApp(this)

            this.App.CanCloseFcn=@(~,~)canTheAppClose(this);

            addFigures(this);




        end


        function closeApp(this,~)

            notify(this,'AppClosed');
        end


        function TF=closeVolumeDocument(this)

            TF=this.CanClose;

            this.VolumeDocument.Phantom=true;
            this.VolumeVisible=false;

            updateAppLayout(this);

        end


        function TF=closeLabelDocument(this)

            TF=this.CanClose;

            this.LabelDocument.Phantom=true;
            this.LabelVisible=false;

            updateAppLayout(this);

        end


        function createApp(this,title,name)


            appOptions.Tag=name;
            appOptions.Title=title;
            [x,y,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition();
            appOptions.WindowBounds=[x,y,width,height];
            appOptions.DefaultLayout=getDefaultLayout(this,width,height);
            appOptions.Product="Computer Vision Toolbox";
            appOptions.Scope="Labelers";


            this.App=matlab.ui.container.internal.AppContainer(appOptions);

            wireUpQuickAccessBar(this);
            setUpStatusBar(this);
        end

        function wireUpQuickAccessBar(self)

            self.UndoButton=matlab.ui.internal.toolstrip.qab.QABUndoButton();
            self.UndoListener=addlistener(self.UndoButton,'ButtonPushed',@(~,~)notify(self,'UndoRequested'));

            self.RedoButton=matlab.ui.internal.toolstrip.qab.QABRedoButton();
            self.RedoListener=addlistener(self.RedoButton,'ButtonPushed',@(~,~)notify(self,'RedoRequested'));

            self.HelpButton=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            self.HelpListener=addlistener(self.HelpButton,'ButtonPushed',@(~,~)notify(self,'HelpRequested'));





            self.App.add(self.HelpButton);
            self.App.add(self.RedoButton);
            self.App.add(self.UndoButton);
        end


        function setUpStatusBar(this)

            statusBar=matlab.ui.internal.statusbar.StatusBar();
            statusBar.Tag='statusBar';

            statusLabel=matlab.ui.internal.statusbar.StatusLabel();
            statusLabel.Tag='statusLabel';
            statusBar.add(statusLabel);
            this.App.add(statusBar);
            this.StatusBar=statusBar;
            this.StatusLabel=statusLabel;
        end


        function removeFromLayout(~,~)

        end


        function figOrder=getFigureOrder(~)

            figOrder={'Labels','Slice','3-D Display'};

        end
    end

    methods(Access=private)

        function hDoc=createAndAddDocument(this,title)
            figOptions.Title=string(title);
            figOptions.DocumentGroupTag=this.DocGroupTag;
            figOptions.Closable=false;




            hDoc=matlab.ui.internal.FigureDocument(figOptions);
            this.App.add(hDoc);
        end

        function hPanel=createAndAddPanel(this,title,region,isVisible)
            figOptions.Title=string(title);
            figOptions.Region=region;

            figOptions.Tag=string(title);
            figOptions.Opened=isVisible;
            figOptions.Closable=false;

            hPanel=matlab.ui.internal.FigurePanel(figOptions);
            this.App.add(hPanel);
        end

        function hDocFig=setDocFigure(this,title,hDoc)
            hDocFig=hDoc.Figure;

            set(hDocFig,'NumberTitle','off',...
            'Name',char(title),...
            'IntegerHandle','off',...
            'HandleVisibility','callback',...
            'Visible','on',...
            'ToolBar','none',...
            'Color','white',...
            'AutoResizeChildren','off');



        end

        function emptySizeChangeFcn(this,fig)
            if isvalid(fig)
                set(fig,'SizeChangedFcn',[]);
            end
        end

    end

    methods(Hidden,Access=?visiontest.apps.labeler.appcontainer.AppContainerTester)

        function panel=getFrameLabelPanel(this)
            panel=this.FrameLabelPanel;
        end
    end
end

function str=formatJSONstring(str)

    str=strrep(str,',',sprintf(',\r'));
    str=strrep(str,'[{',sprintf('[\r{\r'));
    str=strrep(str,'}]',sprintf('\r}\r]'));
end

function setPhantom(figDoc,~,state)
    if figDoc.Phantom~=state
        set(figDoc,'Phantom',state);
    end
end
