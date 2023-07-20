




classdef View<handle

    properties(Transient=true)
ToolGroup
    end

    properties(Dependent)
VolumeMode
    end


    properties
VolVizTab
VolumeSource
LabeledVolumeSource
    end


    properties

xySliceFig
yzSliceFig
xzSliceFig


xySliceView
yzSliceView
xzSliceView


volumeRenderingFig


volumeRenderingView


slicePlane3DViewer


renderingEditorFigure


renderingEditorView


orientationAxesFigure


orientationAxesView
    end


    properties

NewSessionButton

ShowSlicesToggleButton
ShowVolumeToggleButton


CustomReferencingButton
UniformInWorldButton
UseFileMetadataButton


XAxisLabel
YAxisLabel
ZAxisLabel


XUnitsLabel
YUnitsLabel
ZUnitsLabel


XAxisUnitsEditField
YAxisUnitsEditField
ZAxisUnitsEditField

VolumeModeButton
LabelModeButton

RestoreDefaultButton
BackgroundColorButton
DefaultLayoutButton
ExportButton
ExportConfigSubitem

IconRoot
NewSessionIcon
ImportVolume
ImportLabeledVolume
SliceIcon
VolIcon
LabelVolIcon
IsoIcon
MipIcon
RestoreIcon
ExportRenderingIcon
ExportIcon

    end



    properties

VolumeCamera
VolumeTransform
VolumePanel
Canvas
DefaultCanvasColor

    end

    events
ImportFromFile
ImportFromDicomFolder
ImportFromWorkspace
StartNewSession
BackgroundColorChange
ReplaceOrOverlayResult
    end


    methods

        function self=View

            import matlab.ui.internal.toolstrip.*

            self.VolumeSource="";
            self.LabeledVolumeSource="";


            self.ToolGroup=matlab.ui.internal.desktop.ToolGroup(getString(message('images:volumeViewerToolgroup:appName')));


            self.ToolGroup.setContextualHelpCallback(@(es,ed)doc('volumeViewer'));


            images.internal.app.utilities.addDDUXLogging(self.ToolGroup,'Image Processing Toolbox','Volume Viewer');

            self.createIcons();


            self.removeViewTab();


            [x,y,width,height]=imageslib.internal.apputil.ScreenUtilities.getInitialToolPosition();
            self.ToolGroup.setPosition(x,y,width,height);
            self.ToolGroup.disableDataBrowser();


            self.createVolViewTab();
            self.createFileSection();
            self.createImportSection();
            self.createSpatialReferencingSection();
            self.createViewSection();
            self.createVolumeRenderingSection();
            self.createLayoutAndBackgroundSection();
            self.createExportSection();



            self.ToolGroup.setClosingApprovalNeeded(true);
            self.ToolGroup.open();


            internal.setJavaCustomData(self.ToolGroup.Peer,self);


            self.createFigures()



            self.addFigures();
            self.removeDocumentTabs();
            drawnow;

            self.positionFigures();
            self.disableCloseGestureOnDockedFeatures();


            self.respondToCloseCommands();


            self.create2DSliceViews();


            self.createVolumeRenderingSettingsView();



            self.createVolumeCanvasViewArea();



            drawnow;



            self.DefaultCanvasColor=self.Canvas.Color;



            self.createVolumeViewCamera();


            self.createVolumeRenderingView();
            self.create3DSliceView();


            self.orientationAxesView=images.internal.app.volviewToolgroup.OrientationAxes(self.orientationAxesFigure,self.VolumeCamera.Position);


            addlistener(self.volumeRenderingFig,'SizeChanged',@(hobj,evt)self.manageVolumeFigureResize());

        end

        function delete(self)
            if~isempty(self.ToolGroup)&&isvalid(self.ToolGroup)
                imageslib.internal.apputil.manageToolInstances('remove','volumeViewerToolgroup',self);
                self.ToolGroup.setClosingApprovalNeeded(false);
                self.ToolGroup.approveClose();


                delete(self.renderingEditorView);




                close(self.renderingEditorFigure);
                self.ToolGroup.close();
                delete(self.ToolGroup);
            end
        end

    end


    methods

        function createIcons(self)

            import matlab.ui.internal.toolstrip.*

            self.IconRoot=fullfile(matlabroot,'toolbox','images','icons');
            self.ImportVolume=Icon(fullfile(self.IconRoot,'importVolume_24.png'));
            self.ImportLabeledVolume=Icon(fullfile(self.IconRoot,'importLabeledVolume_24.png'));
            self.NewSessionIcon=matlab.ui.internal.toolstrip.Icon.NEW_24;
            self.SliceIcon=Icon(fullfile(self.IconRoot,'slice_plane_24.png'));
            self.VolIcon=Icon(fullfile(self.IconRoot,'volume_24.png'));
            self.LabelVolIcon=Icon(fullfile(self.IconRoot,'LabelVolume_24.png'));
            self.IsoIcon=Icon(fullfile(self.IconRoot,'isosurface_24.png'));
            self.MipIcon=Icon(fullfile(self.IconRoot,'mip_24.png'));
            self.RestoreIcon=Icon(fullfile(self.IconRoot,'Reset_24.png'));
            self.ExportIcon=Icon(fullfile(self.IconRoot,'CreateMask_24px.png'));
            self.ExportRenderingIcon=Icon(fullfile(self.IconRoot,'ExportRendering_24.png'));

        end

        function createVolViewTab(self)

            import matlab.ui.internal.toolstrip.*

            tabgroup=TabGroup();
            self.VolVizTab=Tab(getString(message('images:volumeViewerToolgroup:volVizTabName')));
            tabgroup.add(self.VolVizTab);
            self.VolVizTab.Tag='tab_vol_viz';
            self.ToolGroup.addTabGroup(tabgroup);

        end

        function createFileSection(self)

            import matlab.ui.internal.toolstrip.*
            section=self.VolVizTab.addSection(upper(getString(message('images:volumeViewerToolgroup:fileSection'))));


            column=section.addColumn();
            button=Button(getString(message('images:volumeViewerToolgroup:newSessionButtonLabel')),self.NewSessionIcon);
            button.Tag='New Session';
            button.Description=getString(message('images:volumeViewerToolgroup:newSessionButtonDescription'));
            button.Enabled=false;
            addlistener(button,'ButtonPushed',@(hobj,evt)self.newSessionClick());
            self.NewSessionButton=button;
            column.add(self.NewSessionButton);
        end

        function createImportSection(self)

            import matlab.ui.internal.toolstrip.*
            section=self.VolVizTab.addSection(upper(getString(message('images:volumeViewerToolgroup:importSection'))));


            column1=section.addColumn();
            volType='volume';

            button1=SplitButton(getString(message('images:volumeViewerToolgroup:importVolumeBtn')),self.ImportVolume);
            button1.Tag='Load Data';
            button1.Description=getString(message('images:volumeViewerToolgroup:importVolumeDescription'));
            button1.ButtonPushedFcn=@(varargin)self.getVolumeFromFile(volType);

            popup1=PopupList();
            button1.Popup=popup1;
            popup1.Tag='LoadButtonPopUp';

            item=ListItem(getString(message('images:volumeViewerToolgroup:importFromFile')),Icon.IMPORT_16);
            item.Tag='Load From File';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)self.getVolumeFromFile(volType);
            popup1.add(item);

            item=ListItem(getString(message('images:volumeViewerToolgroup:importFromDicomFolder')),Icon.OPEN_16);
            item.Tag='Load From DICOM Folder';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)self.getVolumeFromDicomFolder(volType);
            popup1.add(item);

            item=ListItem(getString(message('images:volumeViewerToolgroup:importFromWorkspace')),Icon.IMPORT_16);
            item.Tag='Import From Workspace';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)self.getVolumeFromWorkspace(volType);
            popup1.add(item);

            column1.add(button1);


            column2=section.addColumn();
            volType='labels';

            button2=SplitButton(getString(message('images:volumeViewerToolgroup:importLabeledVolumeBtn')),self.ImportLabeledVolume);
            button2.Tag='Load Labeled Data';
            button2.Description=getString(message('images:volumeViewerToolgroup:importLabeledVolumeDescription'));
            button2.ButtonPushedFcn=@(varargin)self.getVolumeFromFile(volType);

            popup2=PopupList();
            button2.Popup=popup2;
            popup2.Tag='LoadButtonPopUp';

            item=ListItem(getString(message('images:volumeViewerToolgroup:importFromFile')),Icon.IMPORT_16);
            item.Tag='Load Labeled From File';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)self.getVolumeFromFile(volType);
            popup2.add(item);

            item=ListItem(getString(message('images:volumeViewerToolgroup:importFromDicomFolder')),Icon.OPEN_16);
            item.Tag='Load Labeled From DICOM Folder';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)self.getVolumeFromDicomFolder(volType);
            popup2.add(item);

            item=ListItem(getString(message('images:volumeViewerToolgroup:importFromWorkspace')),Icon.IMPORT_16);
            item.Tag='Import Labeled From Workspace';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)self.getVolumeFromWorkspace(volType);
            popup2.add(item);

            column2.add(button2);

        end

        function createSpatialReferencingSection(self)

            import matlab.ui.internal.toolstrip.*


            section=self.VolVizTab.addSection(upper(getString(message('images:volumeViewerToolgroup:spatialRefSectionName'))));
            section.Tag='spatialReferencing';


            column1=section.addColumn();
            buttonGroup=ButtonGroup();

            self.CustomReferencingButton=RadioButton(buttonGroup,getString(message('images:volumeViewerToolgroup:specifyDimensionsButtonLabel')));
            self.CustomReferencingButton.Description=getString(message('images:volumeViewerToolgroup:specifyDimensionsButtonDescription'));
            self.CustomReferencingButton.Enabled=false;
            column1.add(self.CustomReferencingButton);

            self.UniformInWorldButton=RadioButton(buttonGroup,getString(message('images:volumeViewerToolgroup:upsampleToCubeButtonLabel')));
            self.UniformInWorldButton.Description=getString(message('images:volumeViewerToolgroup:upsampleToCubeButtonDescription'));
            self.UniformInWorldButton.Enabled=false;
            column1.add(self.UniformInWorldButton);

            self.UseFileMetadataButton=RadioButton(buttonGroup,getString(message('images:volumeViewerToolgroup:useMetadataButtonLabel')));
            self.UseFileMetadataButton.Description=getString(message('images:volumeViewerToolgroup:useMetadataButtonDescription'));
            self.UseFileMetadataButton.Enabled=false;
            column1.add(self.UseFileMetadataButton);

            self.CustomReferencingButton.Value=true;

            section.addColumn('Width',10);


            column2=section.addColumn();

            self.XAxisLabel=Label(getString(message('images:volumeViewerToolgroup:xAxisLabel')));
            self.XAxisLabel.Enabled=false;
            column2.add(self.XAxisLabel);

            self.YAxisLabel=Label(getString(message('images:volumeViewerToolgroup:yAxisLabel')));
            self.YAxisLabel.Enabled=false;
            column2.add(self.YAxisLabel);

            self.ZAxisLabel=Label(getString(message('images:volumeViewerToolgroup:zAxisLabel')));
            self.ZAxisLabel.Enabled=false;
            column2.add(self.ZAxisLabel);


            column3=section.addColumn('Width',70);

            self.XAxisUnitsEditField=EditField();
            self.XAxisUnitsEditField.Enabled=false;
            self.XAxisUnitsEditField.Tag='XAxisUnitsEditField';
            column3.add(self.XAxisUnitsEditField);

            self.YAxisUnitsEditField=EditField();
            self.YAxisUnitsEditField.Enabled=false;
            self.YAxisUnitsEditField.Tag='YAxisUnitsEditField';
            column3.add(self.YAxisUnitsEditField);

            self.ZAxisUnitsEditField=EditField();
            self.ZAxisUnitsEditField.Enabled=false;
            self.ZAxisUnitsEditField.Tag='ZAxisUnitsEditField';
            column3.add(self.ZAxisUnitsEditField);


            column4=section.addColumn();

            self.XUnitsLabel=Label(getString(message('images:volumeViewerToolgroup:unitsLabel')));
            self.XUnitsLabel.Enabled=false;
            column4.add(self.XUnitsLabel);

            self.YUnitsLabel=Label(getString(message('images:volumeViewerToolgroup:unitsLabel')));
            self.YUnitsLabel.Enabled=false;
            column4.add(self.YUnitsLabel);

            self.ZUnitsLabel=Label(getString(message('images:volumeViewerToolgroup:unitsLabel')));
            self.ZUnitsLabel.Enabled=false;
            column4.add(self.ZUnitsLabel);
        end

        function createViewSection(self)

            import matlab.ui.internal.toolstrip.*

            section=self.VolVizTab.addSection(upper(getString(message('images:volumeViewerToolgroup:viewSectionName'))));

            c=section.addColumn();
            buttonGroup=ButtonGroup();

            self.VolumeModeButton=RadioButton(buttonGroup,getString(message('images:volumeViewerToolgroup:volumeModeVolume')));
            self.VolumeModeButton.Description=getString(message('images:volumeViewerToolgroup:volumeModePopupDescription'));
            self.VolumeModeButton.Tag='VolumeModeButton';
            self.VolumeModeButton.Enabled=false;
            c.add(self.VolumeModeButton);

            self.LabelModeButton=RadioButton(buttonGroup,getString(message('images:volumeViewerToolgroup:volumeModeLabels')));
            self.LabelModeButton.Description=getString(message('images:volumeViewerToolgroup:volumeModePopupDescription'));
            self.VolumeModeButton.Tag='LabelModeButton';
            self.LabelModeButton.Enabled=false;
            c.add(self.LabelModeButton);

            section.addColumn('Width',10);

            group=ButtonGroup();
            column1=section.addColumn();
            control=ToggleButton(getString(message('images:volumeViewerToolgroup:viewVolumeButtonLabel')),self.VolIcon,group);
            column1.add(control);
            self.ShowVolumeToggleButton=control;
            self.ShowVolumeToggleButton.Description=getString(message('images:volumeViewerToolgroup:showVolumeButtonDescription'));
            column2=section.addColumn();

            control=ToggleButton(getString(message('images:volumeViewerToolgroup:viewSlicesButtonLabel')),self.SliceIcon,group);
            column2.add(control);
            self.ShowSlicesToggleButton=control;
            self.ShowSlicesToggleButton.Description=getString(message('images:volumeViewerToolgroup:show3DSlicesButtonDescription'));
            self.ShowVolumeToggleButton.Value=true;

            self.ShowSlicesToggleButton.Enabled=false;
            self.ShowVolumeToggleButton.Enabled=false;

        end

        function createVolumeRenderingSection(self)

            import matlab.ui.internal.toolstrip.*

            section=self.VolVizTab.addSection(upper(getString(message('images:volumeViewerToolgroup:volumeRenderingSectionName'))));

            column1=section.addColumn();
            button=Button(getString(message('images:volumeViewerToolgroup:restoreRenderingButtonLabel')),self.RestoreIcon);
            button.Tag='Restore Default';
            button.Enabled=false;
            button.Description=getString(message('images:volumeViewerToolgroup:restoreDefaultButtonDescription'));
            self.RestoreDefaultButton=button;
            column1.add(button);

        end

        function createLayoutAndBackgroundSection(self)

            import matlab.ui.internal.toolstrip.*

            section=self.VolVizTab.addSection(upper(getString(message('images:volumeViewerToolgroup:layoutAndBGSectionName'))));
            column1=section.addColumn();

            button1=Button(getString(message('images:volumeViewerToolgroup:layoutButtonLabel')),Icon.LAYOUT_24);
            button1.Tag='Default Layout';
            self.DefaultLayoutButton=button1;
            self.DefaultLayoutButton.Enabled=true;
            button1.Description=getString(message('images:volumeViewerToolgroup:layoutButtonDescription'));
            column1.add(button1);
            addlistener(self.DefaultLayoutButton,'ButtonPushed',@(hobj,evt)self.positionFigures());

            button2=Button(getString(message('images:volumeViewerToolgroup:backgroundColorButtonLabel')));
            button2.Tag='Background Color';
            button2.Description=getString(message('images:volumeViewerToolgroup:backgroundColorButtonDescription'));
            column1.add(button2);
            addlistener(button2,'ButtonPushed',@(hobj,evt)self.launchBackgroundColorDialog());
            self.BackgroundColorButton=button2;
            self.BackgroundColorButton.Enabled=false;

        end

        function createExportSection(self)
            import matlab.ui.internal.toolstrip.*
            section=self.VolVizTab.addSection(upper(getString(message('images:volumeViewerToolgroup:exportSectionName'))));


            column1=section.addColumn();
            button=SplitButton(getString(message('images:volumeViewerToolgroup:exportSectionName')),self.ExportIcon);
            button.Tag='Export';
            button.Description=getString(message('images:volumeViewerToolgroup:exportButtonDescription'));
            button.Enabled=false;
            self.ExportButton=button;



            popup=PopupList();
            button.Popup=popup;

            subItem1=ListItem(getString(message('images:volumeViewerToolgroup:exportRenderingSubItem')),self.ExportRenderingIcon);
            subItem1.Description=getString(message('images:volumeViewerToolgroup:exportRenderingSubItemDescription'));
            self.ExportConfigSubitem=subItem1;
            popup.add(subItem1);

            column1.add(button);
        end

        function setCustomReferencingButtonActive(self)

            self.CustomReferencingButton.Value=true;

        end

        function setSpatialReferencingEditFields(self,xSize,ySize,zSize)
            self.XAxisUnitsEditField.Value=num2str(xSize);
            self.YAxisUnitsEditField.Value=num2str(ySize);
            self.ZAxisUnitsEditField.Value=num2str(zSize);
        end

    end


    methods

        function createFigures(self)

            self.xySliceFig=figure('Name',getString(message('images:volumeViewerToolgroup:sliceDocumentName','XY')),...
            'Tag','xySlice','NumberTitle','off','IntegerHandle','off','WindowKeyPressFcn',@(varargin)[],...
            'HandleVisibility','callback','Visible','off');

            self.xzSliceFig=figure('Name',getString(message('images:volumeViewerToolgroup:sliceDocumentName','XZ')),...
            'Tag','xzSlice','NumberTitle','off','IntegerHandle','off','WindowKeyPressFcn',@(varargin)[],...
            'HandleVisibility','callback','Visible','off');

            self.yzSliceFig=figure('Name',getString(message('images:volumeViewerToolgroup:sliceDocumentName','YZ')),...
            'Tag','yzSlice','NumberTitle','off','IntegerHandle','off','WindowKeyPressFcn',@(varargin)[],...
            'HandleVisibility','callback','Visible','off');

            self.volumeRenderingFig=figure('Name',getString(message('images:volumeViewerToolgroup:volumeDocumentName')),...
            'Tag','volumeFig','NumberTitle','off','IntegerHandle','off','WindowKeyPressFcn',@(varargin)[],...
            'HandleVisibility','callback','Visible','off');

            self.renderingEditorFigure=figure('Name',getString(message('images:volumeViewerToolgroup:renderingEditorDocumentName')),...
            'Tag','renderingEditor','NumberTitle','off','IntegerHandle','off','WindowKeyPressFcn',@(varargin)[],...
            'HandleVisibility','callback','Visible','off');

            self.orientationAxesFigure=figure('Name',getString(message('images:volumeViewerToolgroup:orientationAxesDocumentName')),...
            'Tag','orientationAxes','NumberTitle','off','IntegerHandle','off','WindowKeyPressFcn',@(varargin)[],...
            'Visible','off');

        end

        function addFigures(self)

            self.ToolGroup.addFigure(self.xySliceFig);
            self.ToolGroup.addFigure(self.xzSliceFig);
            self.ToolGroup.addFigure(self.yzSliceFig);
            self.ToolGroup.addFigure(self.volumeRenderingFig);
            self.ToolGroup.addFigure(self.renderingEditorFigure);
            self.ToolGroup.addFigure(self.orientationAxesFigure);



            set(self.xySliceFig,'Visible','on');
            set(self.xzSliceFig,'Visible','on');
            set(self.yzSliceFig,'Visible','on');
            set(self.volumeRenderingFig,'Visible','on');
            set(self.renderingEditorFigure,'Visible','on');
            set(self.orientationAxesFigure,'Visible','on');

        end

        function respondToCloseCommands(self)







            self.orientationAxesFigure.DeleteFcn=@(hObj,evt)destroyInstance();

            function destroyInstance()
                delete(self);
            end

        end

        function manageVolumeFigureResize(self)
            self.setCameraViewportPosition();
        end

        function setCameraViewportPosition(self)

            figUnits=self.volumeRenderingFig.Units;
            self.volumeRenderingFig.Units='pixels';
            newFigSize=self.volumeRenderingFig.Position;

            fullyInitialzedState=strcmp(self.VolumeCamera.Viewport.Units,'pixels');

            if fullyInitialzedState
                pos=newFigSize;
                if pos(4)/pos(3)>1
                    pos(4)=abs(pos(3));
                else
                    pos(3)=abs(pos(4));
                end

                offsetX=max(0,(newFigSize(3)-pos(3))/2);
                offsetY=max(0,(newFigSize(4)-pos(4))/2);
                pos(1:2)=[offsetX+1,offsetY+1];

                self.VolumeCamera.Viewport.Position=pos;
            end

            self.volumeRenderingFig.Units=figUnits;
        end

        function positionFigures(self)

            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;


            md.setDocumentArrangement(self.ToolGroup.Name,md.TILED,java.awt.Dimension(3,4));


            loc=com.mathworks.widgets.desk.DTLocation.create(0);
            md.setClientLocation(self.xySliceFig.Name,self.ToolGroup.Name,loc);
            loc=com.mathworks.widgets.desk.DTLocation.create(3);
            md.setClientLocation(self.xzSliceFig.Name,self.ToolGroup.Name,loc);
            loc=com.mathworks.widgets.desk.DTLocation.create(6);
            md.setClientLocation(self.yzSliceFig.Name,self.ToolGroup.Name,loc);
            loc=com.mathworks.widgets.desk.DTLocation.create(9);
            md.setClientLocation(self.orientationAxesFigure.Name,self.ToolGroup.Name,loc);
            loc=com.mathworks.widgets.desk.DTLocation.create(1);
            md.setClientLocation(self.volumeRenderingFig.Name,self.ToolGroup.Name,loc);

            loc=com.mathworks.widgets.desk.DTLocation.create(2);
            md.setClientLocation(self.renderingEditorFigure.Name,self.ToolGroup.Name,loc);

            md.setDocumentRowSpan(self.ToolGroup.Name,0,1,4);
            md.setDocumentRowSpan(self.ToolGroup.Name,0,2,4);

            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.setDocumentColumnWidths(self.ToolGroup.Name,[0.25,0.55,0.20]);

            drawnow;

        end

        function disableCloseGestureOnDockedFeatures(self)

            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
            md.getClient(self.xySliceFig.Name,self.ToolGroup.Name).putClientProperty(prop,java.lang.Boolean.FALSE);
            md.getClient(self.xzSliceFig.Name,self.ToolGroup.Name).putClientProperty(prop,java.lang.Boolean.FALSE);
            md.getClient(self.yzSliceFig.Name,self.ToolGroup.Name).putClientProperty(prop,java.lang.Boolean.FALSE);
            md.getClient(self.volumeRenderingFig.Name,self.ToolGroup.Name).putClientProperty(prop,java.lang.Boolean.FALSE);
            md.getClient(self.renderingEditorFigure.Name,self.ToolGroup.Name).putClientProperty(prop,java.lang.Boolean.FALSE);
            md.getClient(self.orientationAxesFigure.Name,self.ToolGroup.Name).putClientProperty(prop,java.lang.Boolean.FALSE);

        end

        function removeDocumentTabs(self)




            group=self.ToolGroup.Peer.getWrappedComponent;



            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.SHOW_SINGLE_ENTRY_DOCUMENT_BAR,false);

            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.APPEND_DOCUMENT_TITLE,false);
        end

        function removeViewTab(self)
            group=self.ToolGroup.Peer.getWrappedComponent;

            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.ACCEPT_DEFAULT_VIEW_TAB,false);
        end

        function create2DSliceViews(self)
            self.xySliceView=images.internal.app.volviewToolgroup.Scrollable2DImageSliceView(self.xySliceFig);
            self.xzSliceView=images.internal.app.volviewToolgroup.Scrollable2DImageSliceView(self.xzSliceFig);
            self.yzSliceView=images.internal.app.volviewToolgroup.Scrollable2DImageSliceView(self.yzSliceFig);

            self.xySliceView.hSlider.Tag='xySliceSlider';
            self.xzSliceView.hSlider.Tag='xzSliceSlider';
            self.yzSliceView.hSlider.Tag='yzSliceSlider';
        end

        function createVolumeCanvasViewArea(self)

            hPanel=uipanel('Parent',self.volumeRenderingFig,'BorderType','none');

            self.VolumePanel=hPanel;
            self.Canvas=hg2gcv(hPanel);

        end

        function createVolumeViewCamera(self)

            self.VolumeCamera=matlab.graphics.axis.camera.UniformCamera3D;
            self.VolumeCamera.DepthSort='on';
            self.VolumeCamera.TransparencyMethodHint='objectsort';
            self.VolumeCamera.Parent=self.Canvas;

            set(self.VolumeCamera,'Position',[4,4,2.5],'upvector',[0,0,1],'viewangle',15);

            self.VolumeTransform=hgtransform(self.VolumeCamera);



            self.VolumeCamera.Viewport.Units='pixels';

            self.setCameraViewportPosition();

        end

        function createVolumeRenderingView(self)
            dummyVol=zeros(3,3,3,'uint8');
            self.volumeRenderingView=images.internal.app.volviewToolgroup.VolumeRenderer(self.VolumeCamera,self.VolumeTransform,...
            self.Canvas,dummyVol);
        end

        function create3DSliceView(self)
            dummySlice=zeros(3,3);
            self.slicePlane3DViewer=images.internal.app.volviewToolgroup.SlicePlane3DViewer(self.VolumeTransform,dummySlice,dummySlice,dummySlice);
            self.slicePlane3DViewer.XYVisible='off';
            self.slicePlane3DViewer.XZVisible='off';
            self.slicePlane3DViewer.YZVisible='off';
        end

        function createVolumeRenderingSettingsView(self)
            self.renderingEditorView=images.internal.app.volviewToolgroup.VolumeRenderingSettingsEditor(self.renderingEditorFigure);
        end

        function getVolumeFromFile(self,volType)

            [filename,userCanceled]=images.internal.app.volviewToolgroup.volgetfile();
            if~userCanceled
                showAsBusy(self);
                self.notify('ImportFromFile',images.internal.app.volviewToolgroup.ImportFromFileEventData(filename,volType));
                unshowAsBusy(self);
            end

        end

        function getVolumeFromDicomFolder(self,volType)

            [directorySelected,userCanceled]=images.internal.app.volviewToolgroup.volgetfolder();
            if~userCanceled
                showAsBusy(self);
                self.notify('ImportFromDicomFolder',images.internal.app.volviewToolgroup.ImportFromDicomFolderEventData(directorySelected,volType));
                unshowAsBusy(self);
            end
        end

        function getVolumeFromWorkspace(self,volType)

            if strcmp(volType,'volume')
                [V,~,variableName,~,userCanceled]=iptui.internal.imgetvar([],4);
            elseif strcmp(volType,'labels')
                [V,~,variableName,~,userCanceled]=iptui.internal.imgetvar([],6);
            else
                assert(true,'Invalid volType in',mfilename);
            end
            if~userCanceled
                showAsBusy(self);
                self.notify('ImportFromWorkspace',images.internal.app.volviewToolgroup.ImportFromWorkspaceEventData(V,variableName,volType));
                unshowAsBusy(self);
            end

        end

        function showAsBusy(self)
            self.ToolGroup.setWaiting(true);
        end

        function unshowAsBusy(self)
            self.ToolGroup.setWaiting(false)
        end

        function displayScaleFactorsWarningDlg(~,messageStr)
            warndlg(messageStr,getString(message('images:volumeViewerToolgroup:scaleFactorsLabeledVolume')));
        end

        function displayFileLoadFailedDlg(~,messageStr)
            errordlg(messageStr,getString(message('images:volumeViewerToolgroup:invalidFile')));
        end

        function displayFolderLoadFailedDlg(~,messageStr)
            errordlg(messageStr,getString(message('images:volumeViewerToolgroup:invalidFolder')));
        end

        function displayVolSizesNotEqualDlg(~,messageStr)
            errordlg(messageStr,getString(message('images:volumeViewerToolgroup:volumeSizesNotEqual')));
        end

        function displayNumLabelsExceededDlg(~,messageStr)
            errordlg(messageStr,getString(message('images:volumeViewerToolgroup:numLabelsExceeded')));
        end

        function displayInvalidSpatialReferencingDlg(~,messageStr)
            errordlg(messageStr,getString(message('images:volumeViewerToolgroup:invalidSpatialReferencing')));
        end

        function launchBackgroundColorDialog(self)

            c=uisetcolor(self.Canvas.Color,getString(message('images:volumeViewerToolgroup:backgroundColorButtonLabel')));
            self.notify('BackgroundColorChange',images.internal.app.volviewToolgroup.BackgroundColorChangeEventData(c));

        end

        function newSessionClick(self)
            buttonName=questdlg(getString(message('images:volumeViewerToolgroup:startNewSession')),...
            getString(message('images:volumeViewerToolgroup:newSessionButtonLabel')),...
            getString(message('images:commonUIString:yes')),...
            getString(message('images:commonUIString:cancel')),...
            getString(message('images:commonUIString:cancel')));

            switch buttonName
            case getString(message('images:commonUIString:cancel'))
                return;
            case getString(message('images:commonUIString:yes'))
                self.notify('StartNewSession');
            end
        end

        function launchExportDialog(~,config)
            export2wsdlg({'Rendering and Camera Configuration'},{'config'},{config});
        end

        function checkReplaceOrOverlay(self,data)
            import images.internal.app.volviewToolgroup.*
            refreshValue=checkReplaceOrOverlay(data);
            self.notify('ReplaceOrOverlayResult',ReplaceOrOverlayResultEventData(refreshValue));
        end

        function setBackgroundColor(self,color)

            self.BackgroundColorButton.Icon=constructColorIconFromRGBTriplet(color);
            self.Canvas.Color=color;

        end

        function enableViewControlsOnDataLoad(self,data)
            self.VolumePanel.Visible='on';

            self.NewSessionButton.Enabled=true;
            self.CustomReferencingButton.Enabled=true;
            self.UniformInWorldButton.Enabled=true;

            self.XAxisLabel.Enabled=true;
            self.YAxisLabel.Enabled=true;
            self.ZAxisLabel.Enabled=true;

            self.XUnitsLabel.Enabled=true;
            self.YUnitsLabel.Enabled=true;
            self.ZUnitsLabel.Enabled=true;

            self.XAxisUnitsEditField.Enabled=true;
            self.YAxisUnitsEditField.Enabled=true;
            self.ZAxisUnitsEditField.Enabled=true;

            self.ShowSlicesToggleButton.Enabled=true;
            self.ShowVolumeToggleButton.Enabled=true;
            self.RestoreDefaultButton.Enabled=true;
            self.BackgroundColorButton.Enabled=true;
            self.ExportButton.Enabled=true;

            self.renderingEditorView.Panel.Visible='on';
            self.orientationAxesView.Panel.Visible='on';

            self.xySliceView.hSlider.Visible='on';
            self.xzSliceView.hSlider.Visible='on';
            self.yzSliceView.hSlider.Visible='on';

            if strcmp(data.VolumeDisplayMode,'volume')
                self.VolumeModeButton.Value=true;
            elseif strcmp(data.VolumeDisplayMode,'labels')
                self.LabelModeButton.Value=true;
                self.renderingEditorView.EmbedLabelsCheckbox.Value=0;
            elseif strcmp(data.VolumeDisplayMode,'mixed')
                self.LabelModeButton.Value=true;
                self.renderingEditorView.EmbedLabelsCheckbox.Value=1;
            end

            if data.HasVolumeData&&data.HasLabeledVolumeData
                self.VolumeModeButton.Enabled=true;
                self.LabelModeButton.Enabled=true;

                self.renderingEditorView.EmbedLabelsCheckbox.Enable='on';
            elseif data.HasVolumeData
                self.VolumeModeButton.Enabled=true;
                self.LabelModeButton.Enabled=false;
                self.renderingEditorView.EmbedLabelsCheckbox.Enable='off';

            elseif data.HasLabeledVolumeData
                self.VolumeModeButton.Enabled=false;
                self.LabelModeButton.Enabled=true;
                self.renderingEditorView.EmbedLabelsCheckbox.Enable='off';
            end

        end

        function disableViewControlsOnNewSession(self)

            self.VolumePanel.Visible='off';
            self.Canvas.Color=self.DefaultCanvasColor;

            self.NewSessionButton.Enabled=false;
            self.CustomReferencingButton.Enabled=false;
            self.UniformInWorldButton.Enabled=false;

            self.XAxisLabel.Enabled=false;
            self.YAxisLabel.Enabled=false;
            self.ZAxisLabel.Enabled=false;

            self.XUnitsLabel.Enabled=false;
            self.YUnitsLabel.Enabled=false;
            self.ZUnitsLabel.Enabled=false;

            self.XAxisUnitsEditField.Enabled=false;
            self.YAxisUnitsEditField.Enabled=false;
            self.ZAxisUnitsEditField.Enabled=false;

            self.ShowSlicesToggleButton.Enabled=false;
            self.ShowVolumeToggleButton.Enabled=false;
            self.RestoreDefaultButton.Enabled=false;
            self.BackgroundColorButton.Enabled=false;
            self.ExportButton.Enabled=false;




            self.renderingEditorView.Panel.Visible='off';
            self.orientationAxesView.Panel.Visible='off';

            self.xySliceView.hSlider.Visible='off';
            self.xzSliceView.hSlider.Visible='off';
            self.yzSliceView.hSlider.Visible='off';
            self.xySliceView.hIm.CData=[];
            self.yzSliceView.hIm.CData=[];
            self.xzSliceView.hIm.CData=[];

            self.VolumeModeButton.Enabled=false;
            self.LabelModeButton.Enabled=false;
            self.VolumeModeButton.Value=false;
            self.LabelModeButton.Value=false;

        end

        function set.VolumeMode(self,mode)
            str=validatestring(mode,{'volume','mip','iso','labels','mixed'});

            switch str
            case 'volume'
                self.ShowVolumeToggleButton.Icon=self.VolIcon;
                self.ShowVolumeToggleButton.Text=getString(message('images:volumeViewerToolgroup:viewVolumeButtonLabel'));

                self.renderingEditorView.IsosurfacePanel.Visible='off';
                self.renderingEditorView.LabelVolumeRenderingPanel.Visible='off';
                self.renderingEditorView.VolumeRenderingPanel.Visible='on';
                self.renderingEditorView.LightingToggle.Visible='on';

            case 'mip'
                self.ShowVolumeToggleButton.Icon=self.VolIcon;
                self.ShowVolumeToggleButton.Text=getString(message('images:volumeViewerToolgroup:viewVolumeButtonLabel'));

                self.renderingEditorView.IsosurfacePanel.Visible='off';
                self.renderingEditorView.LabelVolumeRenderingPanel.Visible='off';
                self.renderingEditorView.VolumeRenderingPanel.Visible='on';
                self.renderingEditorView.LightingToggle.Visible='off';

            case 'iso'
                self.ShowVolumeToggleButton.Icon=self.VolIcon;
                self.ShowVolumeToggleButton.Text=getString(message('images:volumeViewerToolgroup:viewVolumeButtonLabel'));

                self.renderingEditorView.IsosurfacePanel.Visible='on';
                self.renderingEditorView.LabelVolumeRenderingPanel.Visible='off';
                self.renderingEditorView.VolumeRenderingPanel.Visible='off';
                self.renderingEditorView.LightingToggle.Visible='off';

            case 'labels'
                self.ShowVolumeToggleButton.Icon=self.LabelVolIcon;
                self.ShowVolumeToggleButton.Text=getString(message('images:volumeViewerToolgroup:viewLabelsButtonLabel'));

                self.renderingEditorView.IsosurfacePanel.Visible='off';
                self.renderingEditorView.VolumeRenderingPanel.Visible='off';
                self.renderingEditorView.LabelVolumeRenderingPanel.Visible='on';

                self.renderingEditorView.LabelMode='labels';

            case 'mixed'
                self.ShowVolumeToggleButton.Icon=self.LabelVolIcon;
                self.ShowVolumeToggleButton.Text=getString(message('images:volumeViewerToolgroup:viewLabelsButtonLabel'));

                self.renderingEditorView.IsosurfacePanel.Visible='off';
                self.renderingEditorView.VolumeRenderingPanel.Visible='off';
                self.renderingEditorView.LabelVolumeRenderingPanel.Visible='on';

                self.renderingEditorView.LabelMode='mixed';
            end
        end

    end

end

function icon=constructColorIconFromRGBTriplet(rgbColor)

    iconImage=zeros(24,24,3);
    iconImage(:,:,1)=rgbColor(1);
    iconImage(:,:,2)=rgbColor(2);
    iconImage(:,:,3)=rgbColor(3);
    icon=matlab.ui.internal.toolstrip.Icon(im2uint8(iconImage));

end

