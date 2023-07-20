classdef LabelerTool<vision.internal.labeler.tool.LabelerTool





    properties
SignalLoadController
    end

    methods

        function this=LabelerTool(title,instanceName)
            this@vision.internal.labeler.tool.LabelerTool(title,instanceName);
        end
    end



    methods

        function doROILabelAdditionCallback(this,~,~)




            if((this.ROILabelSetDisplay.NumItems<1)&&this.ShowLabelTypeTutorial)
                createLabelTypeTutorialDialog(this);
            end





            labelAddMode=true;
            dlg=getROILabelDefinitionDialog(this,labelAddMode);
            wait(dlg);

            if~dlg.IsCanceled


                data=dlg.getDialogData();
                roiLabel=data.Label;
                hFig=getDefaultFig(this.Container);

                if~this.Session.isValidName(roiLabel.Label)
                    errorMessage=vision.getMessage('vision:labeler:LabelNameExistsDlgMsg',roiLabel.Label);
                    dialogName=getString(message('vision:labeler:LabelNameExistsDlgName'));
                    vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                    return;
                end

                if roiLabel.ROI==lidarLabelType.Voxel

                    roiLabel.VoxelLabelID=this.Session.getVoxelLabels();


                    updateVoxelLabelerLookup(this.DisplayManager,roiLabel.Color,roiLabel.VoxelLabelID);


                    data.Label=this.Session.addROILabel(roiLabel,hFig);
                    updateOnLabelAddition(this.ROILabelSetDisplay,data,...
                    this.Session.ROILabelSet);

                else

                    data.Label=this.Session.addROILabel(roiLabel,hFig);

                    updateOnLabelAddition(this.ROILabelSetDisplay,data,...
                    this.Session.ROILabelSet);





                end
            end


            setModeFromToolstrip(this);

            this.updateToolstrip();
        end


        function doVoxelLabelIsChanged(this,~,data)




            selectedDisplay=getSelectedDisplay(this);
            if isempty(selectedDisplay)
                return;
            end

            signalName=selectedDisplay.Name;



            if(isa(data,'lidar.internal.labeler.tool.AlgorithmSetupHelperVoxelLabelEventData')||...
                isa(data,'lidar.internal.labeler.tool.VoxelLabelEventData'))


                if hasVoxelLabel(this.Session)
                    signalName=data.Source.Name;
                    if data.UpdateUndoRedo

                        currentIndex=getCurrentFrameIndex(this,signalName);
                        currentROIs=selectedDisplay.getCurrentROIs();
                        selectedDisplay.updateUndoOnLabelChange(currentIndex,currentROIs,...
                        vision.internal.labeler.tool.LabelTypeUndoRedo.PixelLabel);
                    end
                    updateVoxelLabelAnnotations(this,signalName,data.Data);
                    if~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay)
                        updateVisualSummaryROICount(this,signalName,[],data);
                    end
                end


            elseif isa(data,'vision.internal.labeler.tool.ROILabelEventData')



                currentROIs=selectedDisplay.getCurrentROIs();
                currentROIs=deleteOrphanSublabelInstances(this,selectedDisplay,currentROIs);

                currentIndex=getCurrentFrameIndex(this,signalName);


                selectedDisplay.updateUndoOnLabelChange(currentIndex,currentROIs,...
                vision.internal.labeler.tool.LabelTypeUndoRedo.ShapeLabel);
                updateSessionForGivenROIs(this,selectedDisplay,currentROIs,data);
                if~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay)
                    updateVisualSummaryROICount(this,signalName,[],data);
                end
            else








            end

            doROIInstanceIsSelected(this);
            updateProjectedViewStatus(this);
        end


        function updateVoxelLabelAnnotations(this,signalName,labelData)

            thisDisplay=this.DisplayManager.getDisplay(signalName);


            if isempty(this.Session.TempDirectory)

                foldername=setTempDirectory(this);
            else
                isFileNoPath=(isempty(regexp(labelData.Position,'/','once'))&&...
                isempty(regexp(labelData.Position,'\','once')));

                if isFileNoPath
                    foldername=this.Session.TempDirectory;
                else
                    foldername=[];
                end
            end

            if~isempty(foldername)

                labelData.Position=fullfile(foldername,labelData.Position);
                setLabelMatrixFilename(thisDisplay,labelData.Position);
            end



            labelNames=labelData.Label;
            labelPositions=labelData.Position;
            index=labelData.Index;

            TF=writeData(this.Session,signalName,labelNames,index);




            if~TF
                oldDirectory=this.Session.TempDirectory;
                [~,name]=fileparts(tempname);
                foldername=vision.internal.labeler.tool.selectDirectoryDialog(name);
                if~isempty(foldername)

                    labelData.Position=fullfile(foldername,labelData.Position);
                    setLabelMatrixFilename(thisDisplay,labelData.Position);
                end
                setTempDirectory(this.Session,foldername);
                importVoxelLabelData(this.Session);
                if isfolder(oldDirectory)
                    rmdir(oldDirectory,'s');
                end
            end


            setVoxelLabelAnnotation(this.Session,signalName,index,labelPositions);
        end



        function success=saveSession(this,fileName)


            if nargin<2
                if isempty(this.Session.FileName)||~exist(this.Session.FileName,'file')
                    fileName=vision.internal.uitools.getSessionFilename(...
                    this.SessionManager.DefaultSessionFileName);
                    if isempty(fileName)
                        success=false;
                        return;
                    end
                else
                    fileName=this.Session.FileName;
                end
            end

            if hasVoxelLabel(this.Session)
                finalize(this);
            end
            hFig=getDefaultFig(this.Container);
            success=saveSession(this.SessionManager,this.Session,fileName,hFig);

            if hasShapeLabels(this.Session)
                verfiyROIVisibility(this.Session);
            end

            if success
                progressDlgTitle=vision.getMessage('vision:labeler:SavingSessionTitle');
                pleaseWaitMsg=vision.getMessage('vision:labeler:PleaseWait');
                waitBarObj=vision.internal.labeler.tool.ProgressDialog(hFig,...
                progressDlgTitle,pleaseWaitMsg);

                savingSessionMsg=vision.getMessage('vision:labeler:SavingSession');
                [~,fileName]=fileparts(fileName);

                waitBarObj.setParams(0.33,savingSessionMsg);
                titleStr=getString(message(...
                'vision:labeler:ToolTitleWithSession',this.ToolName,fileName));
                setTitleBar(this,titleStr);

                this.Session.IsChanged=false;

                this.setStatusText(vision.getMessage('vision:labeler:SaveSessionStatus',fileName));
                close(waitBarObj);
            end

        end


        function saveSessionAs(this)

            fileName=vision.internal.uitools.getSessionFilename(...
            this.SessionManager.DefaultSessionFileName);
            if~isempty(fileName)
                [pathstr,name,~]=fileparts(fileName);
                sessionPath=fullfile(pathstr,['.',name,'_SessionData']);

                if isfolder(sessionPath)
                    rmdir(sessionPath,'s');
                end

                setIsVoxelLabelChangedAll(this.Session);

                this.saveSession(fileName);
                this.Session.IsChanged=false;
            end

        end


        function exportLabelAnnotationsToFile(this)

            wait(this.Container);

            resetWait=onCleanup(@()resume(this.Container));

            finalize(this);
            hFig=getDefaultFig(this.Container);

            if hasVoxelLabel(this.Session)
                variableName='gTruth';
                dlgTitle=vision.getMessage('vision:labeler:ExportLabelsToFile');
                toFile=true;
                exportDlg=lidar.internal.labeler.tool.ExportVoxelLabelDlg(...
                this.Tool,variableName,dlgTitle,this.Session.getVoxelLabelDataPath,toFile);
                wait(exportDlg);
                proceed=~exportDlg.IsCanceled;
                if proceed
                    TF=exportVoxelLabelData(this.Session,exportDlg.CreatedDirectory);

                    pathName=exportDlg.VarPath;
                    this.Session.setVoxelLabelDataPath(pathName);
                    fileName=exportDlg.VarName;

                    if~TF
                        errorMessage=getString(message('vision:labeler:UnableToExportDlgMessage'));
                        dialogName=getString(message('vision:labeler:UnableToExportDlgName'));
                        vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                        return;
                    end
                end

            else
                [fileName,pathName,proceed]=uiputfile('*.mat',...
                vision.getMessage('vision:labeler:ExportLabels'));
            end

            if proceed
                this.setStatusText(vision.getMessage('vision:labeler:ExportToFileStatus',fileName));

                gTruth=exportLabelAnnotations(this.Session);
                gTruth=appendCustomLabels(this,gTruth);
                if hasVoxelLabel(this.Session)
                    refreshVoxelLabelAnnotation(this.Session);
                end
                try
                    save(fullfile(pathName,fileName),'gTruth');
                catch
                    errorMessage=getString(message('vision:labeler:UnableToExportDlgMessage'));
                    dialogName=getString(message('vision:labeler:UnableToExportDlgName'));
                    vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                end

                this.setStatusText('');

            end
        end





        function updateVoxelColorLookup(this)



            for i=1:this.Session.ROILabelSet.NumLabels
                roiLabelType=this.Session.ROILabelSet.DefinitionStruct(i).Type;
                roiLabelColor=this.Session.ROILabelSet.DefinitionStruct(i).Color;
                voxelLabelID=this.Session.ROILabelSet.DefinitionStruct(i).VoxelLabelID;

                if isequal(roiLabelType,lidarLabelType.Voxel)
                    updateVoxelLabelerLookup(this.DisplayManager,roiLabelColor,...
                    voxelLabelID);
                end
            end
        end
    end





    methods

        function userLabels=checkUserLabels(this,userLabels,isValid,imSize)






            if isValid
                validROILabelNames=this.AlgorithmSetupHelper.ValidROILabelNames;
                validFrameLabelNames=this.AlgorithmSetupHelper.ValidFrameLabelNames;

                if iscategorical(userLabels)

                    isValidCategorical=~isempty(userLabels);
                    if~isValidCategorical
                        error(message('vision:labeler:invalidCategoricalFromUser'));
                    end



                    categorySet=categories(userLabels);
                    unknownCats=setdiff(categorySet,validROILabelNames);

                    if isempty(setdiff(categorySet,unknownCats))

                        networkCategories=string();
                        for idx=1:5:length(categorySet)
                            if idx+5<=length(categorySet)
                                networkCategories=networkCategories+newline+strjoin(string(categorySet(idx:idx+5)),', ')+", ";
                            else
                                networkCategories=networkCategories+newline+strjoin(string(categorySet(idx+1:length(categorySet))),', ');
                            end
                        end
                        error(message('vision:labeler:invalidCategoricalFromNetwork',networkCategories));
                    end


                    if~isempty(unknownCats)
                        userLabels=removecats(userLabels,unknownCats);
                    end

                else
                    for n=1:numel(userLabels)

                        labelName=userLabels(n).Name;
                        lblType=userLabels(n).Type;

                        isValidROI=any(strcmp(labelName,validROILabelNames));



                        isValidAttrib=true;
                        if isValidROI
                            roiLabel=this.Session.queryROILabelData(labelName);

                            if isequal(userLabels(n).Type,labelType.Cuboid)
                                roiLabel.ROI=labelType.Cuboid;
                            end
                            isValidROI=isequal(roiLabel.ROI,lblType);


                            hasAttribDefined=this.Session.hasAttributeDefined(labelName);
                            if(hasAttribDefined)
                                validROIAttribData=this.Session.queryROIAttributeFamilyData(labelName,'');



                                [isValidAttrib,outLbl]=validateAndFillAttribute(this,validROIAttribData,userLabels(n));
                                if isfield(outLbl,'Attributes')
                                    userLabels(n).Attributes=[];
                                end
                                userLabels(n)=outLbl;
                            else

                                if isfield(userLabels(n),'Attributes')
                                    error(message('vision:labeler:undefinedAttributeInAlgo'));
                                end
                            end
                        end




                        isValidFr=any(strcmp(labelName,validFrameLabelNames))...
                        &&isequal(lblType,labelType.Scene);



                        isValid=xor((isValidROI&&isValidAttrib),isValidFr);

                        if~isValid&&(isValidROI&&~isValidAttrib)
                            error(message('vision:labeler:invalidAttributeFromUser'));
                        end
                    end
                end
            end

            if~isValid
                error(message('vision:labeler:invalidLabelFromUser'));
            end
        end


        function endAutomation(this)

            wait(this.Container);
            resetWait=onCleanup(@()resume(this.Container));


            if hasVoxelLabel(this.Session)

                temppath=this.Session.TempDirectory;
                pathstr=fileparts(temppath);
                setTempDirectory(this.Session,pathstr);


                if isfolder(temppath)
                    rmdir(temppath,'s');
                end
            end

            hideModalAlgorithmTab(this);

            unfreezeSublabelItems=true;
            unfreezeLabelPanelsWhenEndingAutomation(this,unfreezeSublabelItems);
        end
    end


    methods(Access=protected)

        function itemInfo=getItemInfoFromData(~,itemData)


            itemInfo.IsGroup=false;
            itemInfo.IsVoxelLabel=false;
            itemInfo.IsRectOrCubeLabel=false;
            itemInfo.IsLineOrLine3DLabel=false;
            itemInfo.IsLabel=false;
            itemInfo.LabelName='';
            itemInfo.SublabelName='';
            itemInfo.Color=[];

            if isempty(itemData)
                return;
            end

            if isstruct(itemData)&&isfield(itemData,'Group')
                itemInfo.IsGroup=true;
                return;
            end

            if(isprop(itemData,'ROI')&&(itemData.ROI==lidarLabelType.Voxel))
                itemInfo.IsLabel=true;
                itemInfo.IsVoxelLabel=true;
            elseif(isprop(itemData,'ROI')&&~isprop(itemData,'LabelName')&&...
                isRectOrCubeLabelDef(itemData.ROI))
                itemInfo.IsLabel=true;
                itemInfo.IsRectOrCubeLabel=true;
            elseif(isprop(itemData,'ROI')&&~isprop(itemData,'LabelName')&&...
                isLineOrLine3DLabelDef(itemData.ROI))
                itemInfo.IsLabel=true;
                itemInfo.IsLineOrLine3DLabel=true;
            else
                itemInfo.IsLabel=~isprop(itemData,'LabelName');
                itemInfo.IsVoxelLabel=false;
            end

            if itemInfo.IsLabel
                itemInfo.LabelName=itemData.Label;
                itemInfo.SublabelName='';
            end
            itemInfo.Color=itemData.Color;
        end


        function selectedItemInfo=getSelectedItemInfo(this)
            itemInfo=this.getSelectedROIPanelItemInfo();

            if isempty(itemInfo.LabelName)

                if~itemInfo.IsGroup
                    isAnyItemSelected=false;
                else
                    isAnyItemSelected=true;
                end
                roiItemDataObj=[];

            else
                isAnyItemSelected=true;
                if itemInfo.IsLabel

                    roiItemDataObj=this.Session.queryROILabelData(itemInfo.LabelName);
                end

            end

            selectedItemInfo.isAnyItemSelected=isAnyItemSelected;
            selectedItemInfo.isVoxelLabelItemSelected=itemInfo.IsVoxelLabel;
            selectedItemInfo.isRectOrCubeLabelItemSelected=itemInfo.IsRectOrCubeLabel;
            selectedItemInfo.isLineOrLine3DLabelItemSelected=itemInfo.IsLineOrLine3DLabel;
            selectedItemInfo.isLabelSelected=itemInfo.IsLabel;
            selectedItemInfo.roiItemDataObj=roiItemDataObj;
            selectedItemInfo.isGroup=itemInfo.IsGroup;
        end




        function updateAttributesSublabelsPanel(this)


            N=numROIInstanceSelected(this);
            singleROIselected=false;

            if N==1
                selectedDisplay=getSelectedDisplay(this);
                signalName=selectedDisplay.Name;
                [labelName,sublabelName,roiData]=this.getFirstSelectedROIInstanceInfo();
                itemColor=roiData.Color;
                singleROIselected=true;
                isVoxelLabelItemSelected=false;
                isGroupItemSelected=false;
            else
                roiData=[];
                itemInfo=this.getSelectedROIPanelItemInfo();
                isVoxelLabelItemSelected=itemInfo.IsVoxelLabel;
                labelName=itemInfo.LabelName;
                sublabelName=itemInfo.SublabelName;
                itemColor=itemInfo.Color;
                isGroupItemSelected=itemInfo.IsGroup;
            end

            if~isGroupItemSelected

                this.AttributesSublabelsDisplay.updatePanelDetail(labelName,sublabelName,itemColor);


                attribDefData=this.Session.queryROIAttributeFamilyData(labelName,sublabelName);
                if singleROIselected
                    attribInstanceData=getAttributeInstanceValue(this,signalName,roiData.ID,attribDefData);
                else
                    attribInstanceData=attribDefData;
                end

                this.AttributesSublabelsDisplay.updateAttribInAttributesSublabelsPanel(labelName,sublabelName,attribDefData,attribInstanceData);
                if singleROIselected
                    this.AttributesSublabelsDisplay.enableAttribPanel();
                else
                    this.AttributesSublabelsDisplay.disableAttribPanel();
                end




                if isempty(sublabelName)
                    sublabelNames=this.Session.queryROISublabelFamilyNames(labelName);
                    if singleROIselected

                        numSublabelInstances=getNumSublabelInstances(this,signalName,labelName,roiData.ID,sublabelNames);
                    else
                        numSublabelInstances=zeros(1,numel(sublabelNames));
                    end

                    this.AttributesSublabelsDisplay.updateSublblInAttributesSublabelsPanel(labelName,sublabelNames,isVoxelLabelItemSelected,numSublabelInstances,singleROIselected);
                end
            end
        end


        function deleteROILabelTree(this,labelName,isVoxelLabelSelected)

            if isVoxelLabelSelected
                roiData=this.Session.queryROILabelData(labelName);

                finalize(this);
                deleteVoxelLabelData(this.Session,roiData.VoxelLabelID);
                if this.AreSignalsLoaded
                    this.DisplayManager.deleteVoxelLabelData(roiData.VoxelLabelID);
                end

                selectStruct.Label=labelName;
                this.deleteROISummaryItem([],selectStruct);
            end

            if(~isVoxelLabelSelected)

                removeSublabelWithAttributes(this,labelName);


                removeAttributesOfLabel(this,labelName);

                deleteAttribSublabelPanelEntries(this);
            else

            end

            this.Session.deleteROILabel(labelName);


        end


        function doROIPanelItemSelectionCallback(this,varargin)



            selectedItemInfo=getSelectedItemInfo(this);

            isAnyItemSelected=selectedItemInfo.isAnyItemSelected;
            isVoxelLabelItemSelected=selectedItemInfo.isVoxelLabelItemSelected;
            isLabelSelected=selectedItemInfo.isLabelSelected;
            roiItemDataObj=selectedItemInfo.roiItemDataObj;
            isGroupItemSelected=selectedItemInfo.isGroup;

            if isAnyItemSelected

                controlVisOfSublabelAttribCreateButtons(this,isAnyItemSelected,...
                isVoxelLabelItemSelected,isLabelSelected,isGroupItemSelected);
                if~isGroupItemSelected
                    updateAttributesSublabelsPanelIfNeeded(this);
                else
                    updatePanelDetail(this.AttributesSublabelsDisplay);
                    updateAttribInAttributesSublabelsPanel(this.AttributesSublabelsDisplay);
                    updateSublblInAttributesSublabelsPanel(this.AttributesSublabelsDisplay);
                end

                setModeROIorNone(this,selectedItemInfo);


                if~isGroupItemSelected
                    this.DisplayManager.updateLabelSelection(roiItemDataObj);
                    if~this.IsCallFromROIInstanceSelection
                        this.DisplayManager.modifyLabelInstanceSelection(roiItemDataObj);
                    end
                    this.IsCallFromROIInstanceSelection=false;
                    setSingleSelectedROIInstanceParentUID(this);
                end


                this.IsCallFromFinalize=true;
                this.IsCallFromFinalize=false;

                if isVoxLabelDef(roiItemDataObj.ROI)||isLineOrLine3DLabelDef(roiItemDataObj.ROI)
                    this.DisplayManager.setClusterVisibility(false);
                else
                    this.DisplayManager.setClusterVisibility(true);
                end

                if~isGroupItemSelected
                    modifyItemMenuLabel(this,roiItemDataObj);
                end


                doUndoRedoUpdate(this);


                if~isempty(varargin)

                    this.DisplayManager.setPasteContextMenuVisibility();
                end



                if isRectOrCubeLabelDef(roiItemDataObj.ROI)
                    disableLineSection(this);
                    enableCuboidSection(this);
                    updateColormapSection(this);
                elseif isLineOrLine3DLabelDef(roiItemDataObj.ROI)
                    disableCuboidSection(this);
                    enableLineSection(this);
                    enableColormapSection(this);
                elseif isVoxLabelDef(roiItemDataObj.ROI)
                    disableCuboidSection(this);
                    disableLineSection(this);
                    disableProjectedView(this);
                    enableColormapSection(this);
                end
            end

        end

    end

    methods




        function doROIPanelItemDeletionCallback(this,~,data)


            itemInfo=getItemInfoFromData(this,data.Data);

            if itemInfo.IsGroup


                displayMessage=vision.getMessage('vision:labeler:DeletionGroupWarning');
                dialogName=vision.getMessage('vision:labeler:DeletionDefinitionWarningTitle');
                yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
                no=vision.getMessage('MATLAB:uistring:popupdialogs:No');
                hFig=getDefaultFig(this.Container);

                selection=vision.internal.labeler.handleAlert(hFig,'questionWithWaitDlg',displayMessage,dialogName,...
                this.Tool,yes,no,yes);

                if strcmpi(selection,yes)
                    this.ROILabelDlgRequired=false;
                    updateOnGroupDelete(this.ROILabelSetDisplay,data,this.Session.ROILabelSet);
                    this.ROILabelDlgRequired=true;
                end
            else
                deleteROILabelSublabelItems(this,itemInfo,data,this.ROILabelDlgRequired);
            end

        end




        function deleteROILabelSublabelItems(this,itemInfo,data,dlgRequired)
            deleteAttrib=~isempty(data.AttributeName);
            hFig=this.Container.getDefaultFig;
            yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
            no=vision.getMessage('MATLAB:uistring:popupdialogs:No');

            if dlgRequired
                displayMessage=warningMessage(this,itemInfo.IsLabel,deleteAttrib);
                dialogName=vision.getMessage('vision:labeler:DeletionDefinitionWarningTitle');

                selection=vision.internal.labeler.handleAlert(hFig,'questionWithWaitDlg',displayMessage,dialogName,...
                this.Tool,yes,no,yes);
            else
                selection=yes;
            end

            if strcmpi(selection,yes)
                if itemInfo.IsLabel
                    if deleteAttrib
                        deleteROILabelAttribute(this,itemInfo.LabelName,data);
                    else
                        deleteROILabelTree(this,itemInfo.LabelName,itemInfo.IsVoxelLabel);
                        updateOnLabelDelete(this.ROILabelSetDisplay,data,this.Session.ROILabelSet);

                        if itemInfo.IsLineOrLine3DLabel
                            disableLineSection(this)
                        elseif itemInfo.IsRectOrCubeLabel
                            disableCuboidSection(this);
                        end
                    end
                end


                if deleteAttrib
                    this.ROILabelSetDisplay.deleteItemAttribute(data.Index,data.AttributeName);
                    deleteAttribSublabelPanelItem(this,itemInfo.LabelName,itemInfo.SublabelName,data.AttributeName);
                else
                    this.updateToolstrip();

                    setModeFromToolstrip(this);


                    this.redrawInteractiveROIs();



                    this.resetUndoRedoOnDeletion();

                    if~isempty(this.ProjectedViewDisplay)
                        if isvalid(this.ProjectedViewDisplay)




                            emptyROISrc=struct;
                            emptyROISrc.CurrentROIs=[];
                            if itemInfo.IsLineOrLine3DLabel
                                activateProjectedViewLine(this.ProjectedViewDisplay,emptyROISrc,[],[],[],[]);
                            else
                                activateProjectedViewCuboid(this.ProjectedViewDisplay,emptyROISrc,[],[],[],[]);
                            end
                        end
                    end
                end


                if itemInfo.IsLabel
                    this.DisplayManager.removeLabelFromCopyClipboard(itemInfo.LabelName);
                end


                this.DisplayManager.refreshClipboard();

                selectedDisplay=getSelectedDisplay(this);
                if~isempty(selectedDisplay)
                    enablePasteFlag=selectedDisplay.copySelectedROIs();

                    if~selectedDisplay.IsCuboidSupported
                        copiedROIsTypes=selectedDisplay.copiedROIsType();
                    else
                        copiedROIsTypes=getString(message('vision:trainingtool:PastePopup'));
                    end
                    setPasteMenuState(this.DisplayManager,selectedDisplay.SignalType,copiedROIsTypes,enablePasteFlag);
                end

                if(this.ROILabelSetDisplay.NumItems==0)
                    disableSublabelAttributeButtons(this);
                    removeAttributeSublabelPanel(this);
                else
                    selectedItemInfo=getSelectedItemInfo(this);

                    isAnyItemSelected=selectedItemInfo.isAnyItemSelected;
                    isVoxelLabelItemSelected=selectedItemInfo.isVoxelLabelItemSelected;
                    isLabelSelected=selectedItemInfo.isLabelSelected;
                    isGroupItemSelected=selectedItemInfo.isGroup;

                    controlVisOfSublabelAttribCreateButtons(this,isAnyItemSelected,isVoxelLabelItemSelected,isLabelSelected,isGroupItemSelected);
                    updateAttributesSublabelsPanelIfNeeded(this);
                end
            end
        end


        function redrawInteractiveROIs(this)
            if this.AreSignalsLoaded
                for i=1:this.NumSignalsForDisplay
                    displayId=i+1;
                    readerId=i;
                    thisdisplay=this.DisplayManager.getDisplayFromIdNoCheck(displayId);
                    sz=thisdisplay.sizeofImage();
                    currentTime=getRangeSliderCurrentTime(this);
                    signalName=thisdisplay.Title;
                    imageInfo=this.SignalLoadController.readFrame(currentTime,signalName);
                    imageData=imageInfo{1}.Data;
                    frameIdx=getCurrentFrameIndex(this,readerId);
                    [data,exceptions]=this.Session.readDataBySignalId(readerId,frameIdx,imageData);

                    if isempty(exceptions)
                        thisdisplay.wipeROIs();
                        thisdisplay.redrawInteractiveROIs(data);
                    end
                end
            end
        end
    end

    methods(Access=protected)

        function doROIPanelItemModificationCallback(this,~,data)


            itemInfo=getItemInfoFromData(this,data.Data);

            isLabelItemSelected=itemInfo.IsLabel;
            isGroupItemSelected=itemInfo.IsGroup;
            labelName=itemInfo.LabelName;
            sublabelName=itemInfo.SublabelName;
            color=itemInfo.Color;

            itemID=data.Index;

            if isLabelItemSelected
                roiLabel=this.Session.ROILabelSet.queryLabel(labelName);
                sublabelNames=this.Session.queryROISublabelFamilyNames(labelName);



                labelAddMode=false;
                dlg=getROILabelDefinitionDialog(this,labelAddMode,roiLabel,sublabelNames);
            elseif isGroupItemSelected
                labelGroupName=data.Data.Group;
                dlg=vision.internal.labeler.tool.GroupModifyDialog(...
                this.Tool,labelGroupName,this.Session.ROILabelSet,this.Container.getDefaultFig);
            end

            wait(dlg);

            if~dlg.IsCanceled

                dialogData=dlg.getDialogData();

                if isLabelItemSelected



                    toUpdate=[dlg.ColorChangedInEditMode;dlg.NameChangedInEditMode];

                    dialogData.Color=dlg.Color;

                    roiLabel=dialogData.Label;
                    if~isempty(data.Data.VoxelLabelID)
                        roiLabel.VoxelLabelID=data.Data.VoxelLabelID;
                    end

                    if dlg.NameChangedInEditMode
                        oldSelectionInfo=struct('IsLabelItemSelected',isLabelItemSelected,...
                        'LabelName',labelName,...
                        'SublabelName',sublabelName,...
                        'Color',color);

                        if~this.Session.isValidName(roiLabel.Label)
                            hFig=getDefaultFig(this.Container);
                            errorMessage=vision.getMessage('vision:labeler:LabelNameExistsDlgMsg',roiLabel.Label);
                            dialogName=getString(message('vision:labeler:LabelNameExistsDlgName'));
                            vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                            return;
                        end
                        modifyLabelOrSublabelName(this,roiLabel,oldSelectionInfo);
                        this.DisplayManager.updateLabelInUndoRedoBuffer(roiLabel,oldSelectionInfo,toUpdate);
                        this.DisplayManager.renameLabelInClipboard(roiLabel,oldSelectionInfo);

                        if toUpdate(1)&&toUpdate(2)

                            labelName=roiLabel.Label;
                        end
                    end

                    if dlg.ColorChangedInEditMode
                        oldSelectionInfo=struct('IsLabelItemSelected',isLabelItemSelected,...
                        'LabelName',labelName,...
                        'SublabelName',sublabelName,...
                        'Color',color);
                        modifyLabelOrSublabelColor(this,roiLabel,oldSelectionInfo);
                        this.DisplayManager.updateLabelInUndoRedoBuffer(roiLabel,oldSelectionInfo,toUpdate);
                        if~isequal(roiLabel.ROI,lidarLabelType.Voxel)
                            this.DisplayManager.colorChangeInClipboard(roiLabel,oldSelectionInfo);
                        else


                        end
                    end

                    if dlg.DescriptionChangedInEditMode
                        modifyItemDescription(this.ROILabelSetDisplay,itemID,roiLabel);

                        updateROILabelDescription(this.Session,...
                        roiLabel.Label,roiLabel.Description);
                    end

                    if dlg.GroupChangedInEditMode
                        updateROILabelGroup(this.Session,roiLabel.Label,roiLabel.Group);


                        updateGroupOnLabelEdit(this.ROILabelSetDisplay,dialogData,...
                        this.Session.ROILabelSet);
                    end

                elseif isGroupItemSelected

                    if dialogData.GroupNameChanged
                        oldGroupName=data.Data.Group;
                        newGroupName=dialogData.Group;
                        updateROIGroupNames(this.Session,oldGroupName,newGroupName);
                        updateOnGroupNameChange(this.ROILabelSetDisplay,itemID,newGroupName);
                    end
                end

                this.Session.IsChanged=true;
            end
        end


        function modifyLabelOrSublabelColor(this,roiLabelSublabel,oldSelectionInfo)
            isLabelSelected=oldSelectionInfo.IsLabelItemSelected;

            if isLabelSelected
                oldLabelColor=oldSelectionInfo.Color;
                newLabelColor=roiLabelSublabel.Color;

                modifyLabelSelection(this,oldLabelColor,newLabelColor);

                modifyLabelColor(this,oldSelectionInfo.LabelName,newLabelColor);

                modifyColorInLabelDefinitionPanel(this,newLabelColor);
                if~isequal(roiLabelSublabel.ROI,lidarLabelType.Voxel)
                    modifyLabelColorInCurrentROIs(this,oldSelectionInfo.LabelName,newLabelColor);
                else
                    updateVoxelLabelerLookup(this.DisplayManager,newLabelColor,roiLabelSublabel.VoxelLabelID);
                    this.DisplayManager.updateVoxelLabelColorInCurrentFrame();
                end
            end

            updateAttributesSublabelsPanel(this);
        end



        function canImportLabels=importVoxelLabelHelper(this,gTruth,currentDefinitions)

            labelTypeCol='Type';

            isVoxelLabelType=findLabelTypeIdx(gTruth.LabelDefinitions.(labelTypeCol),lidarLabelType.Voxel);
            hasVoxelLabels=any(isVoxelLabelType);
            currentSessionHasVoxelLabels=this.Session.hasVoxelLabel;
            canImportLabels=false;
            hFig=getDefaultFig(this.Container);

            if hasVoxelLabels

                id=gTruth.LabelDefinitions{isVoxelLabelType,'VoxelLabelID'};

                isError=false;

                if~iscell(id)
                    id={id};
                elseif iscell(id{1,1})
                    voxelId=cell(numel(id),1);
                    for i=1:numel(id)
                        voxelId{i}=id{i,1}{1};
                    end
                    id=voxelId;
                end

                allScalarLabelIDs=all(cellfun(@(x)isscalar(x),id));
                if~allScalarLabelIDs
                    isError=true;
                else
                    anyLabelIDAreZero=any(cellfun(@(x)x==0,id));
                    if anyLabelIDAreZero
                        isError=true;
                    end
                end

                if isError
                    errorMessage='Voxel label IDs must be scalars and be between 1 and 255.';
                    dialogName='Invalid VoxelLabelID';
                    vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);

                    return;
                end

                if currentSessionHasVoxelLabels


                    labelDefinitions=gTruth.LabelDefinitions;


                    currentVoxelDefinitions=currentDefinitions(findLabelTypeIdx(currentDefinitions.(labelTypeCol),lidarLabelType.Voxel),:);
                    labelDefinitions=labelDefinitions(findLabelTypeIdx(labelDefinitions.(labelTypeCol),lidarLabelType.Voxel),:);

                    if height(currentVoxelDefinitions)~=height(labelDefinitions)

                        errorMessage=vision.getMessage('vision:labeler:ImportIncompatibleGroundTruthNameMismatch');
                        dialogName=vision.getMessage('vision:labeler:ImportError');
                        vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                        return

                    else

                        currentVoxelDefinitions=sortrows(currentVoxelDefinitions,'Name');
                        labelDefinitions=sortrows(labelDefinitions,'Name');

                        namesMatch=isequal(currentVoxelDefinitions.Name,labelDefinitions.Name);
                        idsMatch=isequal(currentVoxelDefinitions.VoxelLabelID,labelDefinitions.VoxelLabelID);

                        canImportLabels=namesMatch&&idsMatch;

                        if~namesMatch
                            errorMessage=vision.getMessage('vision:labeler:ImportIncompatibleGroundTruthNameMismatch');
                            dialogName=vision.getMessage('vision:labeler:ImportError');
                            vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                            return;
                        end

                        if~idsMatch
                            errorMessage=vision.getMessage('vision:labeler:ImportIncompatibleGroundTruthLabelIDMismatch');
                            dialogName=vision.getMessage('vision:labeler:ImportError');
                            vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
                            return;
                        end
                    end

                else
                    canImportLabels=true;
                end
            else

                canImportLabels=true;
            end
        end

        function doROIInstanceIsSelected(this,varargin)









            setSingleSelectedROIInstanceParentUID(this);



            selectedItemInfo=getSelectedItemInfo(this);
            roiItemDataObj=selectedItemInfo.roiItemDataObj;





            if~this.IsCallFromFinalize
                this.modifyLabelDefinitionSelection(roiItemDataObj);
            end

            selectedItemInfo=getSelectedItemInfo(this);

            isAnyItemSelected=selectedItemInfo.isAnyItemSelected;
            isVoxelLabelItemSelected=selectedItemInfo.isVoxelLabelItemSelected;
            isLabelSelected=selectedItemInfo.isLabelSelected;
            isGroupItemSelected=selectedItemInfo.isGroup;

            controlVisOfSublabelAttribCreateButtons(this,isAnyItemSelected,...
            isVoxelLabelItemSelected,isLabelSelected,isGroupItemSelected);



            selectedDisplay=getSelectedDisplay(this);
            if isempty(selectedDisplay)
                return;
            end
            updateAttributesSublabelsPanelIfNeeded(this);

            setModeROIorNone(this,selectedItemInfo);


            if isprop(selectedDisplay,'ProjectedView')
                updateProjectedViewStatus(this);
            end
        end

        function newDisplay=addNewDisplayAsTab(this,dispType,signalName)
            toolType=getToolType(this);

            addNewSignalFigure(this.Container,signalName);
            thisFig=getSignalFigureByName(this.Container,signalName);

            newDisplay=this.DisplayManager.createAndAddDisplay(thisFig,dispType,toolType,signalName);


            setLabelVisiblity(newDisplay,this.LabelVisibleInternal);

            if newDisplay.IsVoxelSupported


                globalColorLookupTable=this.Session.ROILabelSet.voxelColorLookupGlobal;
                updateVoxelLabelerLookupNewDisplay(newDisplay,globalColorLookupTable);



                globalVoxelLabelVisibility=this.Session.getGlobalVoxelLabelVisibility();
                updateVoxelLabelVisibilityDisplay(newDisplay,globalVoxelLabelVisibility);
            end


            noCloseButton=true;

            addNewDisplayAsTabInLayout(this,newDisplay,noCloseButton);

            newDisplay.resizeFigure();


            customSource=true;
            addSource(newDisplay,signalName,customSource);


            newDisplay.initializeVoxelLabeler();
            configureCutCopyCallbacks(this,newDisplay);


            if dispType==displayType.PointCloud
                wireUpLidarListeners(this,newDisplay);
            end

        end
    end




    methods

        function viewLabelSummary(this)


            wait(this.Container);
            restoreWaitState=onCleanup(@()resume(this.Container));

            isVisualSummaryOpen=~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay);


            if isVisualSummaryOpen
                figure(this.VisualSummaryDisplay.VisualSummaryFigure);
                return;
            end



            currentTime=getCurrentValueForSlider(this);


            this.AnnotationSummaryManager=vision.internal.labeler.annotation.AnnotationSummaryManager(this.Session,currentTime);
            createAndAddAnnotationSummaries(this);



            this.VisualSummaryDisplay=lidar.internal.labeler.tool.VisualSummaryDisplay(...
            this.AnnotationSummaryManager,this.ToolType);

            configure(this.VisualSummaryDisplay,@this.doFigKeyPress,...
            @this.handleCloseVisualSummary);

            addFigureToApp(this.VisualSummaryDisplay,this.Container);

            configureVisualSummaryListeners(this);

            enableVisualSummaryDock(this.LabelTab,true);
        end
    end




    methods(Access=protected)

        function undoHelper(this,signalName,selectedDisplay,currentIndex)
            toUpdate=selectedDisplay.undoROI(currentIndex);
            if(toUpdate)
                currentROIs=selectedDisplay.getCurrentROIs();
                updateSessionWithROIsAnnotations(this,selectedDisplay,currentROIs);
            end
            if~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay)
                if(this.Session.getNumVoxelLabels()>0)

                    data=selectedDisplay.getEventDataFouVisualSummaryUpdate(currentIndex);
                else
                    data=[];
                end
                updateVisualSummaryROICount(this,signalName,[],data);
            end

            updateAttributesSublabelsPanelIfNeeded(this);
            this.Session.IsChanged=true;
        end


        function redoHelper(this,signalName,selectedDisplay,currentIndex)
            toUpdate=selectedDisplay.redoROI(currentIndex);
            if(toUpdate)
                currentROIs=selectedDisplay.getCurrentROIs();
                updateSessionWithROIsAnnotations(this,selectedDisplay,currentROIs);
            end
            if~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay)
                if(this.Session.getNumVoxelLabels()>0)
                    data=selectedDisplay.getEventDataFouVisualSummaryUpdate(currentIndex);
                else
                    data=[];
                end
                updateVisualSummaryROICount(this,signalName,[],data);
            end

            updateAttributesSublabelsPanelIfNeeded(this);
            this.Session.IsChanged=true;
        end
    end


    methods(Access=private)

        function createAndAddAnnotationSummaries(this)

            [selectedSignalName,selectedSignalType,signalNames,selectedSignalId]=getSignalInfoFromDisplay(this.DisplayManager);
            isValidRange=isSignalRangeValid(this,selectedSignalName);

            if((~isempty(selectedSignalName))&&isValidRange)
                annotationInfo=getAnnotationInfoForSummary(this,selectedSignalName,selectedSignalType);
                annotationInfo.CurrentValue=getCurrentValueForSlider(this);
            else
                annotationInfo=[];
            end
            createAndAddAnnotationSummary(this.AnnotationSummaryManager,...
            annotationInfo,selectedSignalId,selectedSignalType,...
            signalNames,isValidRange);
        end


        function id=roiLabelNameToID(this,name)
            labelNames=getROILabelNames(this.VisualSummaryDisplay);
            id=find(strcmpi(name,labelNames));
        end


        function toolType=getToolType(this)

            switch this.ToolName
            case vision.getMessage('vision:labeler:ToolTitleLL')
                toolType=vision.internal.toolType.LidarLabeler;
            otherwise
                toolType=vision.internal.toolType.None;
            end
        end



        function[isValidAttrib,outLabel]=validateAndFillAttribute(this,attribDefData,inLabel)


            if isfield(inLabel,'Attributes')&&~isempty(inLabel.Attributes)
                userAttribS=inLabel.Attributes;
                matchingDefIdx=cell(numel(userAttribS),1);
                for i=1:numel(userAttribS)
                    [userAtribNames,userAtribValues]=parseUserDefinedAttributes(this,userAttribS);
                    [isValidAttrib,matchingDefIdx_i]=validateUserDefinedAttributes(this,attribDefData,userAtribNames,userAtribValues);
                    matchingDefIdx{i}=matchingDefIdx_i;
                    if~isValidAttrib
                        outLabel=inLabel;
                        return;
                    end
                end
            else
                isValidAttrib=true;
                matchingDefIdx={};
            end

            outLabel=fillWithAttributeValue(this,attribDefData,inLabel,matchingDefIdx);
        end


        function outLabel=fillWithAttributeValue(~,attribDefData,inLabel,matchingDefIdx)

            outLabel=inLabel;
            N=numel(attribDefData);

            if isfield(inLabel,'Attributes')
                attribS=inLabel.Attributes;
                for p=1:numel(inLabel.Attributes)
                    unmatchedIdx=setdiff(1:N,matchingDefIdx{p});

                    for i=1:numel(unmatchedIdx)

                        idx=unmatchedIdx(i);
                        f=attribDefData{idx}.Name;
                        if attribDefData{idx}.Type==attributeType.List
                            attribS(p).(f)=attribDefData{idx}.Value{1};
                        else
                            attribS(p).(f)=attribDefData{idx}.Value;
                        end
                    end
                end
            else
                attribS=[];

                for i=1:N

                    f=attribDefData{i}.Name;
                    if attribDefData{i}.Type==attributeType.List
                        attribS.(f)=attribDefData{i}.Value{1};
                    else
                        attribS.(f)=attribDefData{i}.Value;
                    end
                end
            end

            outLabel.Attributes=attribS;
        end
    end


    methods(Access=protected)



        function updateVisualSummaryROICount(this,signalName,~,data)

            if isa(data,'lidar.internal.labeler.tool.VoxelLabelEventData')
                currentReadIndex=data.Data.Index;
            else
                currentReadIndex=getCurrentFrameIndex(this,signalName);
            end


            allLabelNames=getROILabelNames(this.VisualSummaryDisplay);
            labelCounts=zeros(numel(allLabelNames),1);
            isVoxelLabel=zeros(numel(allLabelNames),1);
            isChanged=zeros(numel(allLabelNames),1);
            allLabelIDs=zeros(numel(allLabelNames),1);
            for idx=1:numel(allLabelNames)
                allLabelIDs(idx)=this.roiLabelNameToID(allLabelNames{idx});
                if this.Session.isaVoxelLabel(allLabelNames{idx})
                    isVoxelLabel(idx)=true;
                else
                    isChanged(idx)=true;
                end
            end


            [~,labelNames,sublabelNames]=this.Session.ROIAnnotations.queryAnnotationBySignalName(signalName,currentReadIndex);
            for idx=1:numel(labelNames)
                if isempty(sublabelNames{idx})
                    markedLabelID=this.roiLabelNameToID(labelNames{idx});
                    labelCounts(markedLabelID==allLabelIDs)=labelCounts(markedLabelID==allLabelIDs)+1;
                end
            end


            if isa(data,'lidar.internal.labeler.tool.VoxelLabelEventData')
                allVoxelLabelIDs={this.Session.ROILabelSet.DefinitionStruct.VoxelLabelID};

                for idx=1:numel(allLabelNames)

                    if this.Session.isaVoxelLabel(allLabelNames{idx})

                        markedLabelID=this.roiLabelNameToID(allLabelNames{idx});
                        if numel(size(data.Data.Label))==3
                            labelCounts(markedLabelID==allLabelIDs)=sum(sum(data.Data.Label(:,:,4)==allVoxelLabelIDs{idx}))/numel(data.Data.Label(:,:,4));
                        else
                            labelCounts(markedLabelID==allLabelIDs)=sum(data.Data.Label(:,4)==allVoxelLabelIDs{idx})/numel(data.Data.Label(:,4));
                        end
                        isChanged(markedLabelID==allLabelIDs)=true;
                    end
                end
            end

            if isa(data,'lidar.internal.labeler.tool.VoxelLabelEventData')
                currentUpdateIndex=data.Data.Index-getStartIndex(this,signalName)+1;
            else
                currentUpdateIndex=getCurrentFrameIndex(this,signalName)-getStartIndex(this,signalName)+1;
            end
            if(currentUpdateIndex==getEndIndex(this,signalName))
                isChangeInLastFrame=1;
            else
                isChangeInLastFrame=0;
            end

            this.VisualSummaryDisplay.updateROICounts(allLabelIDs,signalName,labelCounts,currentUpdateIndex,isVoxelLabel,isChanged,isChangeInLastFrame);
        end
    end

end

function tf=isRectOrCubeLabelDef(roiType)


    tf=(roiType==labelType.Cuboid)||(roiType==labelType.Rectangle);
end

function tf=isLineOrLine3DLabelDef(roiType)


    tf=roiType==labelType.Line;
end

function tf=isVoxLabelDef(roiType)


    tf=roiType==lidarLabelType.Voxel;
end


function[idx,logicalIdx]=findLabelTypeIdx(labelTypeChoicesEnum,labels)

    idx=1:numel(labelTypeChoicesEnum);
    logicalIdx=ones(1,numel(labelTypeChoicesEnum));
    if~iscell(labelTypeChoicesEnum)
        for i=1:numel(labelTypeChoicesEnum)
            if~(labelTypeChoicesEnum(i)==labels)
                idx(i)=0;
                logicalIdx(i)=0;
            end
        end
    else
        for i=1:numel(labelTypeChoicesEnum)
            if~(labelTypeChoicesEnum{i}==labels)
                idx(i)=0;
                logicalIdx(i)=0;
            end
        end
    end
    idx=nonzeros(idx);
end
