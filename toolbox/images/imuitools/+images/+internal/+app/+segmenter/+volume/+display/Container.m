classdef(Abstract,AllowedSubclasses={?images.internal.app.segmenter.volume.display.ToolgroupContainer,...
    ?images.internal.app.segmenter.volume.display.WebContainer})...
    Container<handle




    events

AppClosed

AppResized

AppLayoutUpdated

UndoRequested

RedoRequested

HelpRequested

SaveRequested

CutRequested

CopyRequested

PasteRequested

    end


    properties(GetAccess={...
        ?images.internal.app.segmenter.volume.View,...
        ?images.internal.app.segmenter.volume.display.ToolgroupContainer,...
        ?images.internal.app.segmenter.volume.display.WebContainer,...
        ?medical.internal.app.home.labeler.View,...
        ?medical.internal.app.home.labeler.display.Container,...
        ?images.uitest.factory.Tester,...
        ?uitest.factory.Tester},SetAccess=protected,Transient)

        SliceFigure matlab.ui.Figure

        VolumeFigure matlab.ui.Figure

        OverviewFigure matlab.ui.Figure

        LabelFigure matlab.ui.Figure

App

        CloseRequested(1,1)logical=false;

    end


    properties

        CanAppClose(1,1)logical=false;

    end


    properties(GetAccess={
        ?images.uitest.factory.Tester,...
        ?uitest.factory.Tester,...
        ?images.internal.app.segmenter.volume.display.ToolgroupContainer,...
        ?images.internal.app.segmenter.volume.display.WebContainer},SetAccess=protected,Transient)

UndoButton
RedoButton
HelpButton
SaveButton
CutButton
CopyButton
PasteButton

    end


    properties(Dependent,SetAccess=protected)

LabelPosition

SlicePosition

SliderPosition

SummaryPosition

VolumePosition

OverviewPosition

VolumeVisible

OverviewVisible

    end


    properties(SetAccess=immutable)

        VolumeSupported(1,1)logical=true;

    end


    properties(Access=protected,Hidden,Transient)

ProgressBar

        SliderHeight=20;

        LayoutFileName char

CachedLayout

        LabelVisible(1,1)logical=true;

        VolumeVisibleInternal(1,1)logical=true;

        OverviewVisibleInternal(1,1)logical=false;

UndoListener
RedoListener
SaveListener
CutListener
CopyListener
PasteListener
HelpListener

    end


    methods(Abstract)

        addTabs(self);

        setColumnLayout(self);
        setStackedLayout(self);

        clear(self);
        close(self);

        loc=getLocation(self);

        wait(self);
        resume(self);

        enableQuickAccessBar(self);
        disableQuickAccessBar(self);
        clearQuickAccessBar(self);

        enableUndo(self,TF);
        enableRedo(self,TF);
        enableCut(self,TF);
        enableCopy(self,TF);
        enablePaste(self,TF);

        approveClose(self);
        vetoClose(self);

    end


    methods(Abstract,Access=protected)

        createApp(self);
        openApp(self);

        removeFromLayout(self,str);
        figOrder=getFigureOrder(self);

        setLayout(self,layout);
        layout=getLayout(self);

        layout=getLayoutFromFile(self,fullFileName);
        setLayoutToFile(self,layout,fullFileName);

        setTwoColumnLayout(self);

        str=getTitleBar(self);
        setTitleBar(self,str);

    end


    methods




        function self=Container(show3DDisplay)

            if~show3DDisplay
                self.VolumeSupported=false;
            end

            setLayoutFileName(self);

            createApp(self);

        end




        function open(self)

            openApp(self);

            setStackedLayout(self);




            drawnow;

        end




        function showVolume(self,TF)

            if~self.VolumeSupported
                return;
            end

            if TF
                self.VolumeFigure.Visible='on';
                self.VolumeVisible=true;
            else
                self.VolumeFigure.Visible='off';
                self.VolumeVisible=false;
                removeFromLayout(self,'3-D Display');
            end

            updateAppLayout(self);

        end




        function showOverview(self,TF)

            if~self.VolumeSupported
                return;
            end

            if TF
                drawnow;
                self.OverviewFigure.Visible='on';
                self.OverviewVisible=true;
            else
                self.OverviewFigure.Visible='off';
                self.OverviewVisible=false;
                removeFromLayout(self,'Overview');
            end

            updateAppLayout(self);

        end




        function showLabels(self,TF)

            if TF
                self.LabelFigure.Visible='on';
                self.LabelVisible=true;
            else
                self.LabelFigure.Visible='off';
                self.LabelVisible=false;
                removeFromLayout(self,'Labels');
            end

            updateAppLayout(self);

        end




        function delete(self)

            delete(self.VolumeFigure);
            delete(self.OverviewFigure);
            delete(self.SliceFigure);
            delete(self.LabelFigure);

        end




        function setTitleBarName(self,str)

            if isempty(str)
                str='Untitled';
            end

            str=[getString(message('images:segmenter:volumeSegmenter')),' - ',str];

            setTitleBar(self,str);

        end




        function clearTitleBarName(self)

            setTitleBar(self,getString(message('images:segmenter:volumeSegmenter')));

        end




        function set3DDisplayFigureName(self,str)

            self.VolumeFigure.Name=str;

        end




        function addTitleBarAsterisk(self)

            str=getTitleBar(self);

            if~contains(str,'*')
                str=[str,'*'];
                setTitleBar(self,str);
            end

        end




        function removeTitleBarAsterisk(self)

            str=getTitleBar(self);

            setTitleBar(self,strrep(str,'*',''));

        end




        function bringToFront(~)

        end

    end

    methods(Access=protected)


        function updateAppLayout(self)

            notify(self,'AppLayoutUpdated',images.internal.app.segmenter.volume.events.AppLayoutUpdatedEventData(...
            self.VolumeVisible,self.LabelVisible,self.OverviewVisible));

        end


        function reactToAppClosing(self)

            self.CloseRequested=true;

            notify(self,'AppClosed');

        end


        function reactToAppResize(self)

            self.CachedLayout=getLayout(self);

            if isvalid(self.SliceFigure)
                notify(self,'AppResized');
            end

        end


        function makeAllFiguresVisible(self)

            self.LabelVisible=true;
            self.VolumeVisible=true;

            set(self.LabelFigure,'Visible','on');
            set(self.SliceFigure,'Visible','on');

            if self.VolumeSupported
                set(self.VolumeFigure,'Visible','on');
                if self.OverviewVisible
                    set(self.OverviewFigure,'Visible','on');
                end
            end

            drawnow;

            updateAppLayout(self);

        end


        function saveLayout(self)

            if~isempty(self.LayoutFileName)
                layout=self.CachedLayout;
                setLayoutToFile(self,layout,self.LayoutFileName);
            end

        end


        function setLayoutFileName(self)

            fileName='Layout.xml';
            writeDirectory=fullfile(prefdir,'images','VolumeLabeler');

            success=true;

            if~isfolder(writeDirectory)
                success=mkdir(writeDirectory);
            end

            if success
                self.LayoutFileName=string(fullfile(writeDirectory,fileName));
            end

        end

    end


    methods




        function pos=get.LabelPosition(self)

            pos=[1,1,floor(self.LabelFigure.Position(3:4))];
            pos(pos<1)=1;

        end




        function pos=get.SlicePosition(self)

            pos=[1,(2*self.SliderHeight)+1,floor(self.SliceFigure.Position(3)),floor(self.SliceFigure.Position(4))-(2*self.SliderHeight)];
            pos(pos<1)=1;

        end




        function pos=get.SliderPosition(self)

            pos=[1,1,floor(self.SliceFigure.Position(3)),self.SliderHeight];
            pos(pos<1)=1;

        end




        function pos=get.SummaryPosition(self)

            pos=[1,self.SliderHeight+1,floor(self.SliceFigure.Position(3)),self.SliderHeight];
            pos(pos<1)=1;

        end




        function pos=get.VolumePosition(self)

            pos=[1,1,floor(self.VolumeFigure.Position(3:4))];
            pos(pos<1)=1;

        end




        function pos=get.OverviewPosition(self)

            pos=[1,1,floor(self.OverviewFigure.Position(3:4))];
            pos(pos<1)=1;

        end




        function set.VolumeVisible(self,TF)

            if~self.VolumeSupported
                self.VolumeVisibleInternal=false;
            else
                self.VolumeVisibleInternal=TF;
            end

        end

        function TF=get.VolumeVisible(self)

            TF=self.VolumeVisibleInternal;

        end




        function set.OverviewVisible(self,TF)

            if~self.VolumeSupported
                self.OverviewVisibleInternal=false;
            else
                self.OverviewVisibleInternal=TF;
            end

        end

        function TF=get.OverviewVisible(self)

            TF=self.OverviewVisibleInternal;

        end

    end

end
