



classdef Display<vision.internal.uitools.AppFig

    properties(SetAccess=protected,GetAccess=public)
        ShowLabel=true;
        SignalType vision.labeler.loading.SignalType
    end

    properties(SetAccess=protected)
UndoRedoManagerShape
Clipboard
PixelClipboard

        UserIsDrawing=false;
CachedMode
        FreezeROIDrawing=false;
        InPixelMode=false;
    end

    properties(Access=protected)
LabeledVideoUIObj

AxesHandle
Image
ImageHandle
Toolbar
ToolbarSelectionEventObject
ToolbarButtonChangedCallback
PasteROIMenuCallback
PastePixelROIMenuCallback
CopyPixelROIMenuCallback
CopyDisplayNameCallbackForPixelROI
CutPixelROIMenuCallback
DeletePixelROIMenuCallback


MultiShapeLabelers
RectangleLabeler
PixelLabeler
LineLabeler
PolygonLabeler
ProjCuboidLabeler
CuboidLabeler
Line3DLabeler
CurrentLabeler
VoxelLabeler

CurrentDisplayIndex

LabelingMode
        Mode='none';

SelectedFrameLabel
OrigFigUnit
ImagePanel
ContextMenuCache

StaticROIs


        WasImageLastHitObject=false;
        WasScrubberLastHitObject=false;




        MouseMotionHitObject=[];
    end

    properties(Access=private)
        IsAppClosing=false;
    end

    properties(Constant)
        YELLOW=[1,1,0];
        GRAY=[0.6627,0.6627,0.6627];
        BORDER_COLOR=[0.0667,0.2902,0.5294];
        BORDER_WIDTH=2;
    end

    properties(Abstract)
        IsCuboidSupported;
        IsPixelSupported;
    end

    properties(Abstract,Dependent,Access=protected)
ShapeLabelers
SupprtedLabelers
    end

    events
ROIsChanged
ROISelected
FreezeSignalNav
UnfreezeSignalNav
DisplayClosing

VoxelROIsChanged
    end

    methods(Abstract)
        configure(this,varargin);
    end

    methods(Abstract,Access=protected)
        initialize(this);
        drawImage(this,data);
    end

    methods(Access=private)

        function modeOut=readjustROImode(this,mode,selectedItemInfo)
            if strcmpi(mode,'ROI')
                isModeReadyForROI=getModeFromSelectedItem(this,selectedItemInfo);
                if isModeReadyForROI
                    modeOut='ROI';
                else
                    modeOut='none';
                end
            else
                modeOut=mode;
            end
        end


        function tf=isTheLabelROI(this,roi,labelName)

            tf=false;




            copiedData=this.ShapeLabelers.getCopiedData(roi);
            ud=copiedData.UserData;
            if strcmp(copiedData.Tag,labelName)&&isempty(ud{2})&&isempty(ud{3})
                tf=true;
            end
        end


        function tf=isASublabelROIOfTheLabel(this,roi,labelName)

            tf=false;




            copiedData=this.ShapeLabelers.getCopiedData(roi);
            ud=copiedData.UserData;
            if~strcmp(copiedData.Tag,labelName)&&strcmp(ud{2},labelName)
                tf=true;
            end
        end

        function highlightSelectedROIsColor(this,oldColor,newColor)
            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                for n=1:numel(thisLabeler.CurrentROIs)
                    if thisLabeler.CurrentROIs{n}.Selected
                        if isequal(thisLabeler.CurrentROIs{n}.SelectedColor,oldColor)
                            thisLabeler.CurrentROIs{n}.SelectedColor=newColor;
                        end
                    end
                end
            end
        end

    end

    methods

        function this=Display(hFig,nameDisplayedInTab)

            this=this@vision.internal.uitools.AppFig(hFig,nameDisplayedInTab,true);


            this.Clipboard=vision.internal.labeler.tool.ROILabelerClipBoard();




            this.Fig.HandleVisibility='off';
            set(this.Fig,'CloseRequestFcn',@this.cbDisplayClosing);
            initialize(this);
        end


        function removeLabelFromCopyClipboard(this,labelName)
            for idx=1:length(this.Clipboard.CopiedROIs)

                if strcmpi(this.Clipboard.CopiedROIs{idx}.Label,labelName)
                    this.Clipboard.CopiedROIs{idx}=[];
                end
            end
        end


        function refreshClipboard(this)
            this.Clipboard.refresh();
        end


        function renameLabelInClipboard(this,newItemInfo,oldItemInfo)
            this.Clipboard.rename(newItemInfo,oldItemInfo);
        end


        function colorChangeInClipboard(this,newItemInfo,oldItemInfo)
            this.Clipboard.colorChange(newItemInfo,oldItemInfo);
        end



        function roiVisibilityChangeInClipboard(this,newItemInfo)
            this.Clipboard.roiVisibilityChange(newItemInfo);
        end


        function renameAttribInClipboard(~,~,~)



        end

        function deletePixelLabelData(~,~)




        end


        function doMoveMultipleROI(this,varargin)
            this.MultiShapeLabelers.doMoveMultipleROI(this.ShapeLabelers,size(this.ImageHandle.CData),varargin{:});
        end


        function addSource(this,displayName,customSource)


            hideHelperText(this);


            wipeROIs(this);

            createImage(this,[]);


            for i=1:numel(this.SupprtedLabelers)
                attachToImage(this.SupprtedLabelers(i),this.Fig,this.AxesHandle,this.ImageHandle);
            end





            displayVideoName(this,displayName,customSource);


            this.resetUndoRedoBuffer();
        end


        function setLabelVisiblity(this,val)
            for i=1:numel(this.ShapeLabelers)
                this.ShapeLabelers(i).LabelVisible=val;
            end







            if strcmp(val,'on')
                this.ShowLabel=true;
            else
                this.ShowLabel=false;
            end
        end



        function enableDrawing(this)

            if~isempty(this.ImageHandle)&&~isempty(this.Fig)&&...
                ~isempty(this.AxesHandle)&&...
                ~isempty(this.CurrentLabeler)&&isCurrentLabelerSupported(this)

                activate(this.CurrentLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
            end
        end


        function disableDrawing(this)
            if~isempty(this.ImageHandle)&&~isempty(this.Fig)&&...
                ~isempty(this.AxesHandle)&&...
                ~isempty(this.CurrentLabeler)&&isCurrentLabelerSupported(this)


                deactivate(this.CurrentLabeler);
            end
        end


        function setMode(this,toolstripMode,selectedItemInfo)

            if isempty(this.Fig)
                return;
            end




            mode=readjustROImode(this,toolstripMode,selectedItemInfo);

            hasModeChanged=~strcmp(this.Mode,mode);

            this.Mode=mode;

            makeToolbarVisible(this);

            switch mode
            case 'ROI'
                this.unselectToolbarToEnableROI();
                this.enableDrawing();

                if this.isLabelerInitialized
                    toggleAxesToolbarSelected(this.CurrentLabeler,false);
                end
            case{'ZoomIn','ZoomOut','Pan','Rotate'}
                if this.isLabelerInitialized
                    toggleAxesToolbarSelected(this.CurrentLabeler,true);
                end
            case 'none'
                this.disableDrawing();
            end

            if hasModeChanged



                setPointer(this);
            end
        end


        function makeToolbarVisible(this)
            if isequal(this.AxesHandle.Toolbar.Visible,'off')
                this.AxesHandle.Toolbar.Visible='on';
            end
        end


        function setToolbarButtonChangedCallback(this,callback)
            this.ToolbarButtonChangedCallback=callback;
        end


        function tf=hasSameName(this,name)
            tf=strcmp(this.Name,name);
        end


        function displayVideoName(this,name,isCustomSource)


            if~isCustomSource

                [~,name,ext]=fileparts(name);
                name=[name,ext];
            end
            this.setFigureTitle(name);
        end



        function flag=isPanelVisible(this)
            flag=strcmpi(this.Fig.Visible,'on');
        end


        function changeToolbarVisibility(this,visible)
            if visible
                this.AxesHandle.Toolbar.Visible='on';
            else
                this.AxesHandle.Toolbar.Visible='off';
            end
        end


        function unselectToolbarToEnableROI(this)
            if this.isToolbarModeSelected
                switch this.ToolbarSelectionEventObject.Selection.Tag
                case 'pan'
                    pan(this.AxesHandle,'off');
                case{'zoomin','zoomout'}
                    zoom(this.AxesHandle,'off');
                case{'rotate'}
                    rotate3d(this.AxesHandle,'off');
                otherwise


                    this.ToolbarSelectionEventObject.Selection.Value='off';
                end
                if~isempty(this.Image)&&isvalid(this.Image)
                    deselectAxesInteraction(this.Image);
                end
            end
        end


        function TF=isToolbarModeSelected(this)
            if isempty(this.ToolbarSelectionEventObject)
                TF=false;
                return;
            end
            selection=this.ToolbarSelectionEventObject.Selection;
            TF=isequal(selection.Type,'toolbarstatebutton')&&...
            isequal(selection.Value,'on');
        end


        function modeSelection=getModeSelection(this)

            if isempty(this.ImageHandle)
                modeSelection='none';
                return;
            end
            if this.isToolbarModeSelected
                selection=this.ToolbarSelectionEventObject.Selection;
                switch selection.Tag
                case{'pan','CustomPan'}
                    modeSelection='Pan';

                case{'zoomin','CustomZoomIn'}
                    modeSelection='ZoomIn';

                case{'zoomout','CustomZoomOut'}
                    modeSelection='ZoomOut';

                case 'rotate'
                    modeSelection='Rotate';

                otherwise
                    modeSelection='none';
                end
            else
                if this.isLabelerInitialized
                    modeSelection='ROI';
                else
                    modeSelection='none';
                end
            end
        end


        function grabFocus(this)
            if~isempty(this.Fig)&&isvalid(this.Fig)&&strcmpi(this.Fig.Visible,'on')
                figure(this.Fig);
            end
        end


        function resizeFigure(this)
            this.LabeledVideoUIObj.resizeFigureCallback();
        end


        function TF=isLabelerInitialized(this)
            TF=~isempty(this.CurrentLabeler);
        end


        function updateDisplayIndex(this,index)
            this.CurrentDisplayIndex=index;
        end


        function idx=getCurrentDisplayIndex(this)
            idx=this.CurrentDisplayIndex;
        end

        function closeFig(this)
            this.IsAppClosing=true;
            if ishandle(this.Fig)
                close(this.Fig)
            end
        end

        function cbDisplayClosing(this,varargin)

            ed=vision.internal.labeler.tool.display.DisplayEventData(this.Fig,this.IsAppClosing);
            if this.IsAppClosing




                notify(this,'DisplayClosing',ed);

            else

                dlgMessage=vision.getMessage('vision:labeler:CloseDisplayWarning');
                dlgTitle=vision.getMessage('vision:labeler:CloseDisplay');
                yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
                no=vision.getMessage('MATLAB:uistring:popupdialogs:No');

                selection=vision.internal.labeler.handleAlert(this.Fig,'question',dlgMessage,dlgTitle,...
                yes,no,no);

                switch selection
                case 'Yes'




                    notify(this,'DisplayClosing',ed);


                otherwise

                end
            end
        end

        function delete(this)


            if ishandle(this.Fig)

                delete(this.Fig)
            end
        end
    end




    methods

        function[roiNames,parentNames]=convertToParentNames(~,labelNames,sublabelNames)
            roiNames=labelNames;
            parentNames=sublabelNames;

            for i=1:length(sublabelNames)
                if isempty(sublabelNames{i})

                    parentNames{i}='';
                else
                    roiNames{i}=sublabelNames{i};
                    parentNames{i}=labelNames{i};
                end
            end
        end


        function[labelNames,sublabelNames]=convertToSublabelNames(~,roiNames,parentNames)
            labelNames=roiNames;
            sublabelNames=parentNames;

            for i=1:length(parentNames)
                if isempty(parentNames{i})

                    sublabelNames{i}='';
                end
            end
        end




        function drawImageWithInteractiveROIs(this,data)


            wipeROIs(this);



            drawImage(this,data);
            data=overrideShape(this,data);
            drawInteractiveROIs(this,data.Positions,data.LabelNames,data.SublabelNames,data.SelfUIDs,data.ParentUIDs,data.Colors,data.Shapes,data.ROIVisibility);
            drawnow('limitrate');
        end




        function redrawInteractiveROIs(this,data)

            roiPositions=data.Positions;
            labelNames=data.LabelNames;
            sublabelNames=data.SublabelNames;
            selfUIDs=data.SelfUIDs;
            parentUIDs=data.ParentUIDs;

            data=overrideShape(this,data);
            drawInteractiveROIs(this,roiPositions,labelNames,sublabelNames,selfUIDs,parentUIDs,data.Colors,data.Shapes,data.ROIVisibility);

        end





        function drawImageWithStaticROIs(this,data)

            wipeROIs(this);

            drawImage(this,data);

            labelNames=data.LabelNames;
            sublabelNames=data.SublabelNames;
            selfUIDs=data.SelfUIDs;
            parentUIDs=data.ParentUIDs;
            data=overrideShape(this,data);
            drawStaticROIs(this,data.Positions,labelNames,sublabelNames,selfUIDs,parentUIDs,data.Colors,data.Shapes,data.ROIVisibility);



            drawnow('limitrate');
        end




        function replaceStaticROIs(this,data)


            wipeROIs(this);

            labelNames=data.LabelNames;
            sublabelNames=data.SublabelNames;
            selfUIDs=data.SelfUIDs;
            parentUIDs=data.ParentUIDs;
            data=overrideShape(this,data);

            drawInteractiveROIs(this,data.Positions,labelNames,sublabelNames,selfUIDs,parentUIDs,data.Colors,data.Shapes,data.ROIVisibility);
        end


        function sz=sizeofImage(this)
            sz=size(this.ImageHandle.CData);
        end



        function wipeROIs(this)
            for lIdx=1:numel(this.ShapeLabelers)
                this.ShapeLabelers(lIdx).wipeROIs();
            end


            for n=1:numel(this.StaticROIs)
                delete(this.StaticROIs{n});
            end
            this.StaticROIs={};
        end


        function setLabelingMode(this,mode)

            if~isempty(this.LabelingMode)&&this.LabelingMode==mode
                return
            else



                this.LabelingMode=mode;

                if~isempty(this.CurrentLabeler)
                    deactivate(this.CurrentLabeler);
                end

                switch mode
                case labelType.Rectangle
                    this.CurrentLabeler=this.CuboidLabeler;
                    this.InPixelMode=false;

                case labelType.Line
                    this.CurrentLabeler=this.Line3DLabeler;
                    this.InPixelMode=false;

                case labelType.Cuboid
                    this.CurrentLabeler=this.CuboidLabeler;
                    this.InPixelMode=false;

                case lidarLabelType.Voxel
                    this.CurrentLabeler=this.VoxelLabeler;
                    this.InPixelMode=false;
                end

                if~isempty(this.ImageHandle)&&~isempty(this.Fig)&&...
                    ~isempty(this.AxesHandle)&&~isempty(this.CurrentLabeler)
                    activate(this.CurrentLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
                end
            end

        end


        function TF=getUserIsDrawing(this)
            TF=~isempty(this.CurrentLabeler)&&this.CurrentLabeler.UserIsDrawing;
        end


        function updateLabelSelection(this,selectedLabel)

            if isa(selectedLabel,'lidar.internal.labeler.ROILabel')||...
                isa(selectedLabel,'vision.internal.labeler.ROISublabel')


                this.setLabelingMode(selectedLabel.ROI);
                if~isempty(this.CurrentLabeler)
                    this.CurrentLabeler.SelectedLabel=selectedLabel;
                end
            elseif isa(selectedLabel,'vision.internal.labeler.FrameLabel')
                this.SelectedFrameLabel=selectedLabel;
            else
                error('Error: Unknown selectedLabel type.')
            end

        end

        function highlightSelectedROIsToGray(this)
            highlightSelectedROIsColor(this,this.YELLOW,this.GRAY);
        end

        function highlightSelectedROIsToYellow(this)
            highlightSelectedROIsColor(this,this.GRAY,this.YELLOW);
        end

        function unhighlightCurrentROIs(this)

        end


        function deselctAllROIInstances(this)
            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);


                for n=1:numel(thisLabeler.CurrentROIs)
                    if thisLabeler.checkROIValidity(thisLabeler.CurrentROIs{n})
                        if thisLabeler.CurrentROIs{n}.Selected
                            thisLabeler.CurrentROIs{n}.Selected=false;
                        end
                    end
                end
            end
        end


        function changeVisibilitySelectedROI(this,selectedLabelData,selectedItemInfo)
            if isa(selectedLabelData,'lidar.internal.labeler.ROILabel')
                labelName=selectedLabelData.Label;
            else
                labelName=selectedLabelData.Sublabel;
            end

            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                for n=1:numel(thisLabeler.CurrentROIs)
                    thisROI=thisLabeler.CurrentROIs{n};
                    if thisLabeler.checkROIValidity(thisROI)&&...
                        strcmp(labelName,thisROI.Label)
                        thisROI.Visible=~thisROI.Visible;
                    end
                end
            end
            if selectedLabelData.ROIVisibility
                this.Mode='ROI';
            else
                this.Mode='none';
            end
            setMode(this,this.Mode,selectedItemInfo);
        end



        function changeVisibilitySelectedVoxelROI(this,selectedLabelData,selectedItemInfo)
            this.VoxelLabeler.updateVoxelVisibility(selectedLabelData);

            if~isempty(selectedItemInfo.roiItemDataObj)&&...
                strcmp(selectedLabelData.Label,selectedItemInfo.roiItemDataObj.Label)
                this.Mode='ROI';
                if~selectedLabelData.ROIVisibility
                    this.Mode='none';
                end
                setMode(this,this.Mode,selectedItemInfo);
            end

        end


        function tf=isSublabelDef(~,selectedLabel)
            tf=isa(selectedLabel,'vision.internal.labeler.ROISublabel')&&...
            isprop(selectedLabel,'Sublabel')&&~isempty(selectedLabel.Sublabel);
        end


        function tf=isLabelDef(~,selectedLabel)
            tf=isa(selectedLabel,'lidar.internal.labeler.ROILabel')&&...
            isprop(selectedLabel,'Label')&&~isempty(selectedLabel.Label);
        end



        function tf=isSublabelInstance(~,labelName,sublabelName)
            tf=~isempty(labelName)&&~isempty(sublabelName);
        end



        function modifyLabelInstanceSelection(this,selectedLabel)








            numROIInstanceSelected=getNumROIInstanceSelected(this);
            if numROIInstanceSelected==0
                return;
            else
                if numROIInstanceSelected==1
                    roiInfo=getSingleSelectedROIInstanceInfo(this);



                    labelName=roiInfo.LabelName;
                    sublabelName=roiInfo.SublabelName;
                    if isSublabelDef(this,selectedLabel)&&...
                        isLabelInstance(this,labelName,sublabelName)&&...
                        strcmp(parentName(this,selectedLabel),labelName)

                    else
                        deselctAllROIInstances(this);
                    end
                else
                    deselctAllROIInstances(this);
                end
            end
        end


        function allROIs=getCurrentROIs(this)

            allROIs=[];

            for lIdx=1:numel(this.ShapeLabelers)

                shapeROIs=this.ShapeLabelers(lIdx).CurrentROIs;
                isValid=cellfun(@(r)this.ShapeLabelers.checkROIValidity(r),shapeROIs);



                rois=repmat(struct('ID','','ParentUID','','Label',[],'ParentName',[],'Position',[],'Color',[],'Shape',labelType.empty,'ROIVisibility',''),...
                nnz(isValid),1);
                idx=1;
                for n=1:numel(shapeROIs)
                    if isValid(n)
                        currentROI=shapeROIs{n};
                        ud=currentROI.UserData;
                        copiedData=this.ShapeLabelers.getCopiedData(currentROI);

                        rois(idx).ParentUID=ud{3};
                        rois(idx).ID=ud{4};
                        rois(idx).Label=copiedData.Tag;
                        rois(idx).Position=copiedData.Position;
                        rois(idx).Color=copiedData.Color;
                        rois(idx).Shape=this.roishape2enum(ud{1});
                        rois(idx).ParentName=ud{2};
                        rois(idx).ROIVisibility=copiedData.Visible;
                        idx=idx+1;
                    end
                end
                allROIs=[allROIs;rois];%#ok<AGROW>
            end

        end



        function modifyLabelNameInCurrentROIs(this,oldLabelName,newLabelName)
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                for n=1:numel(thisLabeler.CurrentROIs)
                    thisROI=thisLabeler.CurrentROIs{n};
                    if thisLabeler.checkROIValidity(thisROI)
                        if isTheLabelROI(this,thisROI,oldLabelName)




                            copiedData=this.ShapeLabelers.getCopiedData(thisROI);
                            if isempty(thisROI.Label)
                                copiedData.Label='';
                            else
                                copiedData.Label=newLabelName;
                            end
                            copiedData.Tag=newLabelName;
                            this.ShapeLabelers.changeROIProperty(thisROI,copiedData);

                        end
                    end
                end
            end
        end

        function modifyLabelColorInCurrentROIs(this,oldLabelName,newLabelColor)


            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                for n=1:numel(thisLabeler.CurrentROIs)
                    thisROI=thisLabeler.CurrentROIs{n};
                    if thisLabeler.checkROIValidity(thisROI)
                        if isTheLabelROI(this,thisROI,oldLabelName)
                            copiedData=this.ShapeLabelers.getCopiedData(thisROI);
                            copiedData.Color=newLabelColor;
                            this.ShapeLabelers.changeROIProperty(thisROI,copiedData);
                        end

                    end
                end
            end
        end


        function finalize(~)



        end



        function initializePixelLabeler(this)

        end




        function freezeROIDrawingTools(this)
            this.FreezeROIDrawing=true;
        end




        function disableAxis(~)





        end




        function enableAxis(~)





        end




        function unfreezeROIDrawingTools(this)
            this.FreezeROIDrawing=false;
        end



        function highlightBorder(this)
            if~useAppContainer
                this.LabeledVideoUIObj.SignalContainerPanel.BorderWidth=this.BORDER_WIDTH;
                this.LabeledVideoUIObj.SignalContainerPanel.HighlightColor=this.BORDER_COLOR;
            end
        end



        function unhighlightBorder(this)
            if~useAppContainer
                this.LabeledVideoUIObj.SignalContainerPanel.BorderWidth=this.BORDER_WIDTH;
                this.LabeledVideoUIObj.SignalContainerPanel.HighlightColor=this.ColorBeige;
            end
        end
    end




    methods





        function updateVoxelLabelerLookup(this,color,voxelID)
            this.VoxelLabeler.updateVoxelLabelerLookup(color,voxelID);
        end





        function updateVoxelLabelerLookupNewDisplay(this,colorLookupTable)
            this.VoxelLabeler.setColorLookupTable(colorLookupTable);
        end





        function updateVoxelLabelVisibilityDisplay(this,voxelLabelVisibility)
            this.VoxelLabeler.setLabelVisibility(voxelLabelVisibility);
        end



        function setLabelMatrixFilename(this,fullfilename)
            setLabelMatrixFilename(this.VoxelLabeler,fullfilename);
        end

    end




    methods


        function configureCutCallback(this,cutCallback)


            for lIdx=1:numel(this.ShapeLabelers)
                this.ShapeLabelers(lIdx).addCutCallback(cutCallback);
            end
        end


        function configureCopyCallback(this,copyCallback)


            for lIdx=1:numel(this.ShapeLabelers)
                this.ShapeLabelers(lIdx).addCopyCallback(copyCallback);
            end
        end


        function configureDeleteCallback(this,DeleteCallback)


            for lIdx=1:numel(this.ShapeLabelers)
                this.ShapeLabelers(lIdx).addDeleteCallback(DeleteCallback);
            end
        end



        function deleteSelectedROIs(this,varargin)



            for lIdx=1:numel(this.ShapeLabelers)
                this.ShapeLabelers(lIdx).deleteSelectedROIs();
            end
        end


        function deleteROIwithUID(this,uid)



            for lIdx=1:numel(this.ShapeLabelers)
                this.ShapeLabelers(lIdx).deleteROIwithUID(uid);
            end
        end


        function selectAllROIs(this,varargin)
            for lIdx=1:numel(this.ShapeLabelers)
                this.ShapeLabelers(lIdx).selectAll();
            end
        end


        function selectROI(this,varargin)
            for lIdx=1:numel(this.ShapeLabelers)
                this.ShapeLabelers(lIdx).selectROI();
            end
        end


        function selectROIreverse(this,varargin)
            for lIdx=1:numel(this.ShapeLabelers)
                this.ShapeLabelers(lIdx).selectROIreverse();
            end
        end


        function roiInfo=selectROIInfo(this,varargin)
            slIdx=getCurrentShapeLabelerIdx(this);
            roiInfo=this.ShapeLabelers(slIdx).selectROIInfo();

        end


        function moveSelectedROI(this,roiInfo,keyPressed)
            slIdx=getCurrentShapeLabelerIdx(this);
            this.ShapeLabelers(slIdx).moveSelectedROI(roiInfo,keyPressed);
        end


        function reshapeRectROI(this,roiInfo,keyPressed)
            if isa(this.CurrentLabeler,'vision.internal.labeler.tool.RectangleLabeler')
                this.ShapeLabelers(1).reshapeRectROI(roiInfo,keyPressed);
            end
        end




        function pan(this,str)
            pan(this.Image,str);
        end


        function[selectedLabelRois,unselectedAllRois]=getSelectedLabelROIs(this)

            selectedLabelRois=repmat(struct('ID','',...
            'ParentUID','',...
            'Label',[],...
            'ParentName','',...
            'Position',[],...
            'Color',[],...
            'Shape',labelType.empty,...
            'Visible',''),...
            0,0);
            unselectedAllRois=repmat(struct('ID','',...
            'ParentUID','',...
            'Label',[],...
            'ParentName','',...
            'Position',[],...
            'Color',[],...
            'Shape',labelType.empty,...
            'Visible',''),...
            0,0);

            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                for n=1:numel(thisLabeler.CurrentROIs)
                    if thisLabeler.checkROIValidity(thisLabeler.CurrentROIs{n})
                        ud=thisLabeler.CurrentROIs{n}.UserData;
                        copiedData=thisLabeler.getCopiedData(thisLabeler.CurrentROIs{n});

                        thisROI.ID=ud{4};
                        thisROI.ParentUID=ud{3};

                        thisROI.Label=copiedData.Tag;
                        thisROI.Position=copiedData.Position;
                        thisROI.Color=copiedData.Color;
                        thisROI.ParentName=ud{2};
                        thisROI.Shape=this.roishape2enum(ud{1});
                        thisROI.Visible=copiedData.Visible;
                        if thisLabeler.CurrentROIs{n}.Selected&&isempty(thisROI.ParentName)
                            selectedLabelRois(end+1)=thisROI;%#ok<AGROW>
                        else
                            unselectedAllRois(end+1)=thisROI;%#ok<AGROW>
                        end
                    end
                end
            end
        end














































        function numROIInstanceSelected=getNumROIInstanceSelected(this)


            numROIInstanceSelected=0;
            for lIdx=1:numel(this.ShapeLabelers)
                numROIInstanceSelected=numROIInstanceSelected+...
                this.ShapeLabelers(lIdx).getNumROIInstanceSelected();
            end
        end


        function[labelName,sublabelName,roiData]=getFirstSelectedROIInstanceInfo(this)


            for lIdx=1:numel(this.ShapeLabelers)
                [labelName,sublabelName,roiData]=this.ShapeLabelers(lIdx).getFirstSelectedROIInstanceInfo();
                if~isempty(roiData)
                    return;
                end
            end
        end


        function[labelName,roiData]=getOneSelectedROILabelInstanceInfo(this)


            for lIdx=1:numel(this.ShapeLabelers)
                [labelName,roiData]=this.ShapeLabelers(lIdx).getOneSelectedROILabelInstanceInfo();
                if~isempty(roiData)
                    return;
                end
            end
            [labelName,roiData]=deal('','');
        end


        function roiInfo=getSingleSelectedROIInstanceInfo(this)



            for lIdx=1:numel(this.ShapeLabelers)
                [labelName,sublabelName,uid,~]=this.ShapeLabelers(lIdx).getSingleSelectedROIInstanceInfo();
                if~isempty(uid)
                    roiInfo=struct('LabelName',labelName,...
                    'SublabelName',sublabelName,...
                    'UID',uid);
                    return;
                end
                roiInfo=struct('LabelName','',...
                'SublabelName','',...
                'UID','');
            end
        end




        function deselectROIInstances(this)




            for lIdx=1:numel(this.ShapeLabelers)
                this.ShapeLabelers(lIdx).deselectAll();
            end
        end
    end




    methods



        function onAutomationMode(this,data,currentIndex,selectedROILabels,algConfig,freezeROIDraw)


            this.resetVoxelLabeler(data);
            wipeROIs(this);


            drawImage(this,data);

            if algConfig.ImportROIs


                roiPositions={selectedROILabels.Position};
                roiNames={selectedROILabels.Label};
                roiparentUIDs={selectedROILabels.ParentUID};
                roiselfUIDs={selectedROILabels.ID};

                parentNames={selectedROILabels.ParentName};

                colors={selectedROILabels.Color};
                shapes=[selectedROILabels.Shape];
                roiVisibility={selectedROILabels.Visible};
                [labelNames,sublabelNames]=convertToSublabelNames(this,roiNames,parentNames);
                drawInteractiveROIs(this,roiPositions,labelNames,sublabelNames,roiselfUIDs,roiparentUIDs,colors,shapes,roiVisibility);
            end

            if freezeROIDraw



                freezeROIDrawingTools(this);
            end


            resetUndoRedoBuffer(this);
            roiAnnotations=this.getCurrentROIs();
            addAllCurrentROILabelsToUndoStack(this,currentIndex,roiAnnotations);
        end




        function onAutomationModeExit(this,currentIndex,unfreezeROIDraw)

            if unfreezeROIDraw



                unfreezeROIDrawingTools(this);
            end


            resetUndoRedoBuffer(this);
            roiAnnotations=this.getCurrentROIs();
            addAllCurrentROILabelsToUndoStack(this,currentIndex,roiAnnotations);
        end




        function onAlgorithmRun(this)
            freezeROIDrawingTools(this);
            resetUndoRedoBuffer(this);
        end




        function onAlgorithmStop(this)
            unfreezeROIDrawingTools(this);
            resetUndoRedoBuffer(this);
        end
    end




    methods(Access=protected)


        function data=overrideShape(~,data)


        end


        function enumShape=roishape2enum(~,shape)
            switch lower(shape)
            case{'line'}
                enumShape=labelType.Line;
            case{'cuboid'}
                enumShape=labelType.Cuboid;
            case{'voxel'}
                enumShape=lidarLabelType.Voxel;
            otherwise
                enumShape=labelType.empty;
            end
        end



        function drawInteractiveROIs(this,varargin)

        end


        function drawStaticROIs(this,varargin)

        end




        function toUpdate=updateInteractiveROIsForUndoRedo(this,currentIndex)



            if this.UndoRedoManagerShape.shouldResetUndoRedo(currentIndex)


                this.UndoRedoManagerShape.resetUndoRedoBuffer();
                roiAnnotations=this.getCurrentROIs();
                addAllCurrentROILabelsToUndoStack(this,currentIndex,roiAnnotations);
                toUpdate=false;
            else
                rois=this.UndoRedoManagerShape.undoStack{end};
                data.Positions=rois.Positions;
                roiNames=rois.ROINames;
                parentNames=rois.ParentNames;

                [labelNames,sublabelNames]=convertToSublabelNames(this,roiNames,parentNames);
                data.LabelNames=labelNames;
                data.SublabelNames=sublabelNames;

                data.SelfUIDs=rois.IDs;
                data.ParentUIDs=rois.ParentUIDs;
                data.Colors=rois.Colors;
                data.Shapes=rois.Shapes;
                data.ROIVisibility=rois.ROIVisibility;

                this.wipeROIs();
                redrawInteractiveROIs(this,data);
                toUpdate=true;

            end
        end

        function doLabelIsSelected(this,~,currentROIs)




            for lIdx=1:numel(this.ShapeLabelers)
                if~isa(currentROIs.Source,class(this.ShapeLabelers(lIdx)))
                    this.ShapeLabelers(lIdx).deselectAll();
                end
            end
            notify(this,'ROISelected',currentROIs);
        end


        function doLabelIsChanged(this,~,currentROIs)





            notify(this,'VoxelROIsChanged',currentROIs);
        end


        function doVoxelLabelChanged(this,data)



            evtData=lidar.internal.labeler.tool.VoxelLabelEventData(data);
            notify(this,'VoxelROIsChanged',evtData);
        end


        function doLabelIsDeleted(this,~,currentROIs)





            deleteSelectedROIs(this);
            notify(this,'ROIsChanged',currentROIs);
        end


        function axToolbarSelectionChangedCallback(this,~,event)
            this.ToolbarSelectionEventObject=event;
            this.ToolbarButtonChangedCallback(this,event);
        end


        function setPointer(this)

        end




        function TF=isInvalidAxes(this)
            TF=isempty(this.AxesHandle)||~ishghandle(this.AxesHandle,'axes');
        end


        function createAxes(this)

        end


        function createImage(this,~)

        end
    end

    methods(Access=private)


        function tf=isCurrentLabelerSupported(this)

            tf=false;
            if this.IsCuboidSupported
                tf=isa(this.CurrentLabeler,'lidar.internal.lidarLabeler.tool.CuboidLabeler')||...
                isa(this.CurrentLabeler,'lidar.internal.lidarLabeler.tool.Line3DLabeler')||...
                isa(this.CurrentLabeler,'lidar.internal.lidarLabeler.tool.VoxelLabeler');
            end
        end

        function slIdx=getCurrentShapeLabelerIdx(this)
            if isa(this.CurrentLabeler,'vision.internal.labeler.tool.RectangleLabeler')
                slIdx=1;
                assert(isa(this.ShapeLabelers(1),'vision.internal.labeler.tool.RectangleLabeler'));
            elseif isa(this.CurrentLabeler,'vision.internal.labeler.tool.LineLabeler')
                slIdx=2;
                assert(isa(this.ShapeLabelers(2),'vision.internal.labeler.tool.LineLabeler'));
            elseif isa(this.CurrentLabeler,'vision.internal.labeler.tool.PolygonLabeler')
                slIdx=3;
                assert(isa(this.ShapeLabelers(3),'vision.internal.labeler.tool.PolygonLabeler'));
            else
                slIdx=4;
                assert(isa(this.ShapeLabelers(4),'vision.internal.labeler.tool.ProjCuboidLabeler'));
            end
        end
    end



    methods(Hidden)
        function mode=getMode(this)
            mode=this.Mode;
        end
    end

end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end
