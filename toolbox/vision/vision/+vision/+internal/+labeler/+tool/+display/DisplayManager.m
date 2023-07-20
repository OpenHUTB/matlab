
classdef DisplayManager<handle

    properties
Displays
NumDisplays
        IsANewDispSelected=false;
    end
    properties(Access=protected)
        PrevActiveDisplayName;
    end
    properties(Access=private)
DisplayFactoryObj
CopyDisplayName_ROI
CopyDisplayName_PixelROI
    end




    methods

        function this=DisplayManager(hFig,toolType,defaultName)

            this.DisplayFactoryObj=vision.internal.labeler.tool.display.DisplayFactory();
            createDefaultDisplay(this,hFig,toolType,defaultName);
        end

        function num=get.NumDisplays(this)
            num=numel(this.Displays);
        end

        function success=updateDisplayNameAndFigTitle(this,oldName,newName)
            success=isNameUnused(this,newName);
            if success
                thisDisplay=getDisplay(this,oldName);
                setFigureTitle(thisDisplay,newName);





                if strcmp(this.PrevActiveDisplayName,oldName)
                    this.PrevActiveDisplayName=newName;
                end

                if strcmp(this.CopyDisplayName_ROI,oldName)
                    this.CopyDisplayName_ROI=newName;
                end

                if strcmp(this.CopyDisplayName_PixelROI,oldName)
                    this.CopyDisplayName_PixelROI=newName;
                end
            end

        end
    end




    methods



        function fig=getDisplayFig(this,name)
            dispObj=getDisplay(this,name);
            fig=dispObj.Fig;
        end


        function display=getDisplayFromId(this,id)
            if(id>0)&&(id<=this.NumDisplays)
                display=this.Displays{id};
            else
                display=[];
            end
        end

        function display=getDisplayFromIdNoCheck(this,id)
            display=this.Displays{id};
        end

        function selectedDisplay=getSelectedDisplay(this)

            selectedDisplay='';
            if this.NumDisplays==2

                selectedDisplay=getDisplayFromIdNoCheck(this,2);
            elseif this.NumDisplays>1
                selectedDisplay=getDisplay(this,this.PrevActiveDisplayName);
            end
        end

        function tf=isSelectedDisplayLidar(this)

            tf=false;
            selectedDisplay=getSelectedDisplay(this);
            if~isempty(selectedDisplay)
                tf=selectedDisplay.IsCuboidSupported;
            end
        end

        function id=getSelectedDisplayId(this)
            id=[];
            selectedDisplay=this.getSelectedDisplay();
            if isempty(selectedDisplay)
                return;
            end
            signalName=selectedDisplay.Name;
            id=this.getDisplayIdFromName(signalName);
        end

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

        function dispIdx=getDisplayIdFromName(this,name)

            [~,dispIdx]=doesNameExist(this,name);
        end

        function dispObj=getDisplay(this,name)
            [dispExists,dispIdx]=doesNameExist(this,name);
            if dispExists
                dispObj=this.Displays{dispIdx};
            else
                dispObj=[];
            end
        end

        function grabFocus(this)




            thisDisplay=[];
            if(this.NumDisplays==1)
                thisDisplay=this.Displays{1};
            elseif this.NumDisplays>1
                thisDisplay=getDisplay(this,this.PrevActiveDisplayName);
            end

            if~isempty(thisDisplay)
                if isPanelVisible(thisDisplay)
                    grabFocus(thisDisplay);
                end
            end
        end

        function dispObjs=getDisplays(this)
            dispObjs=this.Displays;
        end

        function dispObj=getLastAddedDisplay(this)
            if this.NumDisplays>0
                dispObj=this.Displays{end};
            else
                dispObj=[];
            end
        end

        function dispObj=getDefaultDisplay(this)
            if this.NumDisplays>0
                dispObj=this.Displays{1};
            else
                dispObj=[];
            end
        end

        function setCopyDisplayName_ROI(this,displayName)
            this.CopyDisplayName_ROI=displayName;
        end

        function setCopyDisplayName_PixelROI(this,displayName)
            this.CopyDisplayName_PixelROI=displayName;
        end

        function display=getCopyDisplay_ROI(this)

            [dispExists,dispIdx]=doesNameExist(this,this.CopyDisplayName_ROI);
            if dispExists
                display=this.Displays{dispIdx};
            else
                display=[];
            end
        end

        function display=getCopyDisplay_PixelROI(this)

            [dispExists,dispIdx]=doesNameExist(this,this.CopyDisplayName_PixelROI);
            if dispExists
                display=this.Displays{dispIdx};
            else
                display=[];
            end
        end
    end




    methods
        function newDisplay=createAndAddDisplay(this,hFig,dispType,toolType,name)
            newDisplay=[];
            if isNameUnused(this,name)
                newDisplay=this.DisplayFactoryObj.createDisplay(hFig,dispType,toolType,name);

                this.Displays{end+1}=newDisplay;
                if dispType~=displayType.None

                    this.PrevActiveDisplayName=name;
                end
            end
        end

        function removeDisplay(this,name)
            [dispExists,dispIdx]=doesNameExist(this,name);
            if dispExists
                delete(this.Displays{dispIdx});
                this.Displays(dispIdx)=[];
            end
        end

        function setPasteMenuState(this,signalType,copiedROIsTypes,enablePasteFlag)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                thisDisplay=allDisplays{i};

                if enablePasteFlag&&(thisDisplay.SignalType==signalType)
                    enableState='on';
                else
                    enableState='off';
                end
                setPasteMenuState(thisDisplay,copiedROIsTypes,enableState);
            end
        end

        function setPasteMenuVisibility(this,visibleFlag)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                thisDisplay=allDisplays{i};
                setPasteVisibility(thisDisplay,visibleFlag);
            end
        end

        function setPixPasteMenuState(this,signalType,enablePasteFlag)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                thisDisplay=allDisplays{i};

                if enablePasteFlag&&(thisDisplay.SignalType==signalType)
                    enableState='on';
                    visibleState='on';
                elseif thisDisplay.SignalType==signalType
                    enableState='off';
                    visibleState='on';
                else
                    continue;
                end
                setPixPasteMenuState(thisDisplay,enableState,visibleState);
            end
        end

        function setPixContextMenuVisibility(this,visibleFlag)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                thisDisplay=allDisplays{i};
                if thisDisplay.IsPixelSupported
                    setPixContextMenuVisibility(thisDisplay,visibleFlag);
                end
            end
        end

        function updateDisplayedFrameIndices(this,frameIndices)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                if frameIndices(i-1)>0
                    updateDisplayIndex(allDisplays{i},frameIndices(i-1));
                end
            end
        end

        function configureCutCopyCallback(this,cutCallback,copyCallback)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                configureCutCallback(allDisplays{i},cutCallback);
                configureCopyCallback(allDisplays{i},copyCallback);
            end
        end

        function resetUndoRedoBuffer(this)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                resetUndoRedoBuffer(allDisplays{i});
            end
        end

        function removeLabelFromCopyClipboard(this,labelName)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                removeLabelFromCopyClipboard(allDisplays{i},labelName);
            end
        end

        function removeSublabelFromCopyClipboard(this,sublabelName)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                removeSublabelFromCopyClipboard(allDisplays{i},sublabelName);
            end
        end


        function refreshClipboard(this)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                refreshClipboard(allDisplays{i});
            end
        end

        function unhighlightDisplayBorders(this)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                unhighlightBorder(allDisplays{i});
            end
        end

        function highlightSelectedROIsToGray(this)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                highlightSelectedROIsToGray(allDisplays{i});
            end
        end

        function changeDisplayBorderROIColor(this,selectedDisplayName)
            if this.NumDisplays>1

                selectedDisplay=getDisplay(this,selectedDisplayName);



                unhighlightDisplayBorders(this);
                selectedDisplay.highlightBorder();


                highlightSelectedROIsToGray(this);
                selectedDisplay.highlightSelectedROIsToYellow();




            end
        end
        function changeSelectedDisplayBorderROIColor(this)
            changeDisplayBorderROIColor(this,this.PrevActiveDisplayName)
        end









        function finalize(this)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                finalize(allDisplays{i});
            end
        end

        function resetUndoRedoPixelOnLabDefDel(this)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                resetUndoRedoPixelOnLabDefDel(allDisplays{i});
            end
        end

        function setLabelVisiblity(this,val)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                setLabelVisiblity(allDisplays{i},val);
            end
        end

        function setROIColorByGroup(this,val,roiDefinitionStruct)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                setROIColorByGroup(allDisplays{i},val,roiDefinitionStruct);
            end
        end

        function onAlgorithmRun(this,name)

            [dispExists,dispIdxForAlgo]=doesNameExist(this,name);
            if dispExists
                displayForAlgo=this.Displays{dispIdxForAlgo};
                displayForAlgo.onAlgorithmRun();

                for i=2:this.NumDisplays
                    if i~=dispIdxForAlgo
                        disableAxis(this.Displays{i});
                    end
                end
            end
        end

        function onAlgorithmStop(this,name)

            [dispExists,dispIdxForAlgo]=doesNameExist(this,name);
            if dispExists
                displayForAlgo=this.Displays{dispIdxForAlgo};
                displayForAlgo.onAlgorithmStop();

                for i=2:this.NumDisplays
                    if i~=dispIdxForAlgo
                        enableAxis(this.Displays{i});
                    end
                end
            end
        end

        function installContextMenu(this)
            allDisplays=this.Displays;
            for i=2:numel(allDisplays)
                installContextMenu(allDisplays{i});
            end
        end

        function close(this)





            allDisplays=this.Displays;
            for i=1:numel(allDisplays)
                closeFig(allDisplays{i});
            end
        end
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

        function showDisplay(this,name)
            [dispExists,dispIdx]=doesNameExist(this,name);
            if dispExists
                makeFigureVisible(this.Displays{dispIdx});
            end
        end

        function hideDisplay(this,name)
            [dispExists,dispIdx]=doesNameExist(this,name);
            if dispExists
                makeFigureInvisible(this.Displays{dispIdx});
            end
        end

        function showDefaultSignalDisplay(this)
            makeFigureVisible(this.Displays{1});
        end

        function tf=isOnlyOneDisplayTabVisible(this)

            numDisplayVisible=0;
            for i=1:this.NumDisplays
                numDisplayVisible=numDisplayVisible+double(isPanelVisible(this.Displays{i}));
                if numDisplayVisible>1
                    tf=false;
                    return;
                end
            end
            if numDisplayVisible==1
                tf=true;
            else
                tf=false;
            end
        end

        function setMode(this,mode,selectedItemInfo)

            for i=2:this.NumDisplays
                this.Displays{i}.setMode(mode,selectedItemInfo);
            end
        end












        function updateLabelSelection(this,selectedLabel)
            for i=2:this.NumDisplays
                this.Displays{i}.updateLabelSelection(selectedLabel);
            end
        end

        function modifyLabelInstanceSelection(this,selectedLabel)
            for i=2:this.NumDisplays
                this.Displays{i}.modifyLabelInstanceSelection(selectedLabel);
            end
        end






















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






















        function TF=isUndoAvailable(this)
            if this.NumDisplays==1
                TF=false;
                return;
            end
            TF=false(this.NumDisplays,1);
            for dispIdx=2:this.NumDisplays
                TF(dispIdx)=this.Displays{dispIdx}.isUndoAvailable();
            end

            selectedDispId=this.getSelectedDisplayId();
            if~isempty(selectedDispId)
                TF=TF(selectedDispId,1);
            end
        end


        function TF=isRedoAvailable(this)
            if this.NumDisplays==1
                TF=false;
                return;
            end
            TF=false(this.NumDisplays,1);
            for dispIdx=2:this.NumDisplays
                TF(dispIdx)=this.Displays{dispIdx}.isRedoAvailable();
            end

            selectedDispId=this.getSelectedDisplayId();
            if~isempty(selectedDispId)
                TF=TF(selectedDispId,1);
            end
        end


        function modifyLabelNameInCurrentROIs(this,oldLabelName,newLabelName)
            for dispIdx=2:this.NumDisplays
                modifyLabelNameInCurrentROIs(this.Displays{dispIdx},oldLabelName,newLabelName);
            end
        end


        function modifyLabelColorInCurrentROIs(this,labelname,newLabelColor)


            for dispIdx=2:this.NumDisplays
                modifyLabelColorInCurrentROIs(this.Displays{dispIdx},labelname,newLabelColor);
            end
        end


        function modifySublabelNameInCurrentROIs(this,labelName,oldSublabelName,newSublabelName)
            for dispIdx=2:this.NumDisplays
                modifySublabelNameInCurrentROIs(this.Displays{dispIdx},labelName,oldSublabelName,newSublabelName);
            end
        end


        function modifySublabelColorInCurrentROIs(this,labelName,sublabelName,newSublabelColor)


            for dispIdx=2:this.NumDisplays
                modifySublabelColorInCurrentROIs(this.Displays{dispIdx},labelName,sublabelName,newSublabelColor);
            end
        end


        function updateLabelInUndoRedoBuffer(this,newItemInfo,oldItemInfo,toUpdate)
            for dispIdx=2:this.NumDisplays
                updateLabelInUndoRedoBuffer(this.Displays{dispIdx},newItemInfo,oldItemInfo,toUpdate);
            end
        end


        function renameLabelInClipboard(this,newItemInfo,oldItemInfo)
            for dispIdx=2:this.NumDisplays
                renameLabelInClipboard(this.Displays{dispIdx},newItemInfo,oldItemInfo);
            end
        end


        function updatePixelLabelColorInCurrentFrame(this)


            for dispIdx=2:this.NumDisplays
                updatePixelLabelColorInCurrentFrame(this.Displays{dispIdx});
            end
        end


        function colorChangeInClipboard(this,newItemInfo,oldItemInfo)


            for dispIdx=2:this.NumDisplays
                colorChangeInClipboard(this.Displays{dispIdx},newItemInfo,oldItemInfo);
            end
        end


        function colorChangeInClipboardPixel(this,newItemInfo)


            for dispIdx=2:this.NumDisplays
                colorChangeInClipboardPixel(this.Displays{dispIdx},newItemInfo);
            end
        end


        function updateLabelVisibilityInUndoRedoBuffer(this,newItemInfo)
            for dispIdx=2:this.NumDisplays
                updateLabelVisibilityInUndoRedoBuffer(this.Displays{dispIdx},newItemInfo);
            end
        end


        function roiVisibilityChangeInClipboard(this,newItemInfo)

            for dispIdx=2:this.NumDisplays
                roiVisibilityChangeInClipboard(this.Displays{dispIdx},newItemInfo);
            end
        end


        function roiVisibilityChangeInClipboardPixel(this,newItemInfo)


            for dispIdx=2:this.NumDisplays
                roiVisibilityChangeInClipboardPixel(this.Displays{dispIdx},newItemInfo);
            end
        end


        function renameAttribInClipboard(this,attribData,newName)
            for dispIdx=2:this.NumDisplays
                renameAttribInClipboard(this.Displays{dispIdx},attribData,newName);
            end
        end


        function deletePixelLabelData(this,pixelID)
            for dispIdx=2:this.NumDisplays
                deletePixelLabelData(this.Displays{dispIdx},pixelID);
            end
        end


        function pasteSelectedROIs(~,fromDisplay,toDisplay)

            copiedROIsInGroup=fromDisplay.getCopiedROIsInGroup();
            toDisplay.pasteROIsInGroup(copiedROIsInGroup);

        end


        function pastePixelROIs(~,fromDisplay,toDisplay)

            copiedPixelROIsInGroup=fromDisplay.getCopiedPixelROIsInGroup();
            toDisplay.pastePixelROIsInGroup(copiedPixelROIsInGroup);

        end


        function copyPixelROIs(~,fromDisplay,toDisplay)

            copiedPixelROIsInGroup=fromDisplay.getCopiedPixelROIsInGroup();
            toDisplay.pastePixelROIsInGroup(copiedPixelROIsInGroup);

        end


        function resetCopyPastePixelContextMenu(this)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    resetCopyPastePixelContextMenu(display);
                end
            end
        end


        function enableContextMenuCopyPastePixel(this,numPixelROIDefn)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    enableContextMenuCopyPastePixel(display,numPixelROIDefn);
                end
            end
        end


        function disableContextMenuCopyPastePixel(this,numPixelROIDefn,roiData)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    disableContextMenuCopyPastePixel(display,numPixelROIDefn,roiData);
                end
            end
        end


        function setPixelLabelMode(this,sz)

            firstTime=true;
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    showTutorial=firstTime;
                    setPixelLabelMode(display,sz,showTutorial);
                    firstTime=false;
                end
            end
        end


        function updateSuperpixelLayout(this,count,disableLayout)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    updateSuperpixelLayout(display,count,disableLayout);
                end
            end
        end

        function setSuperpixelParams(this,count)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    setSuperpixelParams(display,count);
                end
            end
        end

        function updateSuperpixelState(this)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    updateSuperpixelState(display);
                end
            end
        end

        function updateSuperpixelLayoutState(this,state)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    updateSuperpixelLayoutState(display,state);
                end
            end
        end

        function updateBrushOutline(this)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    updateBrushOutline(display,[]);
                end
            end
        end

        function disableBrushOutline(this)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    disableBrushOutline(display);
                end
            end
        end

        function resetSuperPixelLayout(this)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    resetSuperPixelLayout(display);
                end
            end
        end

        function updatePixelLabelerLookup(this,color,pixelLabelID)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    updatePixelLabelerLookup(display,color,pixelLabelID);
                end
            end
        end


        function updateActivePolygonColorInCurrentFrame(this,labelName,color)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    updateActivePolygonColorInCurrentFrame(display,labelName,color);
                end
            end
        end


        function updateActivePolygonNameInCurrentFrame(this,oldLabelname,newLabelname)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    updateActivePolygonNameInCurrentFrame(display,oldLabelname,newLabelname);
                end
            end
        end

        function setPixelLabelMarkerSize(this,mode)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    setPixelLabelMarkerSize(display,mode);
                end
            end
        end


        function setPixelLabelAlpha(this,alpha)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    setPixelLabelAlpha(display,alpha);
                end
            end
        end

        function setPolygonLabelAlpha(this,alpha)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPolygonSupported
                    setPolygonLabelAlpha(display,alpha);
                end
            end
        end

        function sendPolygonToBack(this)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPolygonSupported
                    sendPolygonToBack(display);
                end
            end
        end

        function bringPolygonToFront(this)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPolygonSupported
                    bringPolygonToFront(display);
                end
            end
        end


        function info=getSignalDisplayInfo(this)

            if this.NumDisplays<=1
                info=[];
                return;
            end

            info=struct('SignalName','','SignalType',[],'IsSelected',false);
            info=repmat(info,[this.NumDisplays-1,1]);
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                info(1).SignalName=display.Name;
                info(1).SignalType=display.SignalType;
                info(1).IsSelected=strcmp(this.PrevActiveDisplayName,display.Name);
            end
        end


        function[selectedSignalName,selectedSignalType,signalNames,selectedSignalId]=getSignalInfoFromDisplay(this)

            if this.NumDisplays<=1
                [selectedSignalName,selectedSignalType,signalNames]=deal('',[],'');
                return;
            end

            signalNames=cell(1,this.NumDisplays-1);
            selectedSignalType=repmat(vision.labeler.loading.SignalType.Image,[this.NumDisplays-1,1]);
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                signalNames{dispIdx-1}=display.Name;
                if strcmp(this.PrevActiveDisplayName,display.Name)
                    selectedSignalName=display.Name;
                    selectedSignalId=(dispIdx-1);
                    selectedSignalType=display.SignalType;
                end
            end
        end

        function changeVisibilitySelectedROI(this,selectedLabelData,selectedItemInfo)
            for dispIdx=2:this.NumDisplays
                changeVisibilitySelectedROI(this.Displays{dispIdx},selectedLabelData,selectedItemInfo);
            end
        end

        function changeVisibilitySelectedPixelROI(this,selectedLabelData,selectedItemInfo)
            for dispIdx=2:this.NumDisplays
                display=this.Displays{dispIdx};
                if display.IsPixelSupported
                    changeVisibilitySelectedPixelROI(this.Displays{dispIdx},selectedLabelData,selectedItemInfo);
                end
            end
        end





















    end




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
    methods
        function isANewDispSelected=appClientActivated(this,~,evtData)

            isANewDispSelected=false;
            clientName=evtData.ClientName;
            if this.NumDisplays<2
                return;
            end

            if isASignalDisplay(this,clientName)
                if sameAsLastActiveDisplay(this,clientName)
                    return;
                else
                    isANewDispSelected=true;
                    this.IsANewDispSelected=isANewDispSelected;

                    changeDisplayBorderROIColor(this,clientName);






                    this.PrevActiveDisplayName=clientName;
                end
            else

            end
        end

        function reset(~)



        end

    end



    methods(Access=private)

        function tf=isASignalDisplay(this,displayName)

            tf=(this.NumDisplays>1)&&...
            (~isNameUnused(this,displayName))&&...
            (~isNoneDisplay(this,displayName));
        end

        function tf=sameAsLastActiveDisplay(this,currDisplayName)
            tf=strcmp(currDisplayName,this.PrevActiveDisplayName);
            if~tf
                this.IsANewDispSelected=false;
            end
        end

        function createDefaultDisplay(this,hFig,toolType,defaultName)
            if isempty(this.Displays)

                createAndAddDisplay(this,hFig,displayType.None,toolType,defaultName);
            end
        end

        function tf=isNoneDisplay(this,name)

            tf=false;
            if this.NumDisplays>0
                tf=strcmp(this.Displays{1}.Name,name);
            end
        end

        function tf=isNameUnused(this,name)

            tf=true;
            for i=1:this.NumDisplays
                if hasSameName(this.Displays{i},name)
                    tf=false;
                    return;
                end
            end
        end

        function[tf,dispIdx]=doesNameExist(this,name)

            tf=false;
            dispIdx=0;
            for i=1:this.NumDisplays
                if hasSameName(this.Displays{i},name)
                    tf=true;
                    dispIdx=i;
                    return;
                end
            end
        end
    end
end
