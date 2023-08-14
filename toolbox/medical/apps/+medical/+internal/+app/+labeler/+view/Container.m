classdef Container<handle




    properties
        CanClose(1,1)logical=true;
    end

    properties(SetAccess=protected,GetAccess={?uitest.factory.Tester,...
        ?medical.internal.app.labeler.View})

        App matlab.ui.container.internal.AppContainer

DataBrowserDocument
LabelBrowserDocument
MetadataDocument
PublishDocument

TransverseDocument
SagittalDocument
CoronalDocument
VolumeDocument

RenderingEditorDocument

DicomDatabaseDocument

UndoButton
RedoButton
HelpButton

AppResizedEventCoalescer

    end

    properties(Access=protected)

VoxelInfoStatusLabel
AppSessionIcon



PreviousLayout

        LeftPanelWidth(1,1)double=300;
        RightPanelWidth(1,1)double=390;

        IsMetadataPanelOpen(1,1)double
        IsRenderingEditorOpen(1,1)double
        IsLabelBrowserOpen(1,1)double


HelpListener
UndoListener
RedoListener


    end

    properties(Access=protected,Constant)
        ScreenToContainerRatio=0.8;
    end

    events

AppResized

AppClosed

UndoRequested

RedoRequested

HelpRequested

SelectedDocumentChanged

    end

    methods


        function self=Container(useDarkMode)

            self.createApp(useDarkMode);

            addlistener(self.App,'PropertyChanged',@(src,evt)self.appPropertyChanged(evt.PropertyName));

        end


        function delete(self)

            delete(self.AppResizedEventCoalescer);
            delete(self.App);

        end


        function openApp(self)

            self.App.CanCloseFcn=@(~,~)canAppClose(self);

            self.addDocuments();

            self.addPanels();
            self.addStatusBar();




            self.AppResizedEventCoalescer=images.internal.app.utilities.EventCoalescerPeriodic();
            addlistener(self.AppResizedEventCoalescer,'EventTriggered',@(~,~)resize(self));

            self.App.Visible=true;
            self.DataBrowserDocument.Opened=true;
            self.LabelBrowserDocument.Opened=false;

            waitfor(self.App,'State',matlab.ui.container.internal.appcontainer.AppState(1));

            self.bringToFront();

        end


        function setup(self,dataFormat)

            switch dataFormat

            case medical.internal.app.labeler.enums.DataFormat.Volume

                self.TransverseDocument.Visible=1;
                self.SagittalDocument.Visible=1;
                self.CoronalDocument.Visible=1;
                self.VolumeDocument.Visible=1;
                waitfor(self.VolumeDocument.Figure,'FigureViewReady','on');

                self.App.Layout=self.getLayout(medical.internal.app.labeler.view.Layout.Default);

                self.TransverseDocument.Title=getString(message('medical:medicalLabeler:transverse'));

                self.AppSessionIcon.Icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','VolumeSession_16.png');
                self.AppSessionIcon.Description=getString(message('medical:medicalLabeler:volumetricBtnLabel'));
                self.AppSessionIcon.Text=getString(message('medical:medicalLabeler:volumetricBtnLabel'));

                self.DataBrowserDocument.Opened=true;
                self.LabelBrowserDocument.Opened=true;

            case medical.internal.app.labeler.enums.DataFormat.Image

                self.TransverseDocument.Visible=1;
                self.SagittalDocument.Visible=0;
                self.CoronalDocument.Visible=0;
                self.VolumeDocument.Visible=0;
                self.RenderingEditorDocument.Opened=0;
                waitfor(self.TransverseDocument.Figure,'FigureViewReady','on');

                self.App.Layout=self.getLayout(medical.internal.app.labeler.view.Layout.Image);

                self.TransverseDocument.Title=getString(message('medical:medicalLabeler:slice'));

                self.AppSessionIcon.Icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','ImageSequenceSession_16.png');
                self.AppSessionIcon.Description=getString(message('medical:medicalLabeler:imageBtnLabel'));
                self.AppSessionIcon.Text=getString(message('medical:medicalLabeler:imageBtnLabel'));

                self.DataBrowserDocument.Opened=true;
                self.LabelBrowserDocument.Opened=true;

            otherwise
                error('Invalid mode, should never reach here')

            end

        end


        function loc=getLocation(self)
            loc=imageslib.internal.app.utilities.ScreenUtilities.getToolCenter(self.App);
        end


        function bringToFront(self)

            if ispc||ismac
                self.App.bringToFront();
            end

        end


        function addTabGroup(self,tabGroup)
            self.App.addTabGroup(tabGroup);
        end


        function setLayout(self,layoutType)

            if isa(layoutType,'medical.internal.app.labeler.view.Layout')

                layout=self.getLayout(layoutType);
                self.App.Layout=layout;

            else


                try
                    self.App.Layout=layoutType;
                catch


                    layout=self.getLayout(medical.internal.app.labeler.view.Layout.Image);
                    self.App.Layout=layout;
                end

            end

            pause(2);
            notify(self,'AppResized');

        end


        function wait(self)
            self.App.Busy=true;
        end


        function resume(self)
            self.App.Busy=false;
        end


        function resize(self)

            if isvalid(self.VolumeDocument)
                notify(self,'AppResized');
            end

        end


        function setIsCurrentDataOblique(self,TF)

            if TF
                str=medical.internal.app.labeler.utils.ras2Direction(medical.internal.app.labeler.enums.SliceDirection.Transverse);
                self.TransverseDocument.Title=str;

                str=medical.internal.app.labeler.utils.ras2Direction(medical.internal.app.labeler.enums.SliceDirection.Coronal);
                self.CoronalDocument.Title=str;

                str=medical.internal.app.labeler.utils.ras2Direction(medical.internal.app.labeler.enums.SliceDirection.Sagittal);
                self.SagittalDocument.Title=str;

            else
                self.TransverseDocument.Title=getString(message('medical:medicalLabeler:transverse'));
                self.CoronalDocument.Title=getString(message('medical:medicalLabeler:coronal'));
                self.SagittalDocument.Title=getString(message('medical:medicalLabeler:sagittal'));
            end



        end


        function showRenderingEditor(self,TF)

            self.RenderingEditorDocument.Opened=TF;
            self.IsRenderingEditorOpen=TF;

            pause(1);
            notify(self,'AppResized');

        end


        function showPublishPanel(self,TF)

            self.PublishDocument.Opened=TF;

            pause(1);
            notify(self,'AppResized');

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


        function setTitleBarName(self,str)

            if isempty(str)
                str='Untitled';
            end

            str=strcat(getString(message('medical:medicalLabeler:appName'))," - ",str);

            self.App.Title=str;

        end


        function clearTitleBarName(self)

            str=getString(message('medical:medicalLabeler:appName'));
            self.App.Title=str;

        end


        function addTitleBarAsterisk(self)

            str=self.App.Title;

            if~contains(str,'*')
                str=strcat(str,'*');
                self.App.Title=str;
            end

        end


        function removeTitleBarAsterisk(self)

            str=self.App.Title;
            self.App.Title=strrep(str,'*','');

        end


        function showVoxelInfo(self,TF)
            if~TF
                self.clearVoxelInfo();
            end
        end


        function updateVoxelInfo(self,position,intensity,index,sliceDirection)

            if sliceDirection==medical.internal.app.labeler.enums.SliceDirection.Unknown
                voxelInfo=sprintf('Slice: %d, Position: [%d %d], Intensity: %s',index,position(1),position(2),num2str(intensity));
            else

                if~isequal(self.TransverseDocument.Title,getString(message('medical:medicalLabeler:transverse')))

                    sliceDirString=medical.internal.app.labeler.utils.ras2Direction(sliceDirection);
                else
                    sliceDirString=string(sliceDirection);
                end
                voxelInfo=sprintf('Slice: %d (%s), Position: [%d %d], Intensity: %s',index,sliceDirString,position(1),position(2),num2str(intensity));

            end

            self.VoxelInfoStatusLabel.Text=voxelInfo;

        end


        function clearVoxelInfo(self)
            self.VoxelInfoStatusLabel.Text="";
        end

    end

    methods(Access=private)

        function createApp(self,useDarkMode)

            [x,y,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition(self.ScreenToContainerRatio);
            appOptions.Title=getString(message('medical:medicalLabeler:appName'));
            appOptions.Tag="MedicalLabeler"+"_"+matlab.lang.internal.uuid;
            appOptions.CleanStart=1;
            appOptions.Icon=fullfile(matlabroot,'toolbox','images','icons','volume_24.png');
            appOptions.WindowBounds=[x,y,width,height];
            appOptions.Product="Medical Imaging Toolbox";
            appOptions.Scope="Medical Labeler";
            appOptions.EnableTheming=useDarkMode;

            self.App=matlab.ui.container.internal.AppContainer(appOptions);
            self.App.Tag="MedicalImageLabeler";
            self.App.DocumentPlaceHolderText=getString(message('medical:medicalLabeler:startupNewSessionText'));

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

        function addDocuments(self)

            self.add2DSliceDocuments();
            self.add3DVolumeDocument();


        end

        function add2DSliceDocuments(self)

            group=matlab.ui.internal.FigureDocumentGroup();
            group.Title="2D Slices";
            group.Tag=string(medical.internal.app.labeler.enums.Tag.SlicesDocGroup);
            self.App.add(group);

            figOptions.DocumentGroupTag=group.Tag;
            figOptions.Closable=false;
            figOptions.Visible=0;


            figOptions.Title=getString(message('medical:medicalLabeler:transverse'));
            figOptions.Tag=string(medical.internal.app.labeler.enums.Tag.TransverseFigure);
            self.TransverseDocument=matlab.ui.internal.FigureDocument(figOptions);
            self.App.add(self.TransverseDocument);

            hFig=self.TransverseDocument.Figure;
            set(hFig,'NumberTitle','off',...
            'Units','pixels',...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'AutoResizeChildren','off',...
            'Tag','TransverseSliceFigure',...
            'SizeChangedFcn',@(~,~)reactToAppResize(self));


            figOptions.Title=getString(message('medical:medicalLabeler:sagittal'));
            figOptions.Tag=string(medical.internal.app.labeler.enums.Tag.SagittalFigure);
            self.SagittalDocument=matlab.ui.internal.FigureDocument(figOptions);
            self.App.add(self.SagittalDocument);

            hFig=self.SagittalDocument.Figure;
            set(hFig,'NumberTitle','off',...
            'Units','pixels',...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'Tag','SagittalSliceFigure',...
            'AutoResizeChildren','off');


            figOptions.Title=getString(message('medical:medicalLabeler:coronal'));
            figOptions.Tag=string(medical.internal.app.labeler.enums.Tag.CoronalFigure);
            self.CoronalDocument=matlab.ui.internal.FigureDocument(figOptions);
            self.App.add(self.CoronalDocument);

            hFig=self.CoronalDocument.Figure;
            set(hFig,'NumberTitle','off',...
            'Units','pixels',...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'Tag','CoronalSliceFigure',...
            'AutoResizeChildren','off');

        end

        function add3DVolumeDocument(self)


            group=matlab.ui.internal.FigureDocumentGroup();
            group.Title="3D Volume";
            group.Tag=string(medical.internal.app.labeler.enums.Tag.VolumeDocGroup);
            self.App.add(group);

            figOptions.Title=getString(message('medical:medicalLabeler:volume3D'));
            figOptions.Tag=string(medical.internal.app.labeler.enums.Tag.VolumeFigure);
            figOptions.DocumentGroupTag=group.Tag;
            figOptions.Closable=false;
            figOptions.Visible=0;

            self.VolumeDocument=matlab.ui.internal.FigureDocument(figOptions);
            self.App.add(self.VolumeDocument);

            hFig=self.VolumeDocument.Figure;
            set(hFig,'NumberTitle','off',...
            'Units','pixels',...
            'Color',[0,0,0],...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'AutoResizeChildren','on');

        end


        function addDicomDatabaseDocument(self)

            group=matlab.ui.internal.FigureDocumentGroup();
            group.Title="DicomBrowser";
            group.Tag=string(medical.internal.app.labeler.enums.Tag.DicomDatabaseDocGroup);
            self.App.add(group);

            figOptions.Title=getString(message('medical:medicalLabeler:dicomDatabase'));
            figOptions.Tag=string(medical.internal.app.labeler.enums.Tag.DicomDatabaseFigure);
            figOptions.DocumentGroupTag=group.Tag;
            figOptions.Closable=false;

            self.DicomDatabaseDocument=matlab.ui.internal.FigureDocument(figOptions);
            self.App.add(self.DicomDatabaseDocument);

            hFig=self.DicomDatabaseDocument.Figure;
            set(hFig,'NumberTitle','off',...
            'Units','pixels',...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'AutoResizeChildren','off',...
            'SizeChangedFcn',@(~,~)reactToAppResize(self));


            self.DicomDatabaseDocument.Phantom=true;

        end

        function addPanels(self)


            appWidth=self.App.WindowBounds(4);
            panelWidth=min(self.LeftPanelWidth,0.4*appWidth);

            panelOptions.Region="left";
            panelOptions.PermissibleRegions="left";
            panelOptions.Collapsible=false;
            panelOptions.Maximizable=false;
            panelOptions.Contextual=false;
            panelOptions.PreferredWidth=panelWidth;


            panelOptions.Title=getString(message('medical:medicalLabeler:dataBrowser'));
            panelOptions.Tag=strcat("A",string(medical.internal.app.labeler.enums.Tag.LabelBrowserPanel));

            self.DataBrowserDocument=matlab.ui.internal.FigurePanel(panelOptions);
            self.DataBrowserDocument.Opened=true;
            self.App.add(self.DataBrowserDocument);

            hFig=self.DataBrowserDocument.Figure;
            set(hFig,...
            'Tag','DataBrowserFigure',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'Color',[1,1,1],...
            'AutoResizeChildren','off',...
            'SizeChangedFcn',@(~,~)reactToAppResize(self));



            panelOptions.Region="left";
            panelOptions.PermissibleRegions="left";
            panelOptions.Tag=strcat("B",string(medical.internal.app.labeler.enums.Tag.LabelBrowserPanel));
            panelOptions.Title=getString(message('medical:medicalLabeler:labelBrowser'));

            self.LabelBrowserDocument=matlab.ui.internal.FigurePanel(panelOptions);
            self.LabelBrowserDocument.Opened=false;
            self.App.add(self.LabelBrowserDocument);

            hFig=self.LabelBrowserDocument.Figure;
            set(hFig,...
            'Tag','LabelBrowserFigure',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'AutoResizeChildren','off');



            appWidth=self.App.WindowBounds(4);
            panelWidth=0.4*appWidth;
            panelOptions.PreferredWidth=panelWidth;


            panelOptions.Region="right";
            panelOptions.PermissibleRegions="right";
            panelOptions.Tag=string(medical.internal.app.labeler.enums.Tag.RenderingEditorPanel);
            panelOptions.Title=getString(message('medical:medicalLabeler:renderingEditorDocumentName'));
            self.RenderingEditorDocument=matlab.ui.internal.FigurePanel(panelOptions);
            self.RenderingEditorDocument.Opened=false;
            self.App.add(self.RenderingEditorDocument);

            hFig=self.RenderingEditorDocument.Figure;
            set(hFig,...
            'Tag','RenderingEditorFigure',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'AutoResizeChildren','off',...
            'SizeChangedFcn',@(~,~)reactToAppResize(self));


            panelOptions.Tag=string(medical.internal.app.labeler.enums.Tag.PublishPanel);
            panelOptions.Title=getString(message('medical:medicalLabeler:publish'));
            self.PublishDocument=matlab.ui.internal.FigurePanel(panelOptions);
            self.PublishDocument.Opened=false;
            self.App.add(self.PublishDocument);

            hFig=self.PublishDocument.Figure;
            set(hFig,...
            'Tag','PublishFigure',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'AutoResizeChildren','off',...
            'SizeChangedFcn',@(~,~)reactToAppResize(self));


            panelOptions.Tag=string(medical.internal.app.labeler.enums.Tag.MetadataPanel);
            panelOptions.Title=getString(message('medical:medicalLabeler:metadata'));
            self.MetadataDocument=matlab.ui.internal.FigurePanel(panelOptions);
            self.MetadataDocument.Opened=false;
            self.App.add(self.MetadataDocument);

            hFig=self.MetadataDocument.Figure;
            set(hFig,...
            'Tag','MetadataFigure',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'AutoResizeChildren','off',...
            'SizeChangedFcn',@(~,~)reactToAppResize(self));

        end

        function addStatusBar(self)


            self.VoxelInfoStatusLabel=matlab.ui.internal.statusbar.StatusLabel();
            self.VoxelInfoStatusLabel.Tag="VoxelInfoStatusLabel";
            self.VoxelInfoStatusLabel.Text="";
            self.VoxelInfoStatusLabel.Region="left";


            self.AppSessionIcon=matlab.ui.internal.statusbar.StatusLabel();
            self.AppSessionIcon.Tag="AppSessionIcon";
            self.AppSessionIcon.Text="";
            self.AppSessionIcon.Description="";
            self.AppSessionIcon.Region="right";


            statusBar=matlab.ui.internal.statusbar.StatusBar();
            statusBar.Tag="statusBar";
            statusBar.add(self.VoxelInfoStatusLabel);
            statusBar.add(self.AppSessionIcon);
            self.App.add(statusBar);

        end

        function layout=getLayout(self,layoutType)

            layout=struct;

            if isvalid(self.App)
                layout=self.App.Layout;
            end

            layout=getLayout(layoutType,layout);

        end

    end


    methods

        function TF=canAppClose(self)

            TF=self.CanClose;

            if TF
                self.cleanUp();
                notify(self,'AppClosed');
            end

        end

        function reactToAppResize(self)
            self.AppResizedEventCoalescer.trigger();

        end

        function appPropertyChanged(self,propertyName)

            if propertyName~="SelectedChild"
                return
            end


            if isvalid(self.App)&&~isempty(self.App.SelectedChild)&&isfield(self.App.SelectedChild,'tag')
                evt=medical.internal.app.labeler.events.ValueEventData(self.App.SelectedChild.tag);
                self.notify('SelectedDocumentChanged',evt);
            end

        end

        function cleanUp(self)

            delete(self.AppResizedEventCoalescer);

        end

    end


end
