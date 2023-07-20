




classdef ImageVideoDisplay<vision.internal.labeler.tool.display.Display

    properties(Dependent,Access=protected)
ShapeLabelers
SupprtedLabelers
    end

    properties

UndoRedoManagerPixel

        OperationUndoStack={};
        OperationRedoStack={};
    end

    properties
        IsCuboidSupported=false;
        IsPixelSupported=true;
    end

    properties(Access=private)
        CopiedRectROIs={};
        CopiedLineROIs={};
        CopiedPolygonROIs={};
        CopiedProjCuboidROIs={};

        CopiedRectWithRectLabels={};
        CopiedRectWithLineLabels={};
        CopiedRectWithPolygonLabels={};
        CopiedRectWithProjCuboidLabels={};

        CopiedLineWithLineLabels={};
        CopiedLineWithRectLabels={};
        CopiedLineWithPolygonLabels={};
        CopiedLineWithProjCuboidLabels={};

        CopiedPolygonWithPolygonLabels={};
        CopiedPolygonWithRectLabels={};
        CopiedPolygonWithLineLabels={};
        CopiedPolygonWithProjCuboidLabels={};

        CopiedProjCuboidWithProjCuboidLabels={};
        CopiedProjCuboidWithRectLabels={};
        CopiedProjCuboidWithLineLabels={};
        CopiedProjCuboidWithPolygonLabels={};

AllRectLabelNames
AllLineLabelNames
AllPolygonLabelNames
AllProjCuboidLabelNames
    end
    methods

        function this=ImageVideoDisplay(hFig,nameDisplayedInTab)

            this=this@vision.internal.labeler.tool.display.Display(hFig,nameDisplayedInTab);

            this.SignalType=vision.labeler.loading.SignalType.Image;

        end


        function configure(this,...
            keyPressCallback,...
            labelChangedCallback,...
            roiInstanceSelectionCallback,...
            appWaitStartedCallback,...
            appWaitFinishedCallback,...
            drawingStartedCallback,...
            drawingFinishedCallback,...
            grabCutEditEnabledCallback,...
            grabCutEditDisabledCallback,...
            multipleROIMovingCallback,...
            toolbarButtonChangedCallback,...
            pasteROIMenuCallback,...
            pastePixelROIMenuCallback,...
            copyDisplayNameCallbackForPixelROI,...
            copyPixelROIMenuCallback,...
            cutPixelROIMenuCallback,...
            deletePixelROIMenuCallback)

            this.Fig.KeyPressFcn=keyPressCallback;

            addlistener(this,'ROIsChanged',labelChangedCallback);
            addlistener(this,'ROISelected',roiInstanceSelectionCallback);

            addlistener(this.PixelLabeler,'AppWaitStarted',appWaitStartedCallback);
            addlistener(this.PixelLabeler,'AppWaitFinished',appWaitFinishedCallback);

            addlistener(this.PixelLabeler,'PolygonStarted',drawingStartedCallback);
            addlistener(this.PixelLabeler,'PolygonFinished',drawingFinishedCallback);

            addlistener(this.PixelLabeler,'GrabCutEditEnabled',grabCutEditEnabledCallback);
            addlistener(this.PixelLabeler,'GrabCutEditDisabled',grabCutEditDisabledCallback);


            for idx=1:numel(this.ShapeLabelers)
                this.ShapeLabelers(idx).wipeROIs();
                addlistener(this.ShapeLabelers(idx),'DrawingStarted',drawingStartedCallback);
                addlistener(this.ShapeLabelers(idx),'DrawingFinished',drawingFinishedCallback);
                addlistener(this.ShapeLabelers(idx),'MultiROIMoving',multipleROIMovingCallback);
            end
            this.ToolbarButtonChangedCallback=toolbarButtonChangedCallback;
            this.PasteROIMenuCallback=pasteROIMenuCallback;
            this.PastePixelROIMenuCallback=pastePixelROIMenuCallback;
            this.CopyPixelROIMenuCallback=copyPixelROIMenuCallback;
            this.CopyDisplayNameCallbackForPixelROI=copyDisplayNameCallbackForPixelROI;
            this.CutPixelROIMenuCallback=cutPixelROIMenuCallback;
            this.DeletePixelROIMenuCallback=deletePixelROIMenuCallback;

        end


        function installContextMenu(this,isInAlgoMode,numPixelLabels)
            if isempty(this.ImageHandle.UIContextMenu)
                hCMenu=uicontextmenu('Parent',this.Fig,...
                'Tag','DisplayContextMenu');


                pasteUIMenu=uimenu(hCMenu,'Label',...
                getString(message('vision:trainingtool:PastePopup')),...
                'Callback',@this.PasteROIMenuCallback,'Accelerator','V',...
                'Tag','PasteContextMenu');

                if isempty(this.Clipboard)
                    set(pasteUIMenu,'Enable','off');
                end

                if ismac()
                    pastePixString=getString(message('vision:trainingtool:PastePixelROI','[Cmd+Shift+V]'));
                    copyPixString=getString(message('vision:trainingtool:CopyPixelROI','[Cmd+Shift+C]'));
                    cutPixString=getString(message('vision:trainingtool:CutPixelROI','[Cmd+Shift+X]'));
                    deletePixString=getString(message('vision:trainingtool:DeletePixelROI','[Cmd+Shift+Delete]'));
                else
                    pastePixString=getString(message('vision:trainingtool:PastePixelROI','[Ctrl+Shift+V]'));
                    copyPixString=getString(message('vision:trainingtool:CopyPixelROI','[Ctrl+Shift+C]'));
                    cutPixString=getString(message('vision:trainingtool:CutPixelROI','[Ctrl+Shift+X]'));
                    deletePixString=getString(message('vision:trainingtool:DeletePixelROI','[Ctrl+Shift+Delete]'));
                end


                uimenu(hCMenu,'Label',pastePixString,...
                'Callback',@this.PastePixelROIMenuCallback,...
                'Tag','PastePixelROIsContextMenu','Visible','off',...
                'Enable','off');


                uimenu(hCMenu,'Label',copyPixString,...
                'Callback',@this.CopyPixelROIMenuCallback,...
                'Tag','CopyPixelROIsContextMenu','Visible','off',...
                'Enable','off');


                uimenu(hCMenu,'Label',cutPixString,...
                'Callback',@this.CutPixelROIMenuCallback,...
                'Tag','CutPixelROIsContextMenu','Visible','off',...
                'Enable','off');


                uimenu(hCMenu,'Label',deletePixString,...
                'Callback',@this.DeletePixelROIMenuCallback,...
                'Tag','DeletePixelROIsContextMenu','Visible','off',...
                'Enable','off');

                set(this.ImageHandle,'UIContextMenu',hCMenu);
                this.ContextMenuCache=hCMenu;
            else
                this.resetCopyPastePixelContextMenu();
            end

            sessionData.isInAlgoMode=isInAlgoMode;
            sessionData.numPixelLabels=numPixelLabels;
            updateContextMenuCopyPastePixel(this,sessionData);
        end


        function setPasteMenuState(this,copiedROIsTypes,enableState)

            foundPaste=findobj(this.ImageHandle.UIContextMenu.Children,...
            'Tag','PasteContextMenu');
            foundPaste.Text=copiedROIsTypes;
            set(foundPaste,'Enable',enableState);
        end


        function setPasteVisibility(this,visibleState)

            foundPaste=findobj(this.ImageHandle.UIContextMenu.Children,...
            'Tag','PasteContextMenu');
            set(foundPaste,'Visible',visibleState);
        end


        function setPixContextMenuVisibility(this,visibleState)

            copyPixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children...
            ,'Tag','CopyPixelROIsContextMenu');
            pastePixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children...
            ,'Tag','PastePixelROIsContextMenu');
            cutPixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children...
            ,'Tag','CutPixelROIsContextMenu');
            deletePixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children...
            ,'Tag','DeletePixelROIsContextMenu');
            set(copyPixelUIMenu,'Visible',visibleState);
            set(pastePixelUIMenu,'Visible',visibleState);
            set(cutPixelUIMenu,'Visible',visibleState);
            set(deletePixelUIMenu,'Visible',visibleState);
        end


        function setPixPasteMenuState(this,enableState,visibleState)



            pastePixelUIMenu=findobj(this.ImageHandle.UIContextMenu.Children...
            ,'Tag','PastePixelROIsContextMenu');

            set(pastePixelUIMenu,'Enable',enableState);
            set(pastePixelUIMenu,'Visible',visibleState);

            drawnow('limitrate');
        end


        function data=getEventDataFouVisualSummaryUpdate(this,index)


            data.Label=this.PixelLabeler.LabelMatrix;
            data.Index=index;
            data=vision.internal.labeler.tool.PixelLabelEventData(data);
        end
    end

    methods
        function LabelerGroup=get.ShapeLabelers(this)
            LabelerGroup=[this.RectangleLabeler;this.LineLabeler;...
            this.PolygonLabeler;this.ProjCuboidLabeler];
        end

        function LabelerGroup=get.SupprtedLabelers(this)
            LabelerGroup=[this.RectangleLabeler;this.LineLabeler;...
            this.PolygonLabeler;this.ProjCuboidLabeler;this.PixelLabeler];
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
    end

    methods


        function finalize(this)
            this.PixelLabeler.finalize();
        end


        function resetUndoRedoPixelOnLabDefDel(this)


            this.PixelLabeler.resetURPixelOnLabDefDel();
        end


        function resetPixelLabeler(this,data)
            this.PixelLabeler.reset(data);
        end


        function renameAttribInClipboard(this,attribData,newName)
            this.Clipboard.renameAttribute(attribData,newName)
        end


        function deletePixelLabelData(this,pixelID)
            deletePixelLabelData(this.PixelLabeler,pixelID);
        end

        function isModeReadyForROI=getModeFromSelectedItem(this,selectedItem)

            roiItemDataObj=selectedItem.roiItemDataObj;
            isLabel=isLabelDef(this,roiItemDataObj);
            isModeReadyForROI=isLabel||...
            (~isLabel&&isOneROIInstanceSelectedOfDefFamily(this,roiItemDataObj));

        end


        function enablePasteFlag=copySelectedROIs(this,varargin)


            allrois=[];


            for lIdx=1:numel(this.ShapeLabelers)
                theserois=this.ShapeLabelers(lIdx).getSelectedROIsForCopy();
                allrois=[allrois,theserois];%#ok<AGROW>
            end


            parentrois=[];
            for idx=1:numel(allrois)
                thisparent=[];
                if~isempty(allrois{idx}.parentName)

                    parentID=allrois{idx}.UserData{3};
                    thisparent=this.RectangleLabeler.copyROIByID(parentID);
                    if isempty(thisparent)

                        thisparent=this.LineLabeler.copyROIByID(parentID);
                    end
                    if isempty(thisparent)

                        thisparent=this.PolygonLabeler.copyROIByID(parentID);
                    end
                    if isempty(thisparent)

                        thisparent=this.ProjCuboidLabeler.copyROIByID(parentID);
                    end
                end

                if~any(cellfun(@(x)isequal(x,thisparent),allrois))
                    parentrois=[parentrois,thisparent];%#ok<AGROW>
                end
            end


            for idx=1:numel(parentrois)
                allrois=[allrois,parentrois(idx)];%#ok<AGROW>
            end

            if~isempty(allrois)
                this.Clipboard.add(allrois);
            end

            enablePasteFlag=~isempty(this.Clipboard);
        end


        function copiedROIsTypes=copiedROIsType(this)

            if~isempty(this.Clipboard)
                availableROIs=cellfun(@(x)x.UserData{1},this.Clipboard.CopiedROIs,...
                'UniformOutput',false);
                lineROI=any(strcmp(availableROIs,'line'));
                rectROI=any(strcmp(availableROIs,'rect'));
                polygonROI=any(strcmp(availableROIs,'polygon'));
                projCuboidROI=any(strcmpi(availableROIs,'projCuboid'));

                numShapes=double(lineROI)+double(rectROI)+...
                double(polygonROI)+double(projCuboidROI);

                if(numShapes>1)


                    copiedROIsTypes=getString(message('vision:trainingtool:PasteRectangleAndLinePopup'));
                elseif rectROI
                    copiedROIsTypes=getString(message('vision:trainingtool:PasteRectanglePopup'));
                elseif lineROI
                    copiedROIsTypes=getString(message('vision:trainingtool:PasteLinePopup'));
                elseif polygonROI
                    copiedROIsTypes=getString(message('vision:trainingtool:PastePolygonPopup'));
                else
                    copiedROIsTypes=getString(message('vision:trainingtool:PasteProjCuboidPopup'));
                end
            else
                copiedROIsTypes=getString(message('vision:trainingtool:PastePopup'));
            end
        end


        function copiedROIsInGroup=getCopiedROIsInGroup(this)

            if isempty(this.Clipboard)
                copiedROIsInGroup=[];
                return;
            end

            rois=contents(this.Clipboard);


            resetPropsCopiedROIs(this);

            populateAllLabelNamesByType(this,rois);

            for inx=1:numel(rois)
                roi=rois{inx};
                if isempty(roi)

                    continue
                end

                roiData=roi.UserData;




                shapeSpec=roiData{1};
                switch shapeSpec
                case 'rect'

                    if isParentLabelRectangle(this,roi)
                        this.CopiedRectWithRectLabels{end+1}=roi;
                    elseif isParentLabelLine(this,roi)
                        this.CopiedRectWithLineLabels{end+1}=roi;
                    elseif isParentLabelPolygon(this,roi)
                        this.CopiedRectWithPolygonLabels{end+1}=roi;
                    elseif isParentLabelProjCuboid(this,roi)
                        this.CopiedRectWithProjCuboidLabels{end+1}=roi;
                    else
                        this.CopiedRectROIs{end+1}=roi;
                    end
                case 'line'

                    if isParentLabelRectangle(this,roi)
                        this.CopiedLineWithRectLabels{end+1}=roi;
                    elseif isParentLabelLine(this,roi)
                        this.CopiedLineWithLineLabels{end+1}=roi;
                    elseif isParentLabelPolygon(this,roi)
                        this.CopiedLineWithPolygonLabels{end+1}=roi;
                    elseif isParentLabelProjCuboid(this,roi)
                        this.CopiedLineWithProjCuboidLabels{end+1}=roi;
                    else
                        this.CopiedLineROIs{end+1}=roi;
                    end
                case 'polygon'

                    if isParentLabelRectangle(this,roi)
                        this.CopiedPolygonWithRectLabels{end+1}=roi;
                    elseif isParentLabelLine(this,roi)
                        this.CopiedPolygonWithLineLabels{end+1}=roi;
                    elseif isParentLabelPolygon(this,roi)
                        this.CopiedPolygonWithPolygonLabels{end+1}=roi;
                    elseif isParentLabelProjCuboid(this,roi)
                        this.CopiedPolygonWithProjCuboidLabels{end+1}=roi;
                    else
                        this.CopiedPolygonROIs{end+1}=roi;
                    end
                case 'projCuboid'


                    if isParentLabelRectangle(this,roi)
                        this.CopiedProjCuboidWithRectLabels{end+1}=roi;
                    elseif isParentLabelLine(this,roi)
                        this.CopiedProjCuboidWithLineLabels{end+1}=roi;
                    elseif isParentLabelPolygon(this,roi)
                        this.CopiedProjCuboidWithPolygonLabels{end+1}=roi;
                    elseif isParentLabelProjCuboid(this,roi)
                        this.CopiedProjCuboidWithProjCuboidLabels{end+1}=roi;
                    else
                        this.CopiedProjCuboidROIs{end+1}=roi;
                    end
                otherwise
                    error('Undefined action for shape %s',roiData);
                end
            end


            copiedROIsInGroup.CopiedRectROIs=this.CopiedRectROIs;
            copiedROIsInGroup.CopiedLineROIs=this.CopiedLineROIs;
            copiedROIsInGroup.CopiedPolygonROIs=this.CopiedPolygonROIs;
            copiedROIsInGroup.CopiedProjCuboidROIs=this.CopiedProjCuboidROIs;


            copiedROIsInGroup.CopiedRectWithRectLabels=this.CopiedRectWithRectLabels;
            copiedROIsInGroup.CopiedRectWithLineLabels=this.CopiedRectWithLineLabels;
            copiedROIsInGroup.CopiedRectWithPolygonLabels=this.CopiedRectWithPolygonLabels;
            copiedROIsInGroup.CopiedRectWithProjCuboidLabels=this.CopiedRectWithProjCuboidLabels;


            copiedROIsInGroup.CopiedLineWithRectLabels=this.CopiedLineWithRectLabels;
            copiedROIsInGroup.CopiedLineWithLineLabels=this.CopiedLineWithLineLabels;
            copiedROIsInGroup.CopiedLineWithPolygonLabels=this.CopiedLineWithPolygonLabels;
            copiedROIsInGroup.CopiedLineWithProjCuboidLabels=this.CopiedLineWithProjCuboidLabels;


            copiedROIsInGroup.CopiedPolygonWithRectLabels=this.CopiedPolygonWithRectLabels;
            copiedROIsInGroup.CopiedPolygonWithLineLabels=this.CopiedPolygonWithLineLabels;
            copiedROIsInGroup.CopiedPolygonWithPolygonLabels=this.CopiedPolygonWithPolygonLabels;
            copiedROIsInGroup.CopiedPolygonWithProjCuboidLabels=this.CopiedPolygonWithProjCuboidLabels;


            copiedROIsInGroup.CopiedProjCuboidWithRectLabels=this.CopiedProjCuboidWithRectLabels;
            copiedROIsInGroup.CopiedProjCuboidWithLineLabels=this.CopiedProjCuboidWithLineLabels;
            copiedROIsInGroup.CopiedProjCuboidWithPolygonLabels=this.CopiedProjCuboidWithPolygonLabels;
            copiedROIsInGroup.CopiedProjCuboidWithProjCuboidLabels=this.CopiedProjCuboidWithProjCuboidLabels;

        end


        function copiedPixelROIsInGroup=getCopiedPixelROIsInGroup(this)

            copiedPixelROIsInGroup=this.PixelClipboard;
        end


        function copyPixelROIs(this,~,~)
            this.PixelClipboard=this.PixelLabeler.copyPixelROIs();
            this.CopyDisplayNameCallbackForPixelROI();
        end


        function deletePixelROI(this)
            this.PixelLabeler.deletePixelROIs();
        end


        function enablePixPasteFlag=pastePixelFlag(this)

            enablePixPasteFlag=false;
            if~isempty(this.PixelClipboard)
                enablePixPasteFlag=true;
            end
        end


        function enablePixPasteFlag=allowPastePixel(this)
            enablePixPasteFlag=false;
            if(nnz(this.PixelLabeler.LabelMatrix))
                enablePixPasteFlag=true;
            end
        end


        function pastePixelROIsInGroup(this,copiedPixelROIsInGroup)
            this.PixelLabeler.pastePixelROIs(copiedPixelROIsInGroup);

            drawnow('limitrate');
        end



        function pasteROIsInGroup(this,copiedROIsInGroup)
            if isempty(copiedROIsInGroup)||isempty(this.ImageHandle.CData)
                return;
            end






























            useProgressBar=sum(structfun(@numel,copiedROIsInGroup))>200;

            if useProgressBar
                progressDlgTitle=vision.getMessage('vision:labeler:PastingProgress');
                pleaseWaitMsg=vision.getMessage('vision:labeler:StartPasting');
                waitBarObj=vision.internal.labeler.tool.ProgressDialog(this.Fig,...
                progressDlgTitle,pleaseWaitMsg);

                pastingLabelsMessage=vision.getMessage('vision:labeler:PastingLabels');
                waitBarObj.setParams(0.33,pastingLabelsMessage);
            end







            pasteSelectedROIs(this.RectangleLabeler,copiedROIsInGroup.CopiedRectROIs);


            pasteSelectedROIs(this.LineLabeler,copiedROIsInGroup.CopiedLineROIs);


            pasteSelectedROIs(this.PolygonLabeler,copiedROIsInGroup.CopiedPolygonROIs);


            pasteSelectedROIs(this.ProjCuboidLabeler,copiedROIsInGroup.CopiedProjCuboidROIs);


            if useProgressBar
                pastingSubLabelsMessage=vision.getMessage('vision:labeler:PastingSublabels');
                waitBarObj.setParams(0.67,pastingSubLabelsMessage);
            end


            pasteSelectedROIs(this.RectangleLabeler,copiedROIsInGroup.CopiedRectWithRectLabels);

            pasteSelectedROIs(this.RectangleLabeler,copiedROIsInGroup.CopiedRectWithLineLabels);

            pasteSelectedROIs(this.RectangleLabeler,copiedROIsInGroup.CopiedRectWithPolygonLabels);

            pasteSelectedROIs(this.RectangleLabeler,copiedROIsInGroup.CopiedRectWithProjCuboidLabels);


            pasteSelectedROIs(this.LineLabeler,copiedROIsInGroup.CopiedLineWithRectLabels);

            pasteSelectedROIs(this.LineLabeler,copiedROIsInGroup.CopiedLineWithLineLabels);

            pasteSelectedROIs(this.LineLabeler,copiedROIsInGroup.CopiedLineWithPolygonLabels);

            pasteSelectedROIs(this.LineLabeler,copiedROIsInGroup.CopiedLineWithProjCuboidLabels);


            pasteSelectedROIs(this.PolygonLabeler,copiedROIsInGroup.CopiedPolygonWithRectLabels);

            pasteSelectedROIs(this.PolygonLabeler,copiedROIsInGroup.CopiedPolygonWithLineLabels);

            pasteSelectedROIs(this.PolygonLabeler,copiedROIsInGroup.CopiedPolygonWithPolygonLabels);

            pasteSelectedROIs(this.PolygonLabeler,copiedROIsInGroup.CopiedPolygonWithProjCuboidLabels);


            pasteSelectedROIs(this.ProjCuboidLabeler,copiedROIsInGroup.CopiedProjCuboidWithRectLabels);

            pasteSelectedROIs(this.ProjCuboidLabeler,copiedROIsInGroup.CopiedProjCuboidWithLineLabels);

            pasteSelectedROIs(this.ProjCuboidLabeler,copiedROIsInGroup.CopiedProjCuboidWithPolygonLabels);

            pasteSelectedROIs(this.ProjCuboidLabeler,copiedROIsInGroup.CopiedProjCuboidWithProjCuboidLabels);

            if useProgressBar
                close(waitBarObj);
            end




            drawnow('limitrate');
        end


        function pasteSelectedROIs(this,varargin)
            copiedROIsInGroup=getCopiedROIsInGroup(this);
            pasteROIsInGroup(this,copiedROIsInGroup);
        end


        function TF=isOneROIInstanceSelectedOfDefFamily(this,sublabelItemData)





            TF=false;
            [Nrl,Nr,Nl,Npc,Npoly]=numEachROIInstanceSelected(this);
            if Nrl==1
                if(Nr==1)
                    N=this.RectangleLabeler.getNumSelectedROIsOfDefFamily(sublabelItemData);
                    TF=(N==1);
                elseif(Nl==1)
                    N=this.LineLabeler.getNumSelectedROIsOfDefFamily(sublabelItemData);
                    TF=(N==1);
                elseif(Npc==1)
                    N=this.ProjCuboidLabeler.getNumSelectedROIsOfDefFamily(sublabelItemData);
                    TF=(N==1);
                else
                    N=this.PolygonLabeler.getNumSelectedROIsOfDefFamily(sublabelItemData);
                    TF=(N==1);
                end
            end
        end


        function[Nrl,Nr,Nl,Npc,Npoly]=numEachROIInstanceSelected(this)


            Nr=this.RectangleLabeler.getNumSelectedROIs();
            Nl=this.LineLabeler.getNumSelectedROIs();
            Npc=this.ProjCuboidLabeler.getNumSelectedROIs();
            Npoly=this.PolygonLabeler.getNumSelectedROIs();
            Np=0;
            Nrl=Nr+Nl+Npc+Npoly+Np;
        end


        function setSingleSelectedROIInstanceInfo(this,selectedROIinfo)

            if this.RectangleLabeler.hasSelectedROI
                lblType=labelType.Rectangle;
            elseif this.LineLabeler.hasSelectedROI
                lblType=labelType.Rectangle;
            elseif this.PolygonLabeler.hasSelectedROI
                lblType=labelType.Rectangle;
            elseif this.ProjCuboidLabeler.hasSelectedROI
                lblType=labelType.Rectangle;
            else
                return;

            end

            selectedROIinfo.Type=lblType;
            this.RectangleLabeler.setSingleSelectedROIInstanceInfo(selectedROIinfo);
            this.LineLabeler.setSingleSelectedROIInstanceInfo(selectedROIinfo);
            this.PolygonLabeler.setSingleSelectedROIInstanceInfo(selectedROIinfo);
            this.ProjCuboidLabeler.setSingleSelectedROIInstanceInfo(selectedROIinfo);

        end

        function clipboardState=isROIClipboardFilled(this)
            clipboardState=~isempty(this.Clipboard);
        end

        function clipboardState=isPixelClipboardFilled(this)
            clipboardState=~isempty(this.PixelClipboard);
        end
    end






































    methods(Access=protected)


        function initialize(this)
            this.OrigFigUnit=this.Fig.Units;

            this.LabeledVideoUIObj=vision.internal.videoLabeler.tool.LabeledVideoUIContainer(this.Fig);
            this.ImagePanel=this.LabeledVideoUIObj.ImagePanel;


            this.Fig.Resize='on';


            this.Fig.BusyAction='cancel';
            this.Fig.Interruptible='off';


            this.Fig.Tag='Video';

            this.UndoRedoManagerShape=vision.internal.labeler.tool.UndoRedoManagerShape();
            this.UndoRedoManagerPixel=vision.internal.labeler.tool.UndoRedoManagerPixel();

            this.MultiShapeLabelers=vision.internal.labeler.tool.MultiShapeLabelers();


            this.RectangleLabeler=vision.internal.labeler.tool.RectangleLabeler();

            addlistener(this.RectangleLabeler,'LabelIsChanged',@this.doLabelIsChanged);
            addlistener(this.RectangleLabeler,'LabelIsSelected',@this.doLabelIsSelected);
            addlistener(this.RectangleLabeler,'LabelIsSelectedPre',@this.doLabelIsSelectedPre);
            addlistener(this.RectangleLabeler,'LabelIsDeleted',@this.doLabelIsDeleted);


            this.LineLabeler=vision.internal.labeler.tool.LineLabeler();

            addlistener(this.LineLabeler,'LabelIsChanged',@this.doLabelIsChanged);
            addlistener(this.LineLabeler,'LabelIsSelected',@this.doLabelIsSelected);
            addlistener(this.LineLabeler,'LabelIsSelectedPre',@this.doLabelIsSelectedPre);
            addlistener(this.LineLabeler,'LabelIsDeleted',@this.doLabelIsDeleted);


            this.PolygonLabeler=vision.internal.labeler.tool.PolygonLabeler();

            addlistener(this.PolygonLabeler,'LabelIsChanged',@this.doLabelIsChanged);
            addlistener(this.PolygonLabeler,'LabelIsSelected',@this.doLabelIsSelected);
            addlistener(this.PolygonLabeler,'LabelIsSelectedPre',@this.doLabelIsSelectedPre);
            addlistener(this.PolygonLabeler,'LabelIsDeleted',@this.doLabelIsDeleted);


            this.ProjCuboidLabeler=vision.internal.labeler.tool.ProjCuboidLabeler();

            addlistener(this.ProjCuboidLabeler,'LabelIsChanged',@this.doLabelIsChanged);
            addlistener(this.ProjCuboidLabeler,'LabelIsSelected',@this.doLabelIsSelected);
            addlistener(this.ProjCuboidLabeler,'LabelIsSelectedPre',@this.doLabelIsSelectedPre);
            addlistener(this.ProjCuboidLabeler,'LabelIsDeleted',@this.doLabelIsDeleted);


            this.PixelLabeler=vision.internal.labeler.tool.PixelLabeler();
            addlistener(this.PixelLabeler,'ImageIsChanged',@(~,evt)this.drawImage(evt.Data));
            addlistener(this.PixelLabeler,'ImageIsChanged',@(~,evt)this.doPixelLabelChanged(evt.Data));
            addlistener(this.PixelLabeler,'ImageIsChanged',@(~,evt)this.updateContextMenuCopyPastePixel(evt.Data));
            addlistener(this.PixelLabeler,'TempPixelUpdate',@(~,evt)this.drawImage(evt.Data));

            addlistener(this.PixelLabeler,'LabelIsChanged',@this.doLabelIsChanged);
            this.initializePixelLabeler();


            wipeROIs(this);






            images.roi.internal.IPTROIPointerManager(this.Fig,[]);
            addlistener(this.Fig,'WindowMouseMotion',@(src,evt)this.mouseMotionCallback(src,evt));
        end




...
...
...
...


        function doLabelIsSelectedPre(this,varargin)
            this.MultiShapeLabelers.doLabelIsSelectedPre(this.ShapeLabelers,varargin{:});
        end


        function mouseMotionCallback(this,~,evt)

            if~this.Fig.IPTROIPointerManager.Enabled||isempty(this.ImageHandle)||~isvalid(this.ImageHandle)
                return;
            end

            if evt.HitObject==this.ImageHandle
                this.WasImageLastHitObject=true;
                setPointer(this);
            elseif isa(evt.HitObject,'matlab.ui.container.Panel')&&any(strcmp(evt.HitObject.Tag,{'RightFlagPanel','LeftFlagPanel','ScrubberPanel'}))
                this.WasScrubberLastHitObject=true;
                images.roi.internal.setROIPointer(this.Fig,'east');
            else
                if this.WasImageLastHitObject||this.WasScrubberLastHitObject

                    this.WasImageLastHitObject=false;
                    this.WasScrubberLastHitObject=false;
                    if~any(strcmp(class(evt.HitObject.Parent),...
                        {'images.roi.Rectangle',...
                        'vision.roi.ProjectedCuboid',...
                        'images.roi.Polygon',...
                        'images.roi.Polyline'}))
                        set(this.Fig,'Pointer','arrow');
                    end

                end
            end

        end

    end




    methods

        function initializeUndoBuffer(this,currentIndex)
            this.UndoRedoManagerShape.initializeUndoBuffer(currentIndex);
            this.UndoRedoManagerPixel.initializeUndoBuffer(currentIndex);
        end







        function toUpdate=undoROI(this,currentIndex)




            if(this.UndoRedoManagerShape.isUndoAvailable()||...
                this.UndoRedoManagerPixel.isUndoAvailable())

                op=this.undoOperationStack();
                switch op
                case vision.internal.labeler.tool.LabelTypeUndoRedo.AllLabel

                    this.UndoRedoManagerShape.undo();
                    this.UndoRedoManagerPixel.undo();
                case vision.internal.labeler.tool.LabelTypeUndoRedo.ShapeLabel

                    this.UndoRedoManagerShape.undo();
                case vision.internal.labeler.tool.LabelTypeUndoRedo.PixelLabel

                    this.UndoRedoManagerPixel.undo();
                end
                toUpdate=this.updateROIsForUndoRedo(currentIndex,op);
            else
                toUpdate=false;
            end
        end


        function toUpdate=redoROI(this,currentIndex)




            if(this.UndoRedoManagerShape.isRedoAvailable()||...
                this.UndoRedoManagerPixel.isRedoAvailable())

                op=this.redoOperationStack();

                switch op
                case vision.internal.labeler.tool.LabelTypeUndoRedo.AllLabel

                    this.UndoRedoManagerShape.redo();
                    this.UndoRedoManagerPixel.redo();
                case vision.internal.labeler.tool.LabelTypeUndoRedo.ShapeLabel

                    this.UndoRedoManagerShape.redo();
                case vision.internal.labeler.tool.LabelTypeUndoRedo.PixelLabel

                    this.UndoRedoManagerPixel.redo();
                end
                toUpdate=this.updateROIsForUndoRedo(currentIndex,op);
            else
                toUpdate=false;
            end
        end


        function op=undoOperationStack(this)

            this.OperationRedoStack{end+1}=this.OperationUndoStack{end};
            op=this.OperationUndoStack{end};
            this.OperationUndoStack(end)=[];
        end


        function op=redoOperationStack(this)

            this.OperationUndoStack{end+1}=this.OperationRedoStack{end};
            op=this.OperationRedoStack{end};
            this.OperationRedoStack(end)=[];
        end


        function toUpdate=updateROIsForUndoRedo(this,currentIndex,op)



            switch op
            case vision.internal.labeler.tool.LabelTypeUndoRedo.AllLabel

                toUpdate1=this.updateInteractiveROIsForUndoRedo(currentIndex);
                toUpdate2=this.updateInteractivePixelROIsForUndoRedo(currentIndex);
                toUpdate=toUpdate1||toUpdate2;
            case vision.internal.labeler.tool.LabelTypeUndoRedo.ShapeLabel

                toUpdate=this.updateInteractiveROIsForUndoRedo(currentIndex);
            case vision.internal.labeler.tool.LabelTypeUndoRedo.PixelLabel

                toUpdate=this.updateInteractivePixelROIsForUndoRedo(currentIndex);
            otherwise
                toUpdate=false;
            end
        end


        function updateUndoOnLabelChange(this,currentIdx,currentROIs,op)




            if nargin==3

                op=vision.internal.labeler.tool.LabelTypeUndoRedo.AllLabel;
            end

            if this.UndoRedoManagerShape.shouldResetUndoRedo(currentIdx)||...
                this.UndoRedoManagerPixel.shouldResetUndoRedo(currentIdx)


                this.UndoRedoManagerShape.initializeUndoBuffer(currentIdx);
                [labelMatrix,~]=this.getInitialPixelROIs();
                this.UndoRedoManagerPixel.initializeUndoBuffer(currentIdx,...
                labelMatrix{1},[]);



                this.OperationUndoStack={};
            end

            this.OperationRedoStack={};

            if op==vision.internal.labeler.tool.LabelTypeUndoRedo.ShapeLabel



                this.UndoRedoManagerPixel.resetRedoStack();
                this.addAllCurrentROILabelsToUndoStack(currentIdx,currentROIs);
            elseif op==vision.internal.labeler.tool.LabelTypeUndoRedo.PixelLabel



                this.UndoRedoManagerShape.resetRedoStack();
                this.addAllCurrentPixelROILabelsToUndoStack(currentIdx);
            elseif op==vision.internal.labeler.tool.LabelTypeUndoRedo.AllLabel



                TFSL=this.addAllCurrentROILabelsToUndoStack(currentIdx,currentROIs);
                TFPL=this.addAllCurrentPixelROILabelsToUndoStack(currentIdx);

                if TFSL&&TFPL



                    this.OperationUndoStack={};
                    this.OperationUndoStack{end+1}=...
                    vision.internal.labeler.tool.LabelTypeUndoRedo.AllLabel;


                elseif xor(TFSL,TFPL)



                    this.OperationUndoStack={};
                    this.OperationUndoStack{end+1}=...
                    vision.internal.labeler.tool.LabelTypeUndoRedo.AllLabel;
                    if TFSL


                        this.UndoRedoManagerPixel.addDuplicate();
                    else


                        this.UndoRedoManagerShape.addDuplicate();
                    end
                end
            end
        end


        function TF=addAllCurrentROILabelsToUndoStack(this,currentIndex,roiAnnotations)



            roiNames={roiAnnotations.Label};
            parentNames={roiAnnotations.ParentName};

            selfUIDs={roiAnnotations.ID};
            parentUIDs={roiAnnotations.ParentUID};

            roiPositions={roiAnnotations.Position};
            roiColors={roiAnnotations.Color};
            roiShapes=[roiAnnotations.Shape];
            roiVisibility={roiAnnotations.ROIVisibility};


            TF=this.UndoRedoManagerShape.executeCommand(...
            vision.internal.labeler.tool.ROIUndoRedoParams(...
            currentIndex,roiNames,parentNames,...
            selfUIDs,parentUIDs,...
            roiPositions,roiColors,roiShapes,roiVisibility));

            if TF
                this.OperationUndoStack{end+1}=...
                vision.internal.labeler.tool.LabelTypeUndoRedo.ShapeLabel;
            end
        end


        function TF=addAllCurrentPixelROILabelsToUndoStack(this,currentIndex)


            [labelMatrix,undoPlaceholder]=this.getCurrentPixelROIs();


            TF=this.UndoRedoManagerPixel.executeCommand(...
            vision.internal.labeler.tool.ROIUndoRedoParamsPixel(...
            currentIndex,labelMatrix,undoPlaceholder));

            if TF
                this.OperationUndoStack{end+1}=...
                vision.internal.labeler.tool.LabelTypeUndoRedo.PixelLabel;
            end
        end


        function toUpdate=updateInteractivePixelROIsForUndoRedo(this,currentIndex)




            if this.UndoRedoManagerPixel.shouldResetUndoRedo(currentIndex)


                this.UndoRedoManagerPixel.resetUndoRedoBuffer();
                addAllCurrentPixelROILabelsToUndoStack(this,currentIndex);
                toUpdate=false;
            else
                rois=this.UndoRedoManagerPixel.undoStack{end};
                data.LabelMatrix={this.createLabelMatrix()};
                data.Placeholder=rois.Placeholder;

                this.wipePixelROIs();
                redrawPixelROIs(this,data);
                toUpdate=true;

            end
        end


        function wipePixelROIs(this)


            this.PixelLabeler.wipeROIs();
        end


        function[labelMatrix,undoPlaceholder]=getCurrentPixelROIs(this)


            labelMatrix={this.PixelLabeler.getLabelMatrixInternal()};
            undoPlaceholder={this.PixelLabeler.getUndoPlaceHolder()};
        end


        function[labelMatrix,undoPlaceholder]=getInitialPixelROIs(this)


            labelMatrix={this.PixelLabeler.getEmptyLabelMatrix()};
            undoPlaceholder={[]};
        end


        function addlistenerForUpdateUndoRedoQAB(this,callback)

            addlistener(this.UndoRedoManagerShape,'UpdateUndoRedoQAB',callback);
            addlistener(this.UndoRedoManagerPixel,'UpdateUndoRedoQAB',callback);
        end


        function TF=isUndoAvailable(this,~)
            TF=this.UndoRedoManagerShape.isUndoAvailable(this.CurrentDisplayIndex)||...
            this.UndoRedoManagerPixel.isUndoAvailable(this.CurrentDisplayIndex);
        end


        function TF=isRedoAvailable(this,~)
            TF=this.UndoRedoManagerShape.isRedoAvailable(this.CurrentDisplayIndex)||...
            this.UndoRedoManagerPixel.isRedoAvailable(this.CurrentDisplayIndex);
        end


        function resetUndoRedoBuffer(this)
            this.UndoRedoManagerShape.resetUndoRedoBuffer();
            this.UndoRedoManagerPixel.resetUndoRedoBuffer();
        end


        function L=createLabelMatrix(this)




            pixelLabeler=this.PixelLabeler;
            undoStack=this.UndoRedoManagerPixel.undoStack;
            L=pixelLabeler.createLabelMatrixFromUndoStack(undoStack{1}.LabelMatrix{1});

            for i=2:numel(undoStack)
                L=L+pixelLabeler.createLabelMatrixFromUndoStack(...
                undoStack{i}.LabelMatrix{1});
            end
            L=uint8(L);
        end


        function updateLabelInUndoRedoBuffer(this,newItemInfo,oldItemInfo,toUpdate)
            if isequal(newItemInfo.ROI,labelType.PixelLabel)
                this.UndoRedoManagerPixel.updateLabelInUndoRedoBuffer(newItemInfo,oldItemInfo,toUpdate);
            else
                this.UndoRedoManagerShape.updateLabelInUndoRedoBuffer(newItemInfo,oldItemInfo,toUpdate);
            end
        end


        function updateLabelVisibilityInUndoRedoBuffer(this,newItemInfo)
            if isequal(newItemInfo.ROI,labelType.PixelLabel)
                this.UndoRedoManagerPixel.updateLabelVisibilityInUndoRedoBuffer(newItemInfo);
            else
                this.UndoRedoManagerShape.updateLabelVisibilityInUndoRedoBuffer(newItemInfo);
            end
        end
    end

    methods


        function appendImage(this)

            hideHelperText(this);
        end


    end

    methods(Access=private)

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

        function populateAllLabelNamesByType(this,rois)

            this.AllRectLabelNames={};
            this.AllLineLabelNames={};
            this.AllProjCuboidLabelNames={};

            for inx=1:numel(rois)
                if isempty(rois{inx}.parentName)
                    shapeSpec=rois{inx}.UserData{1};


                    labelName=rois{inx}.Tag;
                    switch shapeSpec
                    case 'rect'
                        this.AllRectLabelNames{end+1}=labelName;
                    case 'line'
                        this.AllLineLabelNames{end+1}=labelName;
                    case 'polygon'
                        this.AllPolygonLabelNames{end+1}=labelName;
                    case 'projCuboid'
                        this.AllProjCuboidLabelNames{end+1}=labelName;
                    end
                end
            end

        end


        function tf=isParentLabelRectangle(this,roi)
            tf=~isempty(roi.parentName)&&...
            any(strcmp(this.AllRectLabelNames,roi.parentName));
        end


        function tf=isParentLabelLine(this,roi)
            tf=~isempty(roi.parentName)&&...
            any(strcmp(this.AllLineLabelNames,roi.parentName));
        end


        function tf=isParentLabelPolygon(this,roi)
            tf=~isempty(roi.parentName)&&...
            any(strcmp(this.AllPolygonLabelNames,roi.parentName));
        end


        function tf=isParentLabelProjCuboid(this,roi)
            tf=~isempty(roi.parentName)&&...
            any(strcmp(this.AllProjCuboidLabelNames,roi.parentName));
        end


        function resetPropsCopiedROIs(this)
            this.CopiedRectROIs={};
            this.CopiedLineROIs={};
            this.CopiedPolygonROIs={};
            this.CopiedProjCuboidROIs={};

            this.CopiedRectWithRectLabels={};
            this.CopiedRectWithLineLabels={};
            this.CopiedRectWithPolygonLabels={};
            this.CopiedRectWithProjCuboidLabels={};

            this.CopiedLineWithLineLabels={};
            this.CopiedLineWithRectLabels={};
            this.CopiedLineWithPolygonLabels={};
            this.CopiedLineWithProjCuboidLabels={};

            this.CopiedPolygonWithPolygonLabels={};
            this.CopiedPolygonWithRectLabels={};
            this.CopiedPolygonWithLineLabels={};
            this.CopiedPolygonWithProjCuboidLabels={};

            this.CopiedProjCuboidWithProjCuboidLabels={};
            this.CopiedProjCuboidWithRectLabels={};
            this.CopiedProjCuboidWithLineLabels={};
            this.CopiedProjCuboidWithPolygonLabels={};
        end
    end
end
