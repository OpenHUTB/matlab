classdef WebContainer<images.internal.app.segmenter.volume.display.Container




    properties(Access=protected)

        CanClose(1,1)logical=true;

VolumeDocument

OverviewDocument

SliceDocument

LabelDocument

        CloseListener event.listener

    end

    methods




        function self=WebContainer(show3DDisplay)

            self@images.internal.app.segmenter.volume.display.Container(show3DDisplay);

        end




        function addTabs(self,tabs)

            addTabGroup(self.App,tabs);

        end




        function loc=getLocation(self)

            loc=imageslib.internal.app.utilities.ScreenUtilities.getToolCenter(self.App);

        end




        function clear(self)
            clearTitleBarName(self);
            clearQuickAccessBar(self);
        end




        function set3DDisplayFigureName(self,str)

            self.VolumeDocument.Title=str;

        end




        function setColumnLayout(self)

            if~self.VolumeSupported
                setTwoColumnLayout(self);
                return;
            end

            makeAllFiguresVisible(self);

            s=self.App.Layout;

            if isempty(fieldnames(s))

                [~,~,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition();

                s.majorVersion=2;
                s.minorVersion=1;
                s.panelLayout=struct('referenceWidth',width,'referenceHeight',height,'centerExpanded',false,'centerCollapsed',false);
                s.toolstripCollapsed=false;
                s.documentLayout.referenceWidth=width;
                s.documentLayout.referenceHeight=height;
            end

            s.documentLayout.gridDimensions=struct('w',3,'h',1);
            s.documentLayout.tileCount=3;
            s.documentLayout.tileCoverage=[1,2,3];
            s.documentLayout.columnWeights=[0.2;0.5;0.3];
            s.documentLayout.rowWeights=1;
            s.documentLayout.rowTop=[0;s.documentLayout.referenceHeight];
            s.documentLayout.columnLeft=[0;round(s.documentLayout.referenceWidth*0.2);round(s.documentLayout.referenceWidth*0.7);s.documentLayout.referenceWidth];
            s.documentLayout.tileOccupancy=[struct('children',struct('showOrder',4,'id','defaultfigure_document1'),'showingChildId','defaultfigure_document1');...
            struct('children',struct('showOrder',4,'id','defaultfigure_document2'),'showingChildId','defaultfigure_document2');...
            struct('children',struct('showOrder',0,'id','defaultfigure_document3'),'showingChildId','defaultfigure_document3')];
            s.documentLayout.emptyTileCount=0;

            self.App.Layout=s;

            drawnow;

            notify(self,'AppResized');

        end




        function setStackedLayout(self)

            setTwoColumnLayout(self);

        end




        function wait(self)
            self.App.Busy=true;
        end




        function resume(self)
            self.App.Busy=false;
        end




        function enableQuickAccessBar(self)

            self.UndoListener.Enabled=true;
            self.RedoListener.Enabled=true;

        end




        function disableQuickAccessBar(self)

            self.UndoListener.Enabled=false;
            self.RedoListener.Enabled=false;

        end




        function clearQuickAccessBar(self)

            enableUndo(self,false);
            enableRedo(self,false);

        end




        function enableUndo(self,TF)
            self.UndoButton.Enabled=TF;
        end




        function enableRedo(self,TF)
            self.RedoButton.Enabled=TF;
        end




        function enableCut(~,~)

        end




        function enableCopy(~,~)

        end




        function enablePaste(~,~)

        end




        function approveClose(self)

            self.CanClose=true;

        end




        function vetoClose(self)

            self.CanClose=false;

        end




        function showLabels(self,TF)

            self.LabelDocument.Visible=TF;

            if TF
                self.LabelVisible=true;
            else
                self.LabelVisible=false;
            end

            updateAppLayout(self);

        end




        function showVolume(self,TF)

            if~self.VolumeSupported
                return;
            end

            self.VolumeDocument.Visible=TF;

            if TF
                self.VolumeVisible=true;
            else
                self.VolumeVisible=false;
            end

            updateAppLayout(self);

        end




        function showOverview(self,TF)

            if~self.VolumeSupported
                return;
            end

            if self.VolumeDocument.Visible
                self.OverviewDocument.Tile=self.VolumeDocument.Tile;
                self.OverviewDocument.Showing=true;
            else
                self.OverviewDocument.Showing=false;
            end

            self.OverviewDocument.Visible=TF;

            if TF
                self.OverviewVisible=true;
                set(self.OverviewDocument,'CanCloseFcn',@(~,~)closeOverviewDocument(self));
            else
                self.OverviewVisible=false;
            end

            updateAppLayout(self);

        end




        function close(self)
            cleanUpBeforeClosing(self);
            delete(self.App);
        end




        function bringToFront(self)





            if ispc||ismac
                bringToFront(self.App);
            end
        end

    end


    methods(Access=protected)


        function TF=canTheAppClose(self)

            notify(self,'AppClosed');

            TF=self.CanClose;

            if TF
                cleanUpBeforeClosing(self);
            end

        end


        function cleanUpBeforeClosing(self)

            if self.VolumeSupported
                set(self.VolumeDocument,'CanCloseFcn',@(~)closeDocument(self));
                set(self.VolumeFigure,'SizeChangedFcn',[]);
                set(self.OverviewDocument,'CanCloseFcn',@(~)closeDocument(self));
                set(self.OverviewFigure,'SizeChangedFcn',[]);
            end

            set(self.LabelDocument,'CanCloseFcn',@(~)closeDocument(self));
            set(self.LabelFigure,'SizeChangedFcn',[]);
            set(self.SliceFigure,'SizeChangedFcn',[]);

            self.CloseListener.Enabled=false;

        end

        function TF=closeDocument(~)
            TF=true;
        end


        function setTwoColumnLayout(self)

            s=self.App.Layout;

            if isempty(fieldnames(s))

                [~,~,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition();

                s.majorVersion=2;
                s.minorVersion=1;
                s.panelLayout=struct('referenceWidth',width,'referenceHeight',height,'centerExpanded',false,'centerCollapsed',false);
                s.toolstripCollapsed=false;
                s.documentLayout.referenceWidth=width;
                s.documentLayout.referenceHeight=height;
            end

            makeAllFiguresVisible(self);

            if self.VolumeSupported

                if self.OverviewVisible
                    s.documentLayout.gridDimensions=struct('w',2,'h',2);
                    s.documentLayout.tileCount=3;
                    s.documentLayout.tileCoverage=[1,2;3,2];
                    s.documentLayout.columnWeights=[0.3,0.7];
                    s.documentLayout.rowWeights=[0.5,0.5];
                    s.documentLayout.rowTop=[0;round(s.documentLayout.referenceHeight/2);s.documentLayout.referenceHeight];
                    s.documentLayout.columnLeft=[0;round(s.documentLayout.referenceWidth*0.3);s.documentLayout.referenceWidth];
                    s.documentLayout.tileOccupancy=[struct('children',struct('showOrder',0,'id','defaultfigure_document1'),'showingChildId','defaultfigure_document1');...
                    struct('children',struct('showOrder',0,'id','defaultfigure_document2'),'showingChildId','defaultfigure_document2');...
                    struct('children',struct('showOrder',7,'id','defaultfigure_document3'),'showingChildId','defaultfigure_document3');...
                    struct('children',struct('showOrder',7,'id','defaultfigure_document4'),'showingChildId','defaultfigure_document4')];
                    s.documentLayout.emptyTileCount=0;
                else
                    s.documentLayout.gridDimensions=struct('w',2,'h',2);
                    s.documentLayout.tileCount=3;
                    s.documentLayout.tileCoverage=[1,2;3,2];
                    s.documentLayout.columnWeights=[0.3,0.7];
                    s.documentLayout.rowWeights=[0.5,0.5];
                    s.documentLayout.rowTop=[0;round(s.documentLayout.referenceHeight/2);s.documentLayout.referenceHeight];
                    s.documentLayout.columnLeft=[0;round(s.documentLayout.referenceWidth*0.3);s.documentLayout.referenceWidth];
                    s.documentLayout.tileOccupancy=[struct('children',struct('showOrder',0,'id','defaultfigure_document1'),'showingChildId','defaultfigure_document1');...
                    struct('children',struct('showOrder',0,'id','defaultfigure_document2'),'showingChildId','defaultfigure_document2');...
                    struct('children',struct('showOrder',7,'id','defaultfigure_document3'),'showingChildId','defaultfigure_document3')];
                    s.documentLayout.emptyTileCount=0;
                end

            else

                s.documentLayout.gridDimensions=struct('w',2,'h',1);
                s.documentLayout.tileCount=2;
                s.documentLayout.tileCoverage=[1,2];
                s.documentLayout.columnWeights=[0.3,0.7];
                s.documentLayout.rowWeights=1;
                s.documentLayout.rowTop=[0;s.documentLayout.referenceHeight];
                s.documentLayout.columnLeft=[0;round(s.documentLayout.referenceWidth*0.3);s.documentLayout.referenceWidth];
                s.documentLayout.tileOccupancy=[struct('children',struct('showOrder',1,'id','defaultfigure_document1'),'showingChildId','defaultfigure_document1');...
                struct('children',struct('showOrder',1,'id','defaultfigure_document2'),'showingChildId','defaultfigure_document2')];
                s.documentLayout.emptyTileCount=0;

            end

            self.App.Layout=s;

            drawnow;

            notify(self,'AppResized');

        end


        function layout=getLayout(~)
            layout=[];
        end


        function setLayout(self,~)

            setStackedLayout(self);

        end


        function s=getDefaultLayout(self)

            [~,~,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition();

            s=struct;
            s.majorVersion=2;
            s.minorVersion=1;
            s.panelLayout=struct('referenceWidth',width,'referenceHeight',height,'centerExpanded',false,'centerCollapsed',false);
            s.toolstripCollapsed=false;
            s.documentLayout.referenceWidth=width;
            s.documentLayout.referenceHeight=height;

            if self.VolumeSupported

                if self.OverviewVisible

                    s.documentLayout.gridDimensions=struct('w',2,'h',2);
                    s.documentLayout.tileCount=3;
                    s.documentLayout.tileCoverage=[1,2;3,2];
                    s.documentLayout.columnWeights=[0.3,0.7];
                    s.documentLayout.rowWeights=[0.5,0.5];
                    s.documentLayout.rowTop=[0;round(s.documentLayout.referenceHeight/2);s.documentLayout.referenceHeight];
                    s.documentLayout.columnLeft=[0;round(s.documentLayout.referenceWidth*0.3);s.documentLayout.referenceWidth];
                    s.documentLayout.tileOccupancy=[struct('children',struct('showOrder',0,'id','defaultfigure_document1'),'showingChildId','defaultfigure_document1');...
                    struct('children',struct('showOrder',0,'id','defaultfigure_document2'),'showingChildId','defaultfigure_document2');...
                    struct('children',struct('showOrder',7,'id','defaultfigure_document3'),'showingChildId','defaultfigure_document3');...
                    struct('children',struct('showOrder',7,'id','defaultfigure_document4'),'showingChildId','defaultfigure_document4')];
                    s.documentLayout.emptyTileCount=0;

                else

                    s.documentLayout.gridDimensions=struct('w',2,'h',2);
                    s.documentLayout.tileCount=3;
                    s.documentLayout.tileCoverage=[1,2;3,2];
                    s.documentLayout.columnWeights=[0.3,0.7];
                    s.documentLayout.rowWeights=[0.5,0.5];
                    s.documentLayout.rowTop=[0;round(s.documentLayout.referenceHeight/2);s.documentLayout.referenceHeight];
                    s.documentLayout.columnLeft=[0;round(s.documentLayout.referenceWidth*0.3);s.documentLayout.referenceWidth];
                    s.documentLayout.tileOccupancy=[struct('children',struct('showOrder',0,'id','defaultfigure_document1'),'showingChildId','defaultfigure_document1');...
                    struct('children',struct('showOrder',0,'id','defaultfigure_document2'),'showingChildId','defaultfigure_document2');...
                    struct('children',struct('showOrder',7,'id','defaultfigure_document3'),'showingChildId','defaultfigure_document3')];
                    s.documentLayout.emptyTileCount=0;

                end

            else

                s.documentLayout.gridDimensions=struct('w',2,'h',1);
                s.documentLayout.tileCount=2;
                s.documentLayout.tileCoverage=[1,2];
                s.documentLayout.columnWeights=[0.3,0.7];
                s.documentLayout.rowWeights=1;
                s.documentLayout.rowTop=[0;s.documentLayout.referenceHeight];
                s.documentLayout.columnLeft=[0;round(s.documentLayout.referenceWidth*0.3);s.documentLayout.referenceWidth];
                s.documentLayout.tileOccupancy=[struct('children',struct('showOrder',1,'id','defaultfigure_document1'),'showingChildId','defaultfigure_document1');...
                struct('children',struct('showOrder',1,'id','defaultfigure_document2'),'showingChildId','defaultfigure_document2')];
                s.documentLayout.emptyTileCount=0;

            end

        end


        function setLayoutToFile(~,~,~)

        end


        function layout=getLayoutFromFile(~,~)

            layout=[];
        end


        function openApp(self)

            self.App.CanCloseFcn=@(~)canTheAppClose(self);

            addFigures(self);

            self.App.Visible=true;

            waitfor(self.LabelFigure,'FigureViewReady','on');
            waitfor(self.SliceFigure,'FigureViewReady','on');
            if self.VolumeSupported
                waitfor(self.VolumeFigure,'FigureViewReady','on');
                waitfor(self.OverviewFigure,'FigureViewReady','on');
            end

            [x,y,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition();
            self.App.WindowBounds=[x,y,width,height];

        end


        function closeApp(self,~)

            notify(self,'AppClosed');

        end


        function TF=closeVolumeDocument(self)

            TF=self.CanClose;

            self.VolumeDocument.Visible=false;
            self.VolumeVisible=false;

            updateAppLayout(self);

        end


        function TF=closeOverviewDocument(self)

            TF=self.CanClose;

            self.OverviewDocument.Visible=false;
            self.OverviewVisible=false;

            updateAppLayout(self);

        end


        function TF=closeLabelDocument(self)

            TF=self.CanClose;

            self.LabelDocument.Visible=false;
            self.LabelVisible=false;

            updateAppLayout(self);

        end


        function makeAllFiguresVisible(self)

            self.LabelVisible=true;
            self.VolumeVisible=true;

            set(self.LabelFigure,'Visible','on');
            set(self.SliceFigure,'Visible','on');
            set(self.SliceDocument,'Visible',true);
            set(self.LabelDocument,'Visible',true);

            if self.VolumeSupported
                set(self.VolumeFigure,'Visible','on');
                set(self.VolumeDocument,'Visible',true);
                if self.OverviewVisible
                    set(self.OverviewFigure,'Visible','on');
                    set(self.OverviewDocument,'Visible',true);
                end
            end

            drawnow;

            updateAppLayout(self);

        end


        function addFigures(self)

            group=matlab.ui.internal.FigureDocumentGroup();
            group.Title="Figures";
            self.App.add(group);


            figOptions.Title="Labels";
            figOptions.DocumentGroupTag=group.Tag;

            document=matlab.ui.internal.FigureDocument(figOptions);
            self.App.add(document);

            self.LabelFigure=document.Figure;
            self.LabelDocument=document;

            set(self.LabelDocument,'CanCloseFcn',@(~)closeLabelDocument(self));

            set(self.LabelFigure,'NumberTitle','off',...
            'Units','pixels',...
            'Name','Labels',...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'Visible','off',...
            'AutoResizeChildren','off',...
            'Tag','LabelFigure',...
            'SizeChangedFcn',@(~,~)reactToAppResize(self));


            figOptions.Title="Slice";
            figOptions.DocumentGroupTag=group.Tag;

            document=matlab.ui.internal.FigureDocument(figOptions);
            self.App.add(document);

            self.SliceFigure=document.Figure;
            self.SliceDocument=document;

            set(self.SliceFigure,'NumberTitle','off',...
            'Units','pixels',...
            'Name','Slice',...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'Visible','off',...
            'AutoResizeChildren','off',...
            'Tag','SliceFigure',...
            'SizeChangedFcn',@(~,~)reactToAppResize(self));

            self.CloseListener=event.listener(self.SliceFigure,'ObjectBeingDestroyed',@(~,~)closeApp(self));


            figOptions.Title="3-D Display";
            figOptions.DocumentGroupTag=group.Tag;

            document=matlab.ui.internal.FigureDocument(figOptions);
            self.App.add(document);

            self.VolumeFigure=document.Figure;
            self.VolumeDocument=document;

            if self.VolumeSupported
                set(self.VolumeDocument,'CanCloseFcn',@(~)closeVolumeDocument(self));
            else
                set(self.VolumeDocument,'Visible',false);
            end

            set(self.VolumeFigure,'NumberTitle','off',...
            'Units','pixels',...
            'Name','3-D Display',...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'Visible','off',...
            'AutoResizeChildren','on',...
            'Tag','VolumeFigure');


            figOptions.Title="Overview";
            figOptions.DocumentGroupTag=group.Tag;

            document=matlab.ui.internal.FigureDocument(figOptions);
            self.App.add(document);

            self.OverviewFigure=document.Figure;
            self.OverviewDocument=document;

            if self.VolumeSupported
                set(self.OverviewDocument,'CanCloseFcn',@(~)closeOverviewDocument(self));
                if~self.OverviewVisible
                    set(self.OverviewDocument,'Visible',false);
                end
            else
                set(self.OverviewDocument,'Visible',false);
            end

            set(self.OverviewFigure,'NumberTitle','off',...
            'Units','pixels',...
            'Name','Overview',...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'Visible','off',...
            'AutoResizeChildren','on',...
            'Tag','OverviewFigure');

            self.SliceDocument.Closable=false;

        end


        function createApp(self)


            appOptions.Tag="VolumeSegmenter"+"_"+matlab.lang.internal.uuid;
            appOptions.Title=getString(message('images:segmenter:volumeSegmenter'));
            appOptions.DefaultLayout=getDefaultLayout(self);

            [x,y,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition();
            appOptions.WindowBounds=[x,y,width,height];
            appOptions.Product="Image Processing Toolbox";
            appOptions.Scope="Volume Segmenter";
            self.App=matlab.ui.container.internal.AppContainer(appOptions);

            self.App.LeftCollapsed=true;

            self.HelpButton=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            self.HelpListener=addlistener(self.HelpButton,'ButtonPushed',@(~,~)notify(self,'HelpRequested'));

            self.UndoButton=matlab.ui.internal.toolstrip.qab.QABUndoButton();
            self.UndoListener=addlistener(self.UndoButton,'ButtonPushed',@(~,~)notify(self,'UndoRequested'));

            self.RedoButton=matlab.ui.internal.toolstrip.qab.QABRedoButton();
            self.RedoListener=addlistener(self.RedoButton,'ButtonPushed',@(~,~)notify(self,'RedoRequested'));


            self.App.add(self.HelpButton);
            self.App.add(self.RedoButton);
            self.App.add(self.UndoButton);

        end


        function removeFromLayout(~,~)

        end


        function str=getTitleBar(self)
            str=char(self.App.Title);
        end


        function setTitleBar(self,str)
            self.App.Title=str;
        end


        function figOrder=getFigureOrder(~)

            figOrder={'Labels','Slice','3-D Display'};

        end


    end


end