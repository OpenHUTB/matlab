classdef BrowserView<handle


    properties(Access=private)
DICOMTab
ExportButtons
SeriesContextMenu

hFig
hStudyTable
hSeriesTable
hThumbnailPanel
hHelpTextPanel
hHelpTextControl

Thumbnails
    end

    properties(Transient=true)
ToolGroup
    end

    properties(Access=private)
StudyDetails
SeriesDetails

StudyIndex
SeriesIndex

OriginalWarningState

EmptyThumbnailListener
CorruptThumbnailListener
ThumbnailVolumeLoadListener
ThumbnailSuccessListener
    end

    events
ImportFromDicomFolder
ImportFromWorkspace
SendToVideoViewer
SendToVolumeViewer
SendVolumeToWorkspace
SendTableToWorkspace
ViewStudySelection
ViewSeriesSelection
BackgroundVolumeLoad
    end

    methods
        function obj=BrowserView()
            import matlab.ui.internal.toolstrip.*

            appName=message('images:DICOMBrowser:appName').getString();
            obj.ToolGroup=matlab.ui.internal.desktop.ToolGroup(appName);


            images.internal.app.utilities.addDDUXLogging(obj.ToolGroup,'Image Processing Toolbox','DICOM Browser');


            obj.ToolGroup.setContextualHelpCallback(@(es,ed)doc('DICOM Browser'));

            obj.ToolGroup.setWaiting(true)

            obj.createToolstrip()
            obj.createDocumentArea()
            obj.ToolGroup.disableDataBrowser()

            obj.ToolGroup.open()
            obj.disableFigureClosing()
            obj.ToolGroup.setWaiting(false)
            internal.setJavaCustomData(obj.ToolGroup.Peer,obj)
        end

        function delete(obj)
            if~isempty(obj.Thumbnails)&&isvalid(obj.Thumbnails)
                delete(obj.Thumbnails)
            end

            if~isempty(obj.ToolGroup)&&isvalid(obj.ToolGroup)
                delete(obj.ToolGroup)
            end
        end

        function updateViewer(obj,evtData)
            obj.StudyDetails=evtData.StudyDetails;
            obj.SeriesDetails=evtData.SeriesDetails;


            obj.clearThumbnails()
            obj.clearSeriesTable()
            obj.clearStudyTable()


            obj.hStudyTable.Data=prepareTableForUitable(obj.StudyDetails);
            obj.hSeriesTable.Data=prepareTableForUitable(obj.SeriesDetails);
        end

        function updateSeriesTable(obj,seriesDetails)
            obj.SeriesDetails=seriesDetails;
            obj.clearThumbnails()
            obj.clearSeriesTable()
            seriesDetails.Filenames=[];
            obj.hSeriesTable.Data=prepareTableForUitable(seriesDetails);

            if~isempty(obj.SeriesDetails)&&size(obj.SeriesDetails,1)>1
                obj.displaySelectSeriesHelpMessage()
                obj.disableExportButtons()
            else
                obj.hideHelpMessage()
                evtData.Indices=[1,1];
                obj.seriesRowSelected([],evtData)
            end
        end

        function makeResponsive(obj)
            obj.ToolGroup.setWaiting(false)
        end
    end


    methods(Access=private)
        function createToolstrip(obj)
            obj.createDICOMTab()
            obj.removeViewTab()
        end

        function createDICOMTab(obj)
            import matlab.ui.internal.toolstrip.*

            tabgroup=TabGroup();
            obj.DICOMTab=Tab(getString(message('images:DICOMBrowser:browserTabName')));
            tabgroup.add(obj.DICOMTab)
            obj.DICOMTab.Tag='tab_DICOM';
            obj.ToolGroup.addTabGroup(tabgroup)

            obj.createFileSection()
        end

        function createFileSection(obj)
            import matlab.ui.internal.toolstrip.*

            section=obj.DICOMTab.addSection(...
            upper(getString(message('images:DICOMBrowser:fileSection'))));
            section.Tag='sec_file';

            column1=section.addColumn();
            button=SplitButton(getString(message('images:DICOMBrowser:loadFolder')),Icon.IMPORT_24);
            button.Tag='importSplitButton';
            button.Description=getString(message('images:DICOMBrowser:loadFolderDescription'));
            button.ButtonPushedFcn=@(varargin)obj.getCollectionFromFolderName();

            popup=PopupList();
            button.Popup=popup;
            popup.Tag='importButtonPopUp';

            item=ListItem(getString(message('images:DICOMBrowser:loadFromFolder')),Icon.IMPORT_16);
            item.Tag='loadFromFolderItem';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)obj.getCollectionFromFolderName();
            popup.add(item);

            item=ListItem(getString(message('images:DICOMBrowser:importFromWorkspace')),Icon.IMPORT_16);
            item.Tag='loadFromWorkspaceItem';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)obj.getCollectionFromWorkspace();
            popup.add(item)

            column1.add(button)

            column2=section.addColumn();
            button=SplitButton(getString(message('images:DICOMBrowser:exportTo')),Icon.EXPORT_24);
            button.Tag='exportSplitButton';
            button.Description=getString(message('images:DICOMBrowser:exportToDescription'));
            button.ButtonPushedFcn=@(varargin)obj.exportToWorkspace();

            popup=PopupList();
            button.Popup=popup;
            popup.Tag='exportButtonPopUp';

            item=ListItem(getString(message('images:DICOMBrowser:exportToWorkspace')),Icon.EXPORT_16);
            item.Tag='exportToWorkspaceItem';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)obj.exportToWorkspace();
            popup.add(item);

            item=ListItem(getString(message('images:DICOMBrowser:exportToVolumeViewer')),Icon.EXPORT_16);
            item.Tag='exportToVolviewItem';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)obj.exportToVolumeViewer();
            popup.add(item)

            item=ListItem(getString(message('images:DICOMBrowser:exportToVideoViewer')),Icon.EXPORT_16);
            item.Tag='exportToImplayItem';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)obj.exportToVideoViewer();
            popup.add(item)

            column2.add(button)
            obj.ExportButtons=button;
            obj.disableExportButtons()
        end

        function removeViewTab(obj)
            group=obj.ToolGroup.Peer.getWrappedComponent;

            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.ACCEPT_DEFAULT_VIEW_TAB,false);
        end

        function createDocumentArea(obj)
            figureName=getString(message('images:DICOMBrowser:mainDocumentName'));
            obj.hFig=figure('Name',figureName,...
            'Tag','browser',...
            'NumberTitle','off',...
            'IntegerHandle','off',...
            'HandleVisibility','callback');
            obj.ToolGroup.addFigure(obj.hFig);

            leftFraction=0.6;
            topLeftFraction=0.5;

            hLeftPanel=uipanel(obj.hFig,'units','normalized',...
            'position',[0,0,leftFraction,1],...
            'tag','LeftPanel',...
            'title',getString(message('images:DICOMBrowser:tablesPanel')));

            obj.hThumbnailPanel=uipanel(obj.hFig,'units','normalized',...
            'position',[leftFraction,0,1-leftFraction,1],...
            'tag','ImagePanel',...
            'BorderType','none',...
            'title',getString(message('images:DICOMBrowser:thumbnailPanel')));

            obj.hHelpTextPanel=uipanel(obj.hThumbnailPanel,...
            'units','normalized',...
            'position',[0,0,1,1],...
            'BorderType','none',...
            'tag','HelpPanel');
            obj.createHelpTextControl()
            obj.displayStartupHelpMessage()

            hULPanel=uipanel(hLeftPanel,'units','normalized',...
            'position',[0,1-topLeftFraction,1,topLeftFraction],...
            'tag','StudyPanel',...
            'title',getString(message('images:DICOMBrowser:studiesTablePanel')));

            obj.hStudyTable=uitable('parent',hULPanel,...
            'ColumnName',images.internal.app.dicom.getStudyColumnNames(),...
            'Units','normalized',...
            'position',[0,0,1,1],...
            'ColumnEditable',false,...
            'CellSelectionCallback',@(src,evt)obj.studyRowSelected(src,evt),...
            'RearrangeableColumns','on',...
            'Tag','StudyTable');

            hLLPanel=uipanel(hLeftPanel,'units','normalized',...
            'position',[0,0,1,1-topLeftFraction],...
            'tag','LowerLeftPanel',...
            'title',getString(message('images:DICOMBrowser:seriesTablePanel')));

            obj.SeriesContextMenu=uicontextmenu(obj.hFig,...
            'Tag','SeriesTableContextMenu');
            uimenu(obj.SeriesContextMenu,...
            'Label',getString(message('images:DICOMBrowser:exportSeriesContextMenu')),...
            'Callback',@(src,evt)obj.seriesExportContextMenuCallback(src,evt),...
            'Tag','SeriesTableContextMenuItem',...
            'Enable','off');

            obj.hSeriesTable=uitable('parent',hLLPanel,...
            'ColumnName',images.internal.app.dicom.getSeriesColumnNames(),...
            'Units','normalized',...
            'position',[0,0,1,1],...
            'ColumnEditable',false,...
            'CellSelectionCallback',@(src,evt)obj.seriesRowSelected(src,evt),...
            'Tag','SeriesTable',...
            'UIContextMenu',obj.SeriesContextMenu);

            obj.ToolGroup.getFiguresDropTargetHandler.unregisterInterest(obj.hFig)
        end

        function createHelpTextControl(obj)
            obj.hHelpTextControl=uicontrol(...
            'Parent',obj.hHelpTextPanel,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0,0,1,1],...
            'HorizontalAlignment','left',...
            'String','');
        end

        function disableFigureClosing(obj)

            drawnow;
            figureName=getString(message('images:DICOMBrowser:mainDocumentName'));
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
            state=java.lang.Boolean.FALSE;
            md.getClient(figureName,obj.ToolGroup.Name).putClientProperty(prop,state);
        end
    end

    methods(Access=private)
        function clearStudyTable(obj)
            obj.hStudyTable.Data={};
            obj.StudyIndex=[];
            obj.SeriesIndex=[];
        end

        function clearSeriesTable(obj)
            obj.hSeriesTable.Data={};
            obj.SeriesIndex=[];
        end

        function clearThumbnails(obj)
            if~isempty(obj.Thumbnails)
                obj.Thumbnails.Files={};
            end
        end

        function displayThumbnails(obj,filenames)
            if isempty(obj.Thumbnails)
                obj.Thumbnails=images.internal.app.dicom.DICOMThumbnails(obj.hThumbnailPanel);
                obj.hFig.WindowButtonDownFcn=@(varargin)obj.Thumbnails.mouseButtonDownFcn(varargin{:});
                obj.hFig.WindowScrollWheelFcn=@(varargin)obj.scrollWheelFcn(varargin{:});
                obj.hFig.WindowKeyPressFcn=@(varargin)obj.keyPressFcn(varargin{:});

                obj.EmptyThumbnailListener=addlistener(obj.Thumbnails,'EmptyFileRead',@obj.disableExportButtons);
                obj.CorruptThumbnailListener=addlistener(obj.Thumbnails,'FailedFileRead',@obj.disableExportButtons);
                obj.ThumbnailVolumeLoadListener=addlistener(obj.Thumbnails,'FullVolumeLoad',@obj.informModelOfVolume);
                obj.ThumbnailSuccessListener=addlistener(obj.Thumbnails,'SuccessfulFileRead',@obj.enableExportButtons);
            end

            obj.Thumbnails.Files=filenames;
        end

        function setStatusText(obj,newText)
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            f=md.getFrameContainingGroup(obj.ToolGroup.Name);
            if~isempty(f)

                javaMethodEDT('setStatusText',f,newText);
            end
        end

        function displaySelectSeriesHelpMessage(obj)
            obj.hHelpTextControl.String=sprintf(['\n',getString(message('images:DICOMBrowser:selectSeriesHelp'))]);
            obj.hHelpTextPanel.Visible='on';
        end

        function displayStartupHelpMessage(obj)
            obj.hHelpTextControl.String=sprintf(['\n',getString(message('images:DICOMBrowser:startupHelp'))]);
            obj.hHelpTextPanel.Visible='on';
        end

        function hideHelpMessage(obj)
            obj.hHelpTextPanel.Visible='off';
        end
    end


    methods(Access=private)
        function getCollectionFromFolderName(obj)
            obj.OriginalWarningState=warning();
            images.internal.app.dicom.disableDICOMWarnings()
            oc=onCleanup(@()warning(obj.OriginalWarningState));

            obj.ToolGroup.setWaiting(true)
            [directorySelected,userCanceled]=images.internal.app.volview.volgetfolder();
            if~userCanceled
                obj.disableExportButtons()
                obj.setStatusText(getString(message('images:DICOMBrowser:loadingCollection')))
                obj.notify('ImportFromDicomFolder',...
                images.internal.app.dicom.ImportFromDicomFolderEventData(directorySelected))
            end

            obj.setStatusText('')
            obj.ToolGroup.setWaiting(false)
        end

        function getCollectionFromWorkspace(obj)
            [collection,~,~,~,userCanceled]=iptui.internal.imgetvar([],5);
            if~userCanceled
                obj.disableExportButtons()
                obj.notify('ImportFromWorkspace',...
                images.internal.app.dicom.ImportFromWorkspaceEventData(collection));
            end
        end

        function exportToWorkspace(obj)
            obj.ToolGroup.setWaiting(true)
            evtData=images.internal.app.dicom.SelectionEventData(obj.StudyIndex,obj.SeriesIndex);
            obj.notify('SendVolumeToWorkspace',evtData)
        end

        function exportToVolumeViewer(obj)
            obj.ToolGroup.setWaiting(true)
            evtData=images.internal.app.dicom.SelectionEventData(obj.StudyIndex,obj.SeriesIndex);
            obj.notify('SendToVolumeViewer',evtData)
        end

        function exportToVideoViewer(obj)
            obj.ToolGroup.setWaiting(true)
            evtData=images.internal.app.dicom.SelectionEventData(obj.StudyIndex,obj.SeriesIndex);
            obj.notify('SendToVideoViewer',evtData)
        end

        function studyRowSelected(obj,~,evt)
            if~isempty(evt.Indices)
                selectedRow=evt.Indices(1);
            else
                return
            end

            if selectedRow==obj.StudyIndex
                return
            end

            obj.disableExportButtons()
            obj.disableSeriesExportMenu()

            obj.StudyIndex=selectedRow;
            obj.SeriesIndex=[];

            evtData=images.internal.app.dicom.SelectionEventData(obj.StudyIndex,obj.SeriesIndex);
            obj.notify('ViewStudySelection',evtData)
        end

        function seriesRowSelected(obj,~,evt)
            if isempty(evt.Indices)
                return
            end

            selectedRow=evt.Indices(1);
            if selectedRow==obj.SeriesIndex
                return
            end

            obj.hideHelpMessage()

            obj.SeriesIndex=selectedRow;
            evtData=images.internal.app.dicom.SelectionEventData(obj.StudyIndex,obj.SeriesIndex);
            obj.notify('ViewSeriesSelection',evtData)

            thisSeriesDetail=obj.SeriesDetails(selectedRow,:);
            obj.displayThumbnails(thisSeriesDetail.Filenames{1})
        end

        function disableExportButtons(obj,varargin)
            obj.ExportButtons.Enabled=false;
        end

        function disableSeriesExportMenu(obj)
            obj.SeriesContextMenu.Children.Enable='off';
        end

        function enableExportButtons(obj,varargin)
            obj.ExportButtons.Enabled=true;
            obj.SeriesContextMenu.Children.Enable='on';
        end

        function keyPressFcn(obj,src,evt)
            if isa(src.CurrentObject,'matlab.graphics.axis.Axes')&&isequal(src.CurrentObject.Tag,'griddedAxes')
                obj.Thumbnails.keyPressFcn(src,evt)
            end
        end

        function scrollWheelFcn(obj,src,evt)
            if isa(src.CurrentObject,'matlab.graphics.axis.Axes')&&isequal(src.CurrentObject.Tag,'griddedAxes')
                obj.Thumbnails.mouseWheelFcn(src,evt);
            end
        end

        function informModelOfVolume(obj,~,evt)
            obj.notify('BackgroundVolumeLoad',evt)
        end

        function seriesExportContextMenuCallback(obj,src,evt)
            if isempty(obj.SeriesIndex)
                return
            end

            evtData=images.internal.app.dicom.SelectionEventData(obj.StudyIndex,obj.SeriesIndex);
            obj.notify('SendTableToWorkspace',evtData)
        end
    end
end


function outCell=prepareTableForUitable(inTable)

    outCell=table2cell(inTable);
    outCell=cellfun(@cellPrepHelper,outCell,'uniformoutput',false);

end


function out=cellPrepHelper(in)

    if isstring(in)
        out=char(in);
    elseif isdatetime(in)
        out=datestr(in);
    else
        out=in;
    end
end
