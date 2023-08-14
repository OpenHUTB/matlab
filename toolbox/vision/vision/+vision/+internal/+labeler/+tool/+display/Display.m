



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

    properties(Dependent)
IsPolygonSupported
    end

    properties(Dependent,Access=private)
IsLineSupported
IsProjCuboidSupported
    end


    events
ROIsChanged
ROISelected
FreezeSignalNav
UnfreezeSignalNav
DisplayClosing
    end

    methods(Abstract)
        configure(this,varargin);
    end

    methods(Abstract,Access=protected)
        initialize(this);
        drawImage(this,data);
    end

    methods
        function tf=get.IsLineSupported(this)
            tf=~this.IsCuboidSupported;
        end

        function tf=get.IsPolygonSupported(this)
            tf=~this.IsCuboidSupported;
        end

        function tf=get.IsProjCuboidSupported(this)
            tf=~this.IsCuboidSupported;
        end
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

        function tf=isAChildSublabelROI(~,labelName,sublabelName,parentUID,selectedLabelROIInfo)

            tf=strcmp(labelName,selectedLabelROIInfo.LabelName)&&...
            ~isempty(sublabelName)&&...
            strcmp(parentUID,selectedLabelROIInfo.SelfUID);
        end


        function tf=isParentLabelROI(~,labelName,sublabelName,selfUID,selectedSublabelROIInfo)

            tf=strcmp(labelName,selectedSublabelROIInfo.LabelName)&&...
            isempty(sublabelName)&&...
            strcmp(selfUID,selectedSublabelROIInfo.ParentUID);
        end


        function tf=isTheLabelROI(this,roi,labelName)

            tf=false;




            copiedData=this.ShapeLabelers.getCopiedData(roi);
            ud=copiedData.UserData;
            if strcmp(copiedData.Tag,labelName)&&isempty(ud{2})&&isempty(ud{3})
                tf=true;
            end
        end


        function tf=isTheSublabelROI(this,roi,labelName,oldSublabelName)

            tf=false;




            copiedData=this.ShapeLabelers.getCopiedData(roi);
            ud=copiedData.UserData;
            if strcmp(copiedData.Tag,oldSublabelName)&&strcmp(ud{2},labelName)&&(~isempty(ud{3}))
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
                elseif strcmpi(this.Clipboard.CopiedROIs{idx}.parentName,labelName)

                    this.Clipboard.CopiedROIs{idx}=[];
                end
            end
        end





        function removeSublabelFromCopyClipboard(this,sublabelName)
            for idx=1:length(this.Clipboard.CopiedROIs)
                if strcmpi(this.Clipboard.CopiedROIs{idx}.Label,sublabelName)
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


        function colorChangeInClipboardPixel(this,newItemInfo)
            if isempty(this.PixelClipboard)...
                ||isempty(this.PixelClipboard.ActiveROIs)
                return;
            end

            if strcmp(this.PixelClipboard.CopyMode,'grabcutpolygon')
                this.PixelClipboard.ActiveROIs.GrabCutPolygon.Color=newItemInfo.Color;
            else
                this.PixelClipboard.ActiveROIs.Color=newItemInfo.Color;
            end
        end


        function roiVisibilityChangeInClipboard(this,newItemInfo)
            this.Clipboard.roiVisibilityChange(newItemInfo);
        end


        function roiVisibilityChangeInClipboardPixel(this,newItemInfo)
            if isempty(this.PixelClipboard)...
                ||isempty(this.PixelClipboard.ActiveROIs)
                return;
            end

            if strcmp(this.PixelClipboard.CopyMode,'grabcutpolygon')
                this.PixelClipboard.ActiveROIs.GrabCutPolygon.Visible=newItemInfo.ROIVisibility;
            else
                this.PixelClipboard.ActiveROIs.Visible=newItemInfo.ROIVisibility;
            end
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


        function setLoadingText(this,flag,isVideo)
            this.LabeledVideoUIObj.setLoadingText(flag,isVideo);
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

        function setROIColorByGroup(this,val,roiLabelDefinitionStruct)

            for i=1:numel(this.ShapeLabelers)

                if(isempty(this.ShapeLabelers(i).CurrentROIs))
                    continue;
                end

                this.ShapeLabelers(i).setROIColorByGroup(val,roiLabelDefinitionStruct);

            end

        end


        function enableDrawing(this)

            if~isempty(this.ImageHandle)&&~isempty(this.Fig)&&...
                ~isempty(this.AxesHandle)&&...
                ~isempty(this.CurrentLabeler)&&isCurrentLabelerSupported(this)

                activate(this.CurrentLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
                if this.IsPixelSupported
                    updateGrabCutEditor(this.PixelLabeler);
                end
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

            if hasModeChanged||isa(this.ImageHandle,'bigimageshow')







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


        function resetVideoDisplay(this)
            this.wipeFigure();
            this.initialize();
            clearImageInDisplay(this);
        end


        function updateDisplayWithBlankImage(this)

            wipeROIs(this);
            this.ImageHandle.CData=[];
        end


        function freezeSignalNavInteractions(this)



            notify(this,'FreezeSignalNav');
        end


        function unfreezeSignalNavInteractions(this)



            notify(this,'UnfreezeSignalNav');
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
                case{'togglegrid'}



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

                case 'togglegrid'






                    if this.isLabelerInitialized
                        modeSelection='ROI';
                    else
                        modeSelection='none';
                    end

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


        function UIObj=getLabeledVideoContainer(this)
            UIObj=this.LabeledVideoUIObj;
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
                else
                    sublabelNames{i}=roiNames{i};
                    labelNames{i}=parentNames{i};
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

            if this.LabelingMode==labelType.PixelLabel
                updateSuperpixelState(this);
            end

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


        function getDisplayIndex(this,flag)
            this.LabeledVideoUIObj.getDisplayIndexInfo(flag);
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
                    if this.IsCuboidSupported
                        this.CurrentLabeler=this.CuboidLabeler;
                    else
                        this.CurrentLabeler=this.RectangleLabeler;
                    end
                    this.InPixelMode=false;

                case labelType.Line

                    if this.IsLineSupported

                        this.CurrentLabeler=this.LineLabeler;
                    else
                        this.CurrentLabeler=this.Line3DLabeler;
                    end
                    this.InPixelMode=false;

                case labelType.Polygon

                    if this.IsPolygonSupported

                        this.CurrentLabeler=this.PolygonLabeler;
                    else
                        this.CurrentLabeler=[];
                    end
                    this.InPixelMode=false;

                case labelType.ProjectedCuboid

                    if this.IsProjCuboidSupported

                        this.CurrentLabeler=this.ProjCuboidLabeler;
                    else
                        this.CurrentLabeler=[];
                    end
                    this.InPixelMode=false;

                case labelType.PixelLabel

                    if this.IsPixelSupported

                        this.CurrentLabeler=this.PixelLabeler;
                        this.InPixelMode=true;
                    else
                        this.CurrentLabeler=[];
                        this.InPixelMode=false;
                    end
                case labelType.Cuboid

                    if this.IsCuboidSupported
                        this.CurrentLabeler=this.CuboidLabeler;
                    else
                        this.CurrentLabeler=[];
                    end
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

            if isa(selectedLabel,'vision.internal.labeler.ROILabel')||...
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


        function highlightChildrenOrParent(this)
            [numROIselected,singleSelectedROIInfo]=this.selectedROIInstanceInfo();
            this.unhighlightCurrentROIs();

            if numROIselected>0

                if numROIselected==1
                    isLabelSelected=isempty(singleSelectedROIInfo.SublabelName);
                    if isLabelSelected
                        this.highlightSublabels(singleSelectedROIInfo);
                    else
                        this.highlightLabels(singleSelectedROIInfo);
                    end
                end
            end
        end

        function highlightSelectedROIsToGray(this)
            highlightSelectedROIsColor(this,this.YELLOW,this.GRAY);
        end

        function highlightSelectedROIsToYellow(this)
            highlightSelectedROIsColor(this,this.GRAY,this.YELLOW);
        end


        function unhighlightCurrentROIs(this)
            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                for n=1:numel(thisLabeler.CurrentROIs)
                    roi=thisLabeler.CurrentROIs{n};
                    if isa(roi,'images.roi.Rectangle')||...
                        isa(roi,'vision.roi.ProjectedCuboid')
                        if thisLabeler.CurrentROIs{n}.FaceAlpha~=0
                            thisLabeler.CurrentROIs{n}.FaceAlpha=0;
                        end
                    end
                end
            end
        end


        function highlightSublabels(this,labelROIInfo)
            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                for n=1:numel(thisLabeler.CurrentROIs)
                    roi=thisLabeler.CurrentROIs{n};
                    if isa(roi,'images.roi.Rectangle')||...
                        isa(roi,'vision.roi.ProjectedCuboid')
                        [labelName,sublabelName,~,parentUID]=thisLabeler.getLabelDefInfo(roi);
                        if isAChildSublabelROI(this,labelName,sublabelName,parentUID,labelROIInfo)
                            thisLabeler.CurrentROIs{n}.FaceAlpha=0.3;
                        end
                    end
                end
            end
        end


        function highlightLabels(this,sublabelROIInfo)
            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                for n=1:numel(thisLabeler.CurrentROIs)
                    roi=thisLabeler.CurrentROIs{n};
                    if isa(roi,'images.roi.Rectangle')||...
                        isa(roi,'vision.roi.ProjectedCuboid')
                        [labelName,sublabelName,selfUID,~]=thisLabeler.getLabelDefInfo(roi);
                        if isParentLabelROI(this,labelName,sublabelName,selfUID,sublabelROIInfo)
                            thisLabeler.CurrentROIs{n}.FaceAlpha=0.3;
                        end
                    end
                end
            end
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
            if isa(selectedLabelData,'vision.internal.labeler.ROILabel')
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


        function changeVisibilitySelectedPixelROI(this,selectedLabelData,selectedItemInfo)
            this.PixelLabeler.updateActivePolygonVisibility(selectedLabelData,selectedItemInfo.roiItemDataObj);

            if strcmp(selectedLabelData.Label,selectedItemInfo.roiItemDataObj.Label)
                if selectedLabelData.ROIVisibility
                    this.Mode='ROI';
                else
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
            tf=isa(selectedLabel,'vision.internal.labeler.ROILabel')&&...
            isprop(selectedLabel,'Label')&&~isempty(selectedLabel.Label);
        end


        function tf=isLabelInstance(~,labelName,sublabelName)
            tf=~isempty(labelName)&&isempty(sublabelName);
        end


        function tf=isSublabelInstance(~,labelName,sublabelName)
            tf=~isempty(labelName)&&~isempty(sublabelName);
        end


        function parName=parentName(~,selectedLabel)
            if isprop(selectedLabel,'LabelName')
                parName=selectedLabel.LabelName;
            else
                parName='';
            end
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

                        elseif isASublabelROIOfTheLabel(this,thisROI,oldLabelName)


                            copiedData=this.ShapeLabelers.getCopiedData(thisROI);
                            if isempty(thisROI.Label)
                                copiedData.Label='';
                            end
                            copiedData.UserData{2}=newLabelName;
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


        function modifySublabelNameInCurrentROIs(this,labelName,oldSublabelName,newSublabelName)
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
                        if isTheSublabelROI(this,thisROI,labelName,oldSublabelName)





                            copiedData=this.ShapeLabelers.getCopiedData(thisROI);
                            if isempty(thisROI.Label)
                                copiedData.Label='';
                            else
                                copiedData.Label=newSublabelName;
                            end

                            copiedData.Tag=newSublabelName;

                            this.ShapeLabelers.changeROIProperty(thisROI,copiedData);
                        end
                    end
                end
            end
        end


        function modifySublabelColorInCurrentROIs(this,labelName,sublabelName,newSublabelColor)


            for lIdx=1:numel(this.ShapeLabelers)
                thisLabeler=this.ShapeLabelers(lIdx);
                for n=1:numel(thisLabeler.CurrentROIs)
                    thisROI=thisLabeler.CurrentROIs{n};
                    if thisLabeler.checkROIValidity(thisROI)
                        if isTheSublabelROI(this,thisROI,labelName,sublabelName)
                            copiedData=this.ShapeLabelers.getCopiedData(thisROI);
                            copiedData.Color=newSublabelColor;
                            this.ShapeLabelers.changeROIProperty(thisROI,copiedData);
                        end
                    end
                end
            end
        end


        function finalize(~)



        end


        function resetPixelLabeler(~,~)



        end


        function initializePixelLabeler(this)

            if this.isInvalidAxes()
                this.createAxes();
            end
            setHandles(this.PixelLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
        end


        function updateContextMenuCopyPastePixel(this,sessionData)

            copyPixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children,...
            'Tag','CopyPixelROIsContextMenu');
            pastePixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children...
            ,'Tag','PastePixelROIsContextMenu');
            cutPixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children...
            ,'Tag','CutPixelROIsContextMenu');
            deletePixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children...
            ,'Tag','DeletePixelROIsContextMenu');

            if isfield(sessionData,'isInAlgoMode')
                if sessionData.isInAlgoMode
                    return;
                end
                numPixelROIDefn=sessionData.numPixelLabels;
            else
                numPixelROIDefn=0;
            end

            if nnz(this.PixelLabeler.LabelMatrix)
                set(copyPixelUIMenu,'Enable','on');
                set(cutPixelUIMenu,'Enable','on');
                set(deletePixelUIMenu,'Enable','on');
            else
                set(copyPixelUIMenu,'Enable','off');
                set(cutPixelUIMenu,'Enable','off');
                set(deletePixelUIMenu,'Enable','off');
            end




            if strcmp(copyPixelUIMenu.Enable,'on')||...
                strcmp(pastePixelUIMenu.Enable,'on')||...
                strcmp(cutPixelUIMenu.Enable,'on')||...
                strcmp(deletePixelUIMenu.Enable,'on')||...
                numPixelROIDefn>0
                set(copyPixelUIMenu,'Visible','on');
                set(pastePixelUIMenu,'Visible','on');
                set(cutPixelUIMenu,'Visible','on');
                set(deletePixelUIMenu,'Visible','on');
            end
        end


        function enableContextMenuCopyPastePixel(this,numPixelROIDefn)

            copyPixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children,...
            'Tag','CopyPixelROIsContextMenu');
            pastePixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children,...
            'Tag','PastePixelROIsContextMenu');
            cutPixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children,...
            'Tag','CutPixelROIsContextMenu');
            deletePixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children,...
            'Tag','DeletePixelROIsContextMenu');
            if numPixelROIDefn
                set(copyPixelUIMenu,'Visible','on');
                set(pastePixelUIMenu,'Visible','on');
                set(cutPixelUIMenu,'Visible','on');
                set(deletePixelUIMenu,'Visible','on');
            end
        end


        function disableContextMenuCopyPastePixel(this,numPixelROIDefn,roiData)
            if isempty(this.ImageHandle)
                return;
            end


            if~isempty(this.PixelClipboard)
                if~isempty(this.PixelClipboard.Mask)
                    this.PixelClipboard.Mask(this.PixelClipboard.Mask==roiData.PixelLabelID)=0;
                end

                if~isempty(this.PixelClipboard.ActiveROIs)
                    if strcmp(this.PixelClipboard.CopyMode,'grabcutpolygon')
                        if(this.PixelClipboard.ActiveROIs.GrabCutPolygon.UserData==roiData.PixelLabelID)
                            this.PixelClipboard.ActiveROIs=[];
                        end
                    else
                        if(this.PixelClipboard.ActiveROIs.UserData==roiData.PixelLabelID)
                            this.PixelClipboard.ActiveROIs=[];
                        end
                    end
                end

                if~nnz(this.PixelClipboard.Mask)
                    pastePixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children...
                    ,'Tag','PastePixelROIsContextMenu');
                    set(pastePixelUIMenu,'Enable','off');
                    this.PixelClipboard=[];
                end
            end

            if(numPixelROIDefn==1)
                this.resetCopyPastePixelContextMenu();
                this.PixelClipboard=[];
            end
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
        function setDisplayFigHandleVis(this,status)
            this.Fig.HandleVisibility=status;
        end





        function updatePixelLabelerLookup(this,color,pixelID)
            this.PixelLabeler.updatePixelLabelerLookup(color,pixelID);
        end





        function updateActivePolygonColorInCurrentFrame(this,labelName,color)
            this.PixelLabeler.updateActivePolygonColorInCurrentFrame(labelName,color);
        end





        function updateActivePolygonNameInCurrentFrame(this,oldLabelname,newLabelname)
            this.PixelLabeler.updateActivePolygonNameInCurrentFrame(oldLabelname,newLabelname);
        end





        function updatePixelLabelerLookupNewDisplay(this,colorLookupTable)
            this.PixelLabeler.setColorLookupTable(colorLookupTable);
        end





        function updatePixelLabelVisibilityDisplay(this,pixelLabelVisibility)
            this.PixelLabeler.setLabelVisibility(pixelLabelVisibility);
        end





        function setPixelLabelMode(this,mode,showTutorial)
            setMode(this.PixelLabeler,mode,showTutorial);
            if strcmp(this.Mode,'ROI')
                updateGrabCutEditor(this.PixelLabeler);
            end
        end

        function updateSuperpixelLayout(this,count,disableLayout)
            updateSuperpixelGrid(this.PixelLabeler,count,disableLayout);
        end

        function setSuperpixelParams(this,count)
            setSuperpixelParams(this.PixelLabeler,count);
        end

        function updateSuperpixelState(this)
            if this.IsPixelSupported
                updateSuperpixelState(this.PixelLabeler);
            end
        end

        function updateBrushOutline(this,color)
            if this.IsPixelSupported
                updateBrushOutline(this.PixelLabeler,color);
            end
        end

        function updateSuperpixelLayoutState(this,state)
            updateSuperpixelLayoutState(this.PixelLabeler,state);
        end

        function disableBrushOutline(this)
            disableBrushOutline(this.PixelLabeler);
        end

        function resetSuperPixelLayout(this)
            resetSuperPixelLayout(this.PixelLabeler);
        end





        function setPixelLabelMarkerSize(this,sz)
            this.PixelLabeler.MarkerSize=sz;
        end





        function setPixelLabelAlpha(this,alpha)
            this.PixelLabeler.Alpha=alpha;
        end



        function setLabelMatrixFilename(this,fullfilename)
            setLabelMatrixFilename(this.PixelLabeler,fullfilename);
        end


        function resetCopyPastePixelContextMenu(this)
            copyPixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children,...
            'Tag','CopyPixelROIsContextMenu');
            pastePixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children...
            ,'Tag','PastePixelROIsContextMenu');
            cutPixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children...
            ,'Tag','CutPixelROIsContextMenu');
            deletePixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children...
            ,'Tag','DeletePixelROIsContextMenu');
            set(copyPixelUIMenu,'Visible','off','Enable','off');
            set(pastePixelUIMenu,'Visible','off','Enable','off');
            set(cutPixelUIMenu,'Visible','off','Enable','off');
            set(deletePixelUIMenu,'Visible','off','Enable','off');
        end




        function setPolygonLabelAlpha(this,alpha)
            this.PolygonLabeler.setAlpha(alpha);

            if(alpha==0)
                this.PolygonLabeler.setFaceSelectable(false);
            else
                this.PolygonLabeler.setFaceSelectable(true);
            end
        end




        function sendPolygonToBack(this)
            this.PolygonLabeler.sendToBack();
        end




        function bringPolygonToFront(this)
            this.PolygonLabeler.bringToFront();
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


        function configurePolygonSendToBackCallback(this,sendToBackCallback)

            this.PolygonLabeler.addSendToBackCallback(sendToBackCallback);
        end


        function configurePolygonBringToFrontCallback(this,bringToFrontCallback)

            this.PolygonLabeler.addBringToFrontCallback(bringToFrontCallback);
        end


        function cutSelectedROIs(this,varargin)



            this.copySelectedROIs();
            this.deleteSelectedROIs();
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


        function[selectedRois,unselectedRois]=getSelectedROIs(this)

            selectedRois=repmat(struct('ID','',...
            'ParentUID','',...
            'Label',[],...
            'ParentName','',...
            'Position',[],...
            'Color',[],...
            'Shape',labelType.empty),...
            0,0);
            unselectedRois=repmat(struct('ID','',...
            'ParentUID','',...
            'Label',[],...
            'ParentName','',...
            'Position',[],...
            'Color',[],...
            'Shape',labelType.empty),...
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
                        if thisLabeler.CurrentROIs{n}.Selected
                            selectedRois(end+1)=thisROI;%#ok<AGROW>
                        else
                            unselectedRois(end+1)=thisROI;%#ok<AGROW>
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
            [labelName,sublabelName,roiData]=deal('','','');
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
            end

            roiInfo=struct('LabelName','',...
            'SublabelName','',...
            'UID','');

        end


        function[numROIselected,singleSelectedROIInfo]=selectedROIInstanceInfo(this)







            numROIselected=0;
            singleSelectedROIInfo.SelfUID='';
            singleSelectedROIInfo.ParentUID='';
            singleSelectedROIInfo.LabelName='';
            singleSelectedROIInfo.SublabelName='';

            for lIdx=1:numel(this.ShapeLabelers)
                [numROIselectedTmp,singleSelectedROIInfoTmp]=selectedROIInstanceInfo(this.ShapeLabelers(lIdx));
                numROIselected=numROIselected+numROIselectedTmp;
                if numROIselected>1
                    numROIselected=inf;
                    singleSelectedROIInfo.SelfUID='';
                    singleSelectedROIInfo.ParentUID='';
                    singleSelectedROIInfo.LabelName='';
                    singleSelectedROIInfo.SublabelName='';
                    return;
                else
                    if~isempty(singleSelectedROIInfoTmp.LabelName)
                        singleSelectedROIInfo=singleSelectedROIInfoTmp;
                    end
                end
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


            this.resetPixelLabeler(data);
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
            case{'rect'}
                enumShape=labelType.Rectangle;
            case{'line'}
                enumShape=labelType.Line;
            case{'polygon'}
                enumShape=labelType.Polygon;
            case{'projcuboid'}
                enumShape=labelType.ProjectedCuboid;
            case{'cuboid'}
                enumShape=labelType.Cuboid;
            otherwise
                enumShape=labelType.empty;
            end
        end


        function drawInteractiveROIs(this,roiPositions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes,roiVisibility)

            if~isempty(roiPositions)&&...
                ~isempty(labelNames)&&...
                ~isempty(colors)&&...
                ~isempty(colors)

                data.Positions=roiPositions;
                [roiNames,parentNames]=convertToParentNames(this,labelNames,sublabelNames);
                data.Names=roiNames;
                data.ParentNames=parentNames;
                data.ParentUIDs=parentUIDs;
                data.SelfUIDs=selfUIDs;
                data.Colors=colors;
                data.Shapes=shapes;
                data.ROIVisibility=roiVisibility;
                this.RectangleLabeler.drawLabels(data);
                this.LineLabeler.drawLabels(data);
                this.PolygonLabeler.drawLabels(data);
                this.ProjCuboidLabeler.drawLabels(data);
            end
        end


        function drawStaticROIs(this,roiPositions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes,roiVisibility)





            for roiPosIdx=1:numel(roiPositions)
                thisROIPos=roiPositions{roiPosIdx};

                switch shapes(roiPosIdx)
                case labelType.Rectangle

                    for rectROIIdx=1:size(thisROIPos,1)
                        staticRoi=vision.internal.videoLabeler.tool.StaticROI(...
                        thisROIPos(rectROIIdx,:),this.AxesHandle,...
                        colors{roiPosIdx},labelNames{roiPosIdx},...
                        sublabelNames{roiPosIdx},selfUIDs{roiPosIdx},...
                        parentUIDs{roiPosIdx},this.ShowLabel,roiVisibility{roiPosIdx});
                        this.StaticROIs{end+1}=staticRoi;
                    end
                case labelType.Line
                    if~iscell(thisROIPos)
                        thisROIPos={thisROIPos};
                    end

                    for lineROIIdx=1:size(thisROIPos,1)
                        staticRoi=vision.internal.videoLabeler.tool.StaticLineROI(...
                        thisROIPos{lineROIIdx},this.AxesHandle,...
                        colors{roiPosIdx},labelNames{roiPosIdx},...
                        sublabelNames{roiPosIdx},selfUIDs{roiPosIdx},parentUIDs{roiPosIdx},this.ShowLabel,roiVisibility{roiPosIdx});
                        this.StaticROIs{end+1}=staticRoi;
                    end
                case labelType.Polygon
                    if~iscell(thisROIPos)
                        thisROIPos={thisROIPos};
                    end

                    for polygonROIIdx=1:size(thisROIPos,1)
                        staticRoi=vision.internal.videoLabeler.tool.StaticPolygonROI(...
                        thisROIPos{polygonROIIdx},this.AxesHandle,...
                        colors{roiPosIdx},labelNames{roiPosIdx},...
                        sublabelNames{roiPosIdx},selfUIDs{roiPosIdx},parentUIDs{roiPosIdx},this.ShowLabel,roiVisibility{roiPosIdx});
                        this.StaticROIs{end+1}=staticRoi;
                    end
                case labelType.ProjectedCuboid
                    if~iscell(thisROIPos)
                        thisROIPos={thisROIPos};
                    end

                    for projCuboidROIIdx=1:size(thisROIPos,1)
                        staticRoi=vision.internal.videoLabeler.tool.StaticProjCuboidROI(...
                        thisROIPos{projCuboidROIIdx},this.AxesHandle,...
                        colors{roiPosIdx},labelNames{roiPosIdx},...
                        sublabelNames{roiPosIdx},selfUIDs{roiPosIdx},parentUIDs{roiPosIdx},this.ShowLabel,roiVisibility{roiPosIdx});
                        this.StaticROIs{end+1}=staticRoi;
                    end
                otherwise
                    assert(false,'drawStaticROIs: Unknown shape: %s',shapes(roiPosIdx));
                end
            end
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




            notify(this,'ROIsChanged',currentROIs);
        end


        function doPixelLabelChanged(this,data)



            evtData=vision.internal.labeler.tool.PixelLabelEventData(data);
            notify(this,'ROIsChanged',evtData);
        end


        function doLabelIsDeleted(this,~,currentROIs)





            deleteSelectedROIs(this);
            notify(this,'ROIsChanged',currentROIs);
        end


        function axToolbarSelectionChangedCallback(this,~,event)
            this.ToolbarSelectionEventObject=event;
            this.ToolbarButtonChangedCallback(this,event);
        end


        function clickPos=getCurrentAxesPoint(this)
            cP=this.AxesHandle.CurrentPoint;
            clickPos=[cP(1,1),cP(1,2)];
        end


        function tf=isInBounds(this,X,Y)
            XLim=this.AxesHandle.XLim;
            YLim=this.AxesHandle.YLim;
            tf=X>=XLim(1)&&X<=XLim(2)&&Y>=YLim(1)&&Y<=YLim(2);
        end


        function setPointer(this)

            if strcmpi(this.Mode,'ROI')
                if this.LabelingMode==labelType.PixelLabel
                    setPointer(this.PixelLabeler)
                else
                    images.roi.internal.setROIPointer(this.Fig,'crosshair');
                end
            elseif strcmpi(this.Mode,'none')

                images.roi.internal.setROIPointer(this.Fig,'restricted');
            else
                set(this.Fig,'Pointer','arrow');
            end
        end




        function TF=isInvalidAxes(this)
            TF=isempty(this.AxesHandle)||~ishghandle(this.AxesHandle,'axes');
        end


        function createAxes(this)
            this.Image=images.internal.app.utilities.Image(this.ImagePanel);
            addlistener(this.Fig,'WindowScrollWheel',@(src,evt)scrollCallback(this,evt));
            addlistener(this.Fig,'WindowMouseMotion',@(src,evt)imageMotionCallback(this,src,evt));
            this.ImageHandle=this.Image.ImageHandle;
            this.AxesHandle=this.Image.AxesHandle;
            this.AxesHandle.Toolbar.SelectionChangedFcn=@(src,evt)this.axToolbarSelectionChangedCallback(src,evt);
            resizeFigure(this);
            set(this.Fig,...
            'AutoResizeChildren','off',...
            'Units','pixels',...
            'SizeChangedFcn',@(src,evt)resizeFigureImage(this,evt));
            this.Image.Visible=true;
            this.Image.Enabled=true;
        end

        function TF=wasMotionOnAxesToolbar(~,evt)
            TF=~isempty(ancestor(evt.HitObject,'matlab.graphics.controls.AxesToolbar'));
        end

        function imageMotionCallback(this,src,evt)

            this.MouseMotionHitObject=ancestor(evt.HitObject,'figure');

            if this.MouseMotionHitObject==this.Fig
                if wasMotionOnAxesToolbar(this,evt)
                    images.roi.setBackgroundPointer(src,'arrow');
                elseif isa(evt.HitObject,'matlab.graphics.primitive.Image')
                    if isprop(evt.HitObject,'InteractionMode')
                        switch evt.HitObject.InteractionMode
                        case 'pan'
                            images.roi.setBackgroundPointer(src,'custom',matlab.graphics.interaction.internal.getPointerCData('pan_both'),[16,16]);
                        case 'zoomin'
                            images.roi.setBackgroundPointer(src,'custom',matlab.graphics.interaction.internal.getPointerCData('zoomin_unconstrained'),[16,16]);
                        case 'zoomout'
                            images.roi.setBackgroundPointer(src,'custom',matlab.graphics.interaction.internal.getPointerCData('zoomout_both'),[16,16]);
                        end
                    end
                end
            end
        end

        function resizeFigureImage(this,evt)
            set(this.ImagePanel,'Position',[1,1,evt.Source.Position(3:4)]);
            resize(this.Image);
        end

        function scrollCallback(this,evt)
            if~isempty(this.MouseMotionHitObject)&&this.MouseMotionHitObject==this.Fig
                scroll(this.Image,evt.VerticalScrollCount);
            end
        end


        function TF=isInvalidImage(this,im)
            TF=isempty(this.ImageHandle)||~isvalid(this.ImageHandle)||~isequal(size(im),size(this.ImageHandle.CData));
        end


        function createImage(this,im)

            originalTag=this.AxesHandle.Tag;
            if isempty(originalTag)
                originalTag=getAxesTag(this);
            end
            if isempty(this.ImageHandle)
                this.ImageHandle=this.Image.ImageHandle;
            end
            if isstruct(im)
                this.Image.Alpha=im.alpha;
                draw(this.Image,im.I,im.label,im.cmap,[]);
            else
                draw(this.Image,im,[],[],[]);
            end


            if~this.Image.Visible


                this.Image.Visible=true;
            end
            if~this.Image.Enabled
                this.Image.Enabled=true;
            end
            this.AxesHandle.Tag=originalTag;
        end


        function clearImageInDisplay(this)



            clear(this.Image);
            this.ImageHandle=[];
        end

        function axesTag=getAxesTag(this)
            if this.SignalType==vision.labeler.loading.SignalType.Image
                axesTag="ImageAxes";
            elseif this.SignalType==vision.labeler.loading.SignalType.PointCloud
                axesTag="PointCloudAxes";
            else
                axesTag="NoneAxes";
            end
        end




    end

    methods(Access=private)


        function tf=isCurrentLabelerSupported(this)

            if this.IsCuboidSupported
                tf=isa(this.CurrentLabeler,'driving.internal.groundTruthLabeler.tool.CuboidLabeler')||...
                isa(this.CurrentLabeler,'driving.internal.groundTruthLabeler.tool.Line3DLabeler');
            else
                tf=isa(this.CurrentLabeler,'vision.internal.labeler.tool.RectangleLabeler')||...
                isa(this.CurrentLabeler,'vision.internal.labeler.tool.LineLabeler')||...
                isa(this.CurrentLabeler,'vision.internal.labeler.tool.PolygonLabeler')||...
                isa(this.CurrentLabeler,'vision.internal.labeler.tool.ProjCuboidLabeler')||...
                isa(this.CurrentLabeler,'vision.internal.labeler.tool.PixelLabeler');
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