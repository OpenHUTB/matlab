classdef BrowserView<handle




    properties(Access={
        ?uitest.factory.Tester,...
        ?images.internal.app.dicomJT.DICOMBrowser})

        App matlab.ui.container.internal.AppContainer;
    end

    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)

hFig
hThumbnailPanel
        hBrowser images.internal.app.browser.Browser


Tabgroup
DICOMTab


FileSection


ImportButton
ExportButton


SeriesContextMenu


hStudyTable
hSeriesTable


hHelpTextControl
helpMessageGrid


ImportFromWSDlg


ExportToWsDlg
    end

    properties(Access=private)
StudyDetails
SeriesDetails

StudyIndex
SeriesIndex


        FullVolume=[];
        Colormap=[]


        hPanelSize=[];


        hoverOnThumbnail logical=false

OriginalWarningState
        BrokenPlaceholder=imread(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+browser','+icons','BrokenPlaceholder_100.png'));
    end

    events
ImportFromDicomFolder
ImportFromWorkspace
SendToVideoViewer
SendToVolumeViewer
SendVolumeToWorkspace
SendTableToWorkspace
SendImageToWorkspace
ViewStudySelection
ViewSeriesSelection
FullVolumeLoad
    end

    methods
        function obj=BrowserView()
            import matlab.ui.internal.toolstrip.*

            obj.createContainer()

            obj.App.Busy=true;

            obj.createToolstrip()
            obj.createDocumentArea()

            obj.App.Visible=true;
            obj.App.Busy=false;
        end

        function delete(obj)
            if~isempty(obj.hBrowser)&&isvalid(obj.hBrowser)
                delete(obj.hBrowser)
            end

            if~isempty(obj.App)&&isvalid(obj.App)
                delete(obj.App)
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
            obj.App.Busy=false;
        end

        function export2wsdlg(obj,varName,labelMsg,var)
            loc=imageslib.internal.app.utilities.ScreenUtilities.getToolCenter(obj.App);
            obj.ExportToWsDlg=images.internal.app.utilities.ExportToWorkspaceDialog(loc,...
            'Export To Workspace',varName,labelMsg);

            wait(obj.ExportToWsDlg);

            if~obj.ExportToWsDlg.Canceled
                for idx=1:numel(varName)
                    if obj.ExportToWsDlg.VariableSelected(idx)
                        assignin('base',obj.ExportToWsDlg.VariableName(idx),var{idx});
                    end
                end
            end

            delete(obj.ExportToWsDlg);
        end

        function errorDlg(obj,msg)
            dialogTitle=getString(message('images:DICOMBrowser:errorDialogTitle'));
            uialert(obj.App,msg,dialogTitle)
        end
    end


    methods(Access=private)
        function createContainer(obj)

            options.Product="Image Processing Toolbox";
            options.Scope="DICOM Browser";
            options.Title=getString(message('images:DICOMBrowser:appName'));

            obj.App=matlab.ui.container.internal.AppContainer(options);
        end

        function createToolstrip(obj)
            import matlab.ui.internal.toolstrip.*


            obj.Tabgroup=TabGroup();
            obj.Tabgroup.Tag="DICOMTab";
            obj.App.add(obj.Tabgroup);


            obj.DICOMTab=Tab(getString(message('images:DICOMBrowser:browserTabName')));
            obj.DICOMTab.Tag='tab_DICOM';


            obj.FileSection=obj.DICOMTab.addSection(...
            upper(getString(message('images:DICOMBrowser:fileSection'))));
            obj.FileSection.Tag='File';


            getImportButton(obj)
            getExportButton(obj)
            obj.Tabgroup.add(obj.DICOMTab);

            obj.disableExportButtons()






            qabbtn=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            qabbtn.ButtonPushedFcn=@(varargin)doc('dicomBrowser');
            obj.App.add(qabbtn);
        end

        function createDocumentArea(obj)


            options.Tag=getString(message('images:DICOMBrowser:mainDocumentName'));
            options.Title=getString(message('images:DICOMBrowser:mainDocumentName'));
            group=matlab.ui.internal.FigureDocumentGroup(options);
            obj.App.add(group);


            options.DocumentGroupTag=options.Tag;
            document=matlab.ui.internal.FigureDocument(options);
            document.Closable=false;
            obj.App.add(document);

            obj.hFig=document.Figure;
            obj.hFig.Name=getString(message('images:DICOMBrowser:mainDocumentName'));
            obj.hFig.Tag="browser";
            obj.hFig.HandleVisibility='callback';


            panelGrid=uigridlayout(obj.hFig,[1,2]);
            panelGrid.ColumnWidth={'0.6x','0.4x'};

            hLeftPanel=uipanel(panelGrid,...
            'tag','LeftPanel',...
            'title',getString(message('images:DICOMBrowser:tablesPanel')));
            obj.hThumbnailPanel=uipanel(panelGrid,...
            'tag','ImagePanel',...
            'BorderType','none',...
            'title',getString(message('images:DICOMBrowser:thumbnailPanel')));


            obj.helpMessageGrid=uigridlayout(obj.hThumbnailPanel,[1,1]);
            obj.hHelpTextControl=uitextarea(...
            'Parent',obj.helpMessageGrid,...
            'HorizontalAlignment','left',...
            'Value','',...
            'Editable','off');
            obj.displayStartupHelpMessage()


            leftPanelGrid=uigridlayout(hLeftPanel,[2,1]);
            leftPanelGrid.RowHeight={'0.5x','0.5x'};
            hULPanel=uipanel(leftPanelGrid,...
            'tag','StudyPanel',...
            'title',getString(message('images:DICOMBrowser:studiesTablePanel')));

            studyTableGrid=uigridlayout(hULPanel,[1,1]);
            obj.hStudyTable=uitable('parent',studyTableGrid,...
            'ColumnName',images.internal.app.dicom.getStudyColumnNames(),...
            'ColumnEditable',false,...
            'CellSelectionCallback',@(src,evt)obj.studyRowSelected(src,evt),...
            'Tag','StudyTable',...
            'Multiselect','off',...
            'SelectionType','row',...
            'ColumnSortable',[true,true,true,true,false,true]);

            hLLPanel=uipanel(leftPanelGrid,...
            'tag','LowerLeftPanel',...
            'title',getString(message('images:DICOMBrowser:seriesTablePanel')));

            obj.SeriesContextMenu=uicontextmenu(obj.hFig,...
            'Tag','SeriesTableContextMenu');
            uimenu(obj.SeriesContextMenu,...
            'Label',getString(message('images:DICOMBrowser:exportSeriesContextMenu')),...
            'Callback',@(src,evt)obj.seriesExportContextMenuCallback(src,evt),...
            'Tag','SeriesTableContextMenuItem',...
            'Enable','off');

            seriesTableGrid=uigridlayout(hLLPanel,[1,1]);
            obj.hSeriesTable=uitable('parent',seriesTableGrid,...
            'ColumnName',images.internal.app.dicom.getSeriesColumnNames(),...
            'ColumnEditable',false,...
            'CellSelectionCallback',@(src,evt)obj.seriesRowSelected(src,evt),...
            'Tag','SeriesTable',...
            'UIContextMenu',obj.SeriesContextMenu,...
            'Multiselect','off',...
            'SelectionType','row',...
            'ColumnSortable',[true,true,true,true,false,true]);
        end
    end


    methods(Access=private)

        function getImportButton(obj)
            import matlab.ui.internal.toolstrip.*

            importColumn=obj.FileSection.addColumn();
            obj.ImportButton=SplitButton(getString(message('images:DICOMBrowser:loadFolder')),Icon.IMPORT_24);
            obj.ImportButton.Tag='importSplitButton';
            obj.ImportButton.Description=getString(message('images:DICOMBrowser:loadFolderDescription'));
            obj.ImportButton.ButtonPushedFcn=@(varargin)obj.getCollectionFromFolderName();


            popup=PopupList();
            popup.Tag='importButtonPopUp';
            obj.ImportButton.Popup=popup;



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


            importColumn.add(obj.ImportButton)
        end


        function getExportButton(obj)
            import matlab.ui.internal.toolstrip.*

            exportColumn=obj.FileSection.addColumn();
            obj.ExportButton=SplitButton(getString(message('images:DICOMBrowser:exportTo')),Icon.EXPORT_24);
            obj.ExportButton.Tag='exportSplitButton';
            obj.ExportButton.Description=getString(message('images:DICOMBrowser:exportToDescription'));
            obj.ExportButton.ButtonPushedFcn=@(varargin)obj.exportToWorkspace();


            popup=PopupList();
            popup.Tag='exportButtonPopUp';
            obj.ExportButton.Popup=popup;



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

            exportColumn.add(obj.ExportButton)
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
            if~isempty(obj.hBrowser)&&isvalid(obj.hBrowser)
                obj.hBrowser.clear();
            end
        end

        function displayThumbnails(obj,filenames)
            if isempty(obj.hBrowser)
                obj.hThumbnailPanel.AutoResizeChildren='off';
                obj.hThumbnailPanel.SizeChangedFcn=@obj.panelSizeChanged;

                thumbNailSize=images.internal.app.dicom.thumbnailSize();
                obj.hBrowser=images.internal.app.browser.Browser(obj.hThumbnailPanel,[1,1,obj.hThumbnailPanel.InnerPosition(3:4)]);
                obj.hBrowser.ThumbnailSize=thumbNailSize;
                obj.hBrowser.LabelVisible=true;


                addlistener(obj.hFig,'WindowMouseMotion',@(varargin)obj.motionCallback(varargin{:}));
                addlistener(obj.hFig,'WindowScrollWheel',@(varargin)obj.scrollWheelFcn(varargin{:}));
                addlistener(obj.hFig,'KeyPress',@(varargin)obj.keyPressFcn(varargin{:}));
                obj.hFig.KeyPressFcn=@(varargin)[];

                menu=uicontextmenu('Parent',obj.hFig);
                uimenu(menu,'Text',getString(message("images:commonUIString:exportToWS")),'MenuSelectedFcn',@(varargin)obj.exportSelected(varargin{:}));
                obj.hBrowser.ContextMenu=menu;
            end

            obj.updateFiles(filenames);
        end

        function updateFiles(obj,files)

            obj.clearThumbnails();

            obj.clearVolume();

            files=convertToString(files);

            obj.loadVolume(files);


            if~isempty(obj.FullVolume)
                files=obj.FullVolume;
            end
            files=convertToCell(files);


            obj.hBrowser.ReadFcn=@obj.readFcn;

            obj.hBrowser.add(files);

            obj.hBrowser.select(1);
        end

        function clearVolume(obj)
            obj.FullVolume=[];
            obj.Colormap=[];
        end

        function loadVolume(obj,filenames)
            obj.OriginalWarningState=warning();
            images.internal.app.dicom.disableDICOMWarnings()
            oc=onCleanup(@()warning(obj.OriginalWarningState));

            if numel(filenames)==1

                try
                    [im,map]=dicomread(filenames);
                    obj.Colormap=map;
                    if size(im,4)>1

                        obj.FullVolume=im;


                        file=images.internal.dicom.DICOMFile(filenames);
                        spatialDetails=images.internal.dicom.getSpatialDetailsForMultiframe(file);
                        sliceDim=images.internal.dicom.findSortDimension(spatialDetails.PatientPositions);

                        evtData=images.internal.app.dicom.LoadVolumeEventData(obj.FullVolume,...
                        spatialDetails,sliceDim,obj.Colormap);
                        notify(obj,'FullVolumeLoad',evtData)
                    end
                catch

                end
            end
        end

        function[im,label,badge,userData]=readFcn(obj,source)
            obj.OriginalWarningState=warning();
            images.internal.app.dicom.disableDICOMWarnings()
            oc=onCleanup(@()warning(obj.OriginalWarningState));

            try
                if isnumeric(source)

                    im=source;
                    if~isempty(obj.Colormap)

                        im=ind2rgb(im,obj.Colormap);
                    end
                    label="";
                    userData.ClassUnderlying=string(class(source));
                    userData.OriginalSize=size(source);
                    enableExportButtons(obj);

                elseif ischar(source)||(isstring(source)&&numel(source)==1)

                    [im,map]=dicomread(source);
                    if~isempty(map)

                        im=ind2rgb(im,map);
                    end


                    [~,fileName]=fileparts(source);
                    label=string(fileName);

                    if isempty(im)

                        im=obj.BrokenPlaceholder;
                        userData.ClassUnderlying=string(class(im));
                        userData.OriginalSize=size(im);
                        disableExportButtons(obj);
                    else
                        userData.ClassUnderlying="";
                        userData.OriginalSize=[];
                        enableExportButtons(obj);
                    end
                end
            catch

                im=obj.BrokenPlaceholder;
                label="";
                userData=struct();
                disableExportButtons(obj);
            end

            if size(im,3)==1

                im=repmat(im,[1,1,3]);
            end


            if~isa(im,'uint8')



                im=uint8(rescale(im,0,255));
            end

            badge=images.internal.app.browser.data.Badge.Empty;

        end

        function displaySelectSeriesHelpMessage(obj)
            obj.hHelpTextControl.Value=sprintf(['\n',getString(message('images:DICOMBrowser:selectSeriesHelp'))]);
            obj.helpMessageGrid.Visible='on';
            obj.hHelpTextControl.Visible='on';
        end

        function displayStartupHelpMessage(obj)
            obj.hHelpTextControl.Value=sprintf(['\n',getString(message('images:DICOMBrowser:startupHelp'))]);
            obj.helpMessageGrid.Visible='on';
            obj.hHelpTextControl.Visible='on';
        end

        function hideHelpMessage(obj)
            obj.helpMessageGrid.Visible='off';
            obj.hHelpTextControl.Visible='off';
        end
    end


    methods(Access=private)
        function getCollectionFromFolderName(obj)
            obj.OriginalWarningState=warning();
            images.internal.app.dicom.disableDICOMWarnings()
            oc=onCleanup(@()warning(obj.OriginalWarningState));

            obj.App.Busy=true;
            [directorySelected,userCanceled]=images.internal.app.volview.volgetfolder();
            obj.App.Busy=false;
            if~userCanceled
                obj.disableExportButtons()
                dlg=uiprogressdlg(obj.App,'Message',getString(message('images:DICOMBrowser:loadingCollection')),'Indeterminate','on');
                obj.notify('ImportFromDicomFolder',...
                images.internal.app.dicom.ImportFromDicomFolderEventData(directorySelected))
                close(dlg);
            end
        end

        function getCollectionFromWorkspace(obj)
            dlgLoc=imageslib.internal.app.utilities.ScreenUtilities.getToolCenter(obj.App);
            obj.ImportFromWSDlg=images.internal.app.utilities.VariableDialog(dlgLoc,...
            getString(message('images:DICOMBrowser:importFromWorkspace')),...
            getString(message('images:DICOMBrowser:dicomCollection')),'dicomCollection');
            obj.ImportFromWSDlg.wait();
            if~obj.ImportFromWSDlg.Canceled
                obj.disableExportButtons()
                collection=evalin('base',obj.ImportFromWSDlg.SelectedVariable);
                obj.notify('ImportFromWorkspace',...
                images.internal.app.dicom.ImportFromWorkspaceEventData(collection));
            end
        end

        function exportToWorkspace(obj)
            obj.App.Busy=true;
            evtData=images.internal.app.dicom.SelectionEventData(obj.StudyIndex,obj.SeriesIndex);
            obj.notify('SendVolumeToWorkspace',evtData)
        end

        function exportToVolumeViewer(obj)
            obj.App.Busy=true;
            evtData=images.internal.app.dicom.SelectionEventData(obj.StudyIndex,obj.SeriesIndex);
            obj.notify('SendToVolumeViewer',evtData)
        end

        function exportToVideoViewer(obj)
            obj.App.Busy=true;
            evtData=images.internal.app.dicom.SelectionEventData(obj.StudyIndex,obj.SeriesIndex);
            obj.notify('SendToVideoViewer',evtData)
        end

        function exportSelected(obj,~,~)

            files=obj.hBrowser.Sources(obj.hBrowser.Selected);
            evt=images.internal.app.dicomJT.ExportSelectionEventData(files);
            notify(obj,'SendImageToWorkspace',evt)
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
            obj.ExportButton.Enabled=false;
        end

        function disableSeriesExportMenu(obj)
            obj.SeriesContextMenu.Children.Enable='off';
        end

        function enableExportButtons(obj,varargin)
            obj.ExportButton.Enabled=true;
            obj.SeriesContextMenu.Children.Enable='on';
        end

        function panelSizeChanged(obj,~,~)
            oldUnits=obj.hThumbnailPanel.Units;
            obj.hThumbnailPanel.Units='pixels';
            newSize=obj.hThumbnailPanel.InnerPosition;
            obj.hThumbnailPanel.Units=oldUnits;
            if(isequal(obj.hPanelSize,newSize))

                return;
            end
            obj.hPanelSize=newSize;
            resize(obj.hBrowser,[1,1,newSize(3:4)]);
        end

        function keyPressFcn(obj,src,evt)
            if isvalid(src.CurrentObject)...
                &&isa(src.CurrentObject.Parent,'matlab.graphics.axis.Axes')...
                &&isequal(src.CurrentObject.Parent.Tag,'ImageAxes')

                images.internal.app.browser.helper.keyPressCallback(obj.hBrowser,evt)
            end
        end

        function scrollWheelFcn(obj,~,evt)
            if obj.hoverOnThumbnail

                scroll(obj.hBrowser,evt.VerticalScrollCount);
            end
        end

        function motionCallback(obj,~,evt)
            obj.hoverOnThumbnail=false;
            if(isa(evt.HitObject,'matlab.ui.container.Panel')&&...
                isequal(evt.HitObject.Tag,'ScrollablePanel'))||...
                (isa(evt.HitObject.Parent,'matlab.graphics.axis.Axes')&&...
                isequal(evt.HitObject.Parent.Tag,'ImageAxes'))


                obj.hoverOnThumbnail=true;
            end
        end

        function seriesExportContextMenuCallback(obj,~,~)
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


function out=convertToCell(files)
    if isstring(files)||ischar(files)

        out=cellstr(string(files));
    elseif isnumeric(files)

        out=num2cell(files,[1,2,3]);
    end
end


function out=convertToString(in)

    if isstring(in)
        out=in;
    else
        out=string(in);
    end
end