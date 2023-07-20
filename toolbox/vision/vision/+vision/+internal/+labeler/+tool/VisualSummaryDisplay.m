

classdef VisualSummaryDisplay<handle

    properties(GetAccess=public,SetAccess=private)







VisualSummaryFigure
Fig
    end

    properties
SelectedSignalName
    end

    properties(Access=private)


VisualSummaryDockableFigure


ROIVisualSummaryPanel
SceneVisualSummaryPanel
ROITitlePanel
SceneTitlePanel

SignalNamePanel
SignalNameText
SignalNamePU


ComparePanel


VisualSummaryButton
CompareButton


VisualSummaryCheckBox


ROITitle
SceneTitle


ROIItemHeight
SceneItemHeight


NumberOfROIItems
NumberOfSceneItems


WindowMotionFcnCallback


        ROIItemsCheckedIndices=[];
        SceneItemsCheckedIndices=[];



        IsShapeLabelPlotPresent=false;
        IsPixelLabelPlotPresent=false;

        IsCompareSummaryOpen=false;


MouseReleaseListener

        IsSliderButtonUp=true;
        IsSliderLineMoved=false;

KeyPressCallbackCache

        CharDimSelectAllBox;
        CharDimCompareButton;


PrevUnlabeledButton
NextUnlabeledButton
UnlabeledBtnText





        ROILabelNames={}
        SceneLabelNames={}

SignalInvaild
SignalInvaildText
ROIInvaild
ROIInvaildText
AnnotationSummaryManager
    end

    properties(Constant,Access=private)

        MinROIItemHeight=120;
        MinSceneItemHeight=85;
        MaxROIItemHeight=160;
        MaxSceneItemHeight=113;
        MaxCompareROIItemHeight=300;
        UnlabeledFrameBtnSize=15;
        UnlabeledBtnLoc=[0.47,0.91,0,0];
        CompareButtonXPos=0.05;
    end

    properties(Access=private)
        CaughtExceptionDuringPlay=false;
    end

    properties(Dependent)


Name
    end

    events
SliderLineMoved
SliderLineRelease


FigureDocked
FigureUndocked
FigureClosed



ButtonPressed

SignalChanged
    end

    methods

        function hFig=get.VisualSummaryFigure(this)
            hFig=this.VisualSummaryDockableFigure.Figure;
        end


        function hFig=get.Fig(this)
            hFig=this.VisualSummaryDockableFigure.Figure;
        end


        function TF=isDocked(this)
            TF=isDocked(this.VisualSummaryDockableFigure);
        end
    end

    methods

        function this=VisualSummaryDisplay(annoSummaryManager,toolType)
            this.AnnotationSummaryManager=annoSummaryManager;

            if annoSummaryManager.SignalType==vision.labeler.loading.SignalType.Image...
                &&annoSummaryManager.SignalValid==1

                layoutDockableFigure(this);
                layoutSignalName(this,annoSummaryManager);

                if annoSummaryManager.NumAnnotationSummaries<1
                    return;
                end





                layoutCheckBox(this);

                layoutViewButtons(this);
                thisAnnoSummaryObj=getAnnotationSummaryFromIdNoCheck(annoSummaryManager,1);
                thisAnnoSummaryInfo=thisAnnoSummaryObj.AnnotationSummary_;
                roiLabelDefs=thisAnnoSummaryInfo.ROILabelDefs;
                sceneLabelDefs=thisAnnoSummaryInfo.SceneLabelDefs;

                this.NumberOfROIItems=size(roiLabelDefs.Names,2);
                this.NumberOfSceneItems=size(sceneLabelDefs.Names,2);

                this.ROIItemHeight=this.MinROIItemHeight;
                this.SceneItemHeight=this.MinSceneItemHeight;

                if this.NumberOfROIItems>0
                    addROISummaryItems(this,thisAnnoSummaryInfo);
                end

                if this.NumberOfSceneItems>0
                    addSceneSummaryItems(this,thisAnnoSummaryInfo);
                end

                if numel(annoSummaryManager.SignalNames{:})==1
                    this.SignalNameText.Enable='off';
                    this.SignalNamePU.Enable='off';
                end

                if((toolType==vision.internal.toolType.ImageLabeler)||...
                    (toolType==vision.internal.toolType.VideoLabeler))
                    this.SignalNameText.Visible='off';
                    this.SignalNamePU.Visible='off';
                end

                this.VisualSummaryFigure.SizeChangedFcn=@(varargin)this.doPanelPositionUpdate;
                this.VisualSummaryFigure.WindowButtonMotionFcn=@(varargin)this.setScrollCallback();



                this.VisualSummaryCheckBox.Value=1;
                selectAllCheckBoxes(this);
            else
                if annoSummaryManager.SignalType==vision.labeler.loading.SignalType.PointCloud...
                    &&annoSummaryManager.SignalValid==1
                    layoutDockableFigure(this);
                    layoutSignalName(this,annoSummaryManager);
                    if annoSummaryManager.NumAnnotationSummaries<1
                        return;
                    end
                    layoutCheckBox(this);

                    layoutViewButtons(this);
                    thisAnnoSummaryObj=getAnnotationSummaryFromIdNoCheck(annoSummaryManager,1);
                    thisAnnoSummaryInfo=thisAnnoSummaryObj.AnnotationSummary_;
                    roiLabelDefs=thisAnnoSummaryInfo.ROILabelDefs;
                    sceneLabelDefs=thisAnnoSummaryInfo.SceneLabelDefs;

                    this.NumberOfROIItems=size(roiLabelDefs.Names,2);
                    this.NumberOfSceneItems=size(sceneLabelDefs.Names,2);

                    this.ROIItemHeight=this.MinROIItemHeight;
                    this.SceneItemHeight=this.MinSceneItemHeight;

                    if isempty(roiLabelDefs.Type)&&isempty(sceneLabelDefs.Names)
                        ROIinvaild(this);
                        this.CompareButton.Enable='off';
                        this.VisualSummaryButton.Enable='off';
                        this.VisualSummaryCheckBox.Enable='off';
                        this.PrevUnlabeledButton.Enable='off';
                        this.NextUnlabeledButton.Enable='off';
                        this.UnlabeledBtnText.Enable='off';
                        this.SignalNameText.Enable='on';
                        this.SignalNamePU.Enable='on';
                    else
                        if this.NumberOfROIItems>0
                            addROISummaryItems(this,thisAnnoSummaryInfo);
                        end

                        if this.NumberOfSceneItems>0
                            addSceneSummaryItems(this,thisAnnoSummaryInfo);
                        end
                    end

                    if numel(annoSummaryManager.SignalNames{:})==1
                        this.SignalNameText.Enable='off';
                        this.SignalNamePU.Enable='off';
                    end



                    if toolType==vision.internal.toolType.LidarLabeler
                        this.SignalNameText.Visible='off';
                        this.SignalNamePU.Visible='off';
                    end

                    this.VisualSummaryFigure.SizeChangedFcn=@(varargin)this.doPanelPositionUpdate;
                    this.VisualSummaryFigure.WindowButtonMotionFcn=@(varargin)this.setScrollCallback();



                    this.VisualSummaryCheckBox.Value=1;
                    selectAllCheckBoxes(this);
                else
                    if annoSummaryManager.SignalValid==0
                        layoutDockableFigure(this);
                        layoutSignalName(this,annoSummaryManager);
                        layoutCheckBox(this);

                        layoutViewButtons(this);
                        this.NumberOfROIItems=0;
                        this.NumberOfSceneItems=0;

                        this.ROIItemHeight=this.MinROIItemHeight;
                        this.SceneItemHeight=this.MinSceneItemHeight;
                        signalInvaild(this);
                        this.CompareButton.Enable='off';
                        this.VisualSummaryButton.Enable='off';
                        this.VisualSummaryCheckBox.Enable='off';
                        this.PrevUnlabeledButton.Enable='off';
                        this.NextUnlabeledButton.Enable='off';
                        this.UnlabeledBtnText.Enable='off';
                        this.SignalNameText.Enable='on';
                        this.SignalNamePU.Enable='on';
                        this.VisualSummaryFigure.SizeChangedFcn=@(varargin)this.doPanelPositionUpdate;
                    end
                end

            end
        end


        function name=get.Name(this)
            name=this.VisualSummaryFigure.Name;
        end


        function configure(this,keyPressCallback,deleteCallback)
            this.VisualSummaryFigure.DeleteFcn=deleteCallback;
            this.KeyPressCallbackCache=keyPressCallback;
        end


        function addFigureToApp(this,container)
            addFigureToApp(this.VisualSummaryDockableFigure,container);
            this.VisualSummaryFigure.WindowStyle='normal';
            show(this);
        end


        function show(this)
            this.VisualSummaryFigure.Visible='on';
        end


        function addROISummaryItems(this,annotationInfo)

            roiLabelDefs=annotationInfo.ROILabelDefs;
            timeVector=annotationInfo.TimeVector;
            if isrow(timeVector)
                timeVector=timeVector';
            end
            numROIAnnotationStruct=annotationInfo.NumROIAnnotations;
            currentTime=annotationInfo.CurrentValue;

            numDefs=size(roiLabelDefs.Names,2);


            if isempty(this.ROIVisualSummaryPanel)||~isvalid(this.ROIVisualSummaryPanel)
                this.NumberOfROIItems=numDefs;
                this.createROISummaryPanel();
                this.CompareButton.Enable='on';
                this.VisualSummaryCheckBox.Enable='on';
                this.PrevUnlabeledButton.Enable='on';
                this.NextUnlabeledButton.Enable='on';
                this.UnlabeledBtnText.Enable='on';
            end

            for i=1:numDefs
                data.Name=roiLabelDefs.Names{i};
                data.Color=roiLabelDefs.Colors{i};
                if timeVector(1)==0
                    lastFrameExist_time=timeVector(end)-(timeVector(end)/length(timeVector));
                    data.Time=[timeVector(1:end-1);lastFrameExist_time;timeVector(end)];
                    data.Data=[numROIAnnotationStruct.(roiLabelDefs.Names{i}),(numROIAnnotationStruct.(roiLabelDefs.Names{i})(end))];
                else
                    data.Time=timeVector;
                    data.Data=numROIAnnotationStruct.(roiLabelDefs.Names{i});
                end
                data.Type=roiLabelDefs.Type{i};
                data.CurrTime=currentTime;
                data.ItemHeight=this.ROIItemHeight;
                data.ComparisonMode=0;
                this.ROIVisualSummaryPanel.appendItem(data);
                this.ROIVisualSummaryPanel.Items{end}.SliderLine.ButtonDownFcn=@this.sliderButtonDownCallback;
                addlistener(this.ROIVisualSummaryPanel.Items{end},'CheckBoxClicked',@this.updateCompareSummaryButton);
                addlistener(this.ROIVisualSummaryPanel.Items{end},'ButtonPressed',@this.notifyButtonPressed);
                this.ROIVisualSummaryPanel.Items{end}.AxisHandle.ButtonDownFcn=@this.summaryButtonDownCallback;




                this.ROILabelNames(end+1)=roiLabelDefs.Names(i);
            end
            this.ROIVisualSummaryPanel.updateItem();
            this.NumberOfROIItems=size(this.ROIVisualSummaryPanel.Items,2);
            updateSelectAllCheckBox(this);

            if this.IsCompareSummaryOpen


                if this.NumberOfROIItems
                    this.ROIVisualSummaryPanel.hidePanel();
                    this.ROITitlePanel.Visible='off';
                end
            end
        end


        function signalName=getSelectedSignalName(this)

            if~isempty(this.SignalNamePU)&&numel(this.AnnotationSummaryManager.SignalNames{:})>1
                v=this.SignalNamePU.Value;
                signalName=this.SignalNamePU.String(v);
            else
                signalName=this.SignalNamePU.String;
            end

        end


        function exceptionDuringPlayListener(this,varargin)

            this.CaughtExceptionDuringPlay=true;
        end


        function resetExceptionDuringPlay(this)
            this.CaughtExceptionDuringPlay=false;
        end


        function addSceneSummaryItems(this,annotationInfo)

            sceneLabelDefs=annotationInfo.SceneLabelDefs;
            timeVector=annotationInfo.TimeVector;
            if isrow(timeVector)
                timeVector=timeVector';
            end
            numSceneAnnotationStruct=annotationInfo.NumSceneAnnotations;
            currentTime=annotationInfo.CurrentValue;

            numDefs=size(sceneLabelDefs.Names,2);


            if isempty(this.SceneVisualSummaryPanel)||~isvalid(this.SceneVisualSummaryPanel)
                this.NumberOfSceneItems=numDefs;
                this.createSceneSummaryPanel();
            end

            for i=1:numDefs
                data.Name=sceneLabelDefs.Names{i};
                data.Color=sceneLabelDefs.Colors{i};
                if timeVector(1)==0
                    lastFrameExist_time=timeVector(end)-(timeVector(end)/length(timeVector));
                    data.Time=[timeVector(1:end-1);lastFrameExist_time;timeVector(end)];
                    data.Data=[numSceneAnnotationStruct.(sceneLabelDefs.Names{i}),numSceneAnnotationStruct.(sceneLabelDefs.Names{i})(end)];
                else
                    data.Time=timeVector;
                    data.Data=numSceneAnnotationStruct.(sceneLabelDefs.Names{i});
                end
                data.Type=labelType.Scene;
                data.CurrTime=currentTime;
                data.ItemHeight=this.SceneItemHeight;
                data.ComparisonMode=0;
                this.SceneVisualSummaryPanel.appendItem(data);
                this.SceneVisualSummaryPanel.Items{end}.SliderLine.ButtonDownFcn=@this.sliderButtonDownCallback;
                addlistener(this.SceneVisualSummaryPanel.Items{end},'CheckBoxClicked',@this.updateCompareSummaryButton);
                addlistener(this.SceneVisualSummaryPanel.Items{end},'ButtonPressed',@this.notifyButtonPressed);

                this.SceneVisualSummaryPanel.Items{end}.AxisHandle.ButtonDownFcn=@this.summaryButtonDownCallback;





                this.SceneLabelNames(end+1)=sceneLabelDefs.Names(i);
            end
            this.SceneVisualSummaryPanel.updateItem();
            this.NumberOfSceneItems=size(this.SceneVisualSummaryPanel.Items,2);
            updateSelectAllCheckBox(this);

            if this.IsCompareSummaryOpen


                if this.NumberOfSceneItems
                    this.SceneVisualSummaryPanel.hidePanel();
                    this.SceneTitlePanel.Visible='off';
                end
            end
        end


        function deleteROIItem(this,data)
            if isempty(data.Index)&&data.ROINumLabels==1&&data.SceneNumLabels==0
                close(this.VisualSummaryFigure);
                return;
            else
                if isempty(data.Index)
                    return;
                end
            end
            this.ROIVisualSummaryPanel.deleteItem(data);

            this.ROILabelNames(data.Index)=[];

            this.NumberOfROIItems=this.NumberOfROIItems-1;
            if this.NumberOfROIItems==0
                this.ROIVisualSummaryPanel.deleteROIPanel();
                delete(this.ROIVisualSummaryPanel);
                delete(this.ROITitlePanel);
            end

            this.doPanelPositionUpdate();



            idxToDelete=find(this.ROIItemsCheckedIndices==data.Index);
            this.ROIItemsCheckedIndices(idxToDelete)=[];



            for idx=data.Index:numel(this.ROIItemsCheckedIndices)
                this.ROIItemsCheckedIndices(idx)=this.ROIItemsCheckedIndices(idx)-1;
            end

            if this.IsCompareSummaryOpen


                if~isempty(idxToDelete)



                    checkedName=data.LabelName;
                    for idx=1:length(this.ComparePanel.Items)
                        plotHandle=findall(this.ComparePanel.Items{idx}.AxisHandle,'Tag',['Plot_',checkedName]);
                        delete(plotHandle);
                    end
                end



                if~isempty(idxToDelete)&&isempty(this.ROIItemsCheckedIndices)
                    this.ComparePanel.deleteItem(data);
                end


                idx=1;
                while~isempty(this.ComparePanel.Items)
                    if numel(this.ComparePanel.Items{idx}.AxisHandle.Children)==1

                        compareItem.Index=idx;
                        this.ComparePanel.deleteItem(compareItem);
                    else
                        idx=idx+1;
                    end
                    if idx>length(this.ComparePanel.Items)
                        break
                    end
                end



                totalNumCheckedItems=numel(this.ROIItemsCheckedIndices)+numel(this.SceneItemsCheckedIndices);
                if totalNumCheckedItems==0
                    close(this.VisualSummaryFigure);
                    return;
                end
            end

            updateSelectAllCheckBox(this);

            totalNumItems=(this.NumberOfROIItems+this.NumberOfSceneItems);
            if totalNumItems==0
                close(this.VisualSummaryFigure);
            end
        end


        function renameROIItem(this,idx,oldName,newName)
            if isempty(idx)

                return;
            end
            this.ROIVisualSummaryPanel.modifyItemData(idx,newName);


            this.ROILabelNames{idx}=newName;


            if this.IsCompareSummaryOpen&&...
                any(this.ROIItemsCheckedIndices==idx)
                plot=this.findPlotHandle(oldName);
                if~isempty(plot)
                    plotTag=strcat('Plot_',newName);
                    plot.Tag=plotTag;
                end
            end
        end


        function changeColorROIItem(this,idx,labelName,newColor)
            if isempty(idx)

                return;
            end
            this.ROIVisualSummaryPanel.modifyItemData(idx,newColor);


            if this.IsCompareSummaryOpen&&...
                any(this.ROIItemsCheckedIndices==idx)
                plot=this.findPlotHandle(labelName);
                if~isempty(plot)
                    if isprop(plot,'Color')
                        plot.Color=newColor;
                    else
                        plot.FaceColor=newColor;
                    end
                end
            end
        end


        function renamesceneItem(this,idx,oldName,newName)
            this.SceneVisualSummaryPanel.modifyItemData(idx,newName);


            if this.IsCompareSummaryOpen&&...
                any(this.SceneItemsCheckedIndices==idx)

                idToChange=this.IsShapeLabelPlotPresent+...
                this.IsPixelLabelPlotPresent+idx;
                this.ComparePanel.Items{idToChange}.CheckBox.String=...
                newName;

                plot=this.findPlotHandle(oldName);
                if~isempty(plot)
                    plotTag=strcat('Plot_',newName);
                    plot.Tag=plotTag;
                end
            end
        end


        function changeColorsceneItem(this,idx,labelName,newColor)
            this.SceneVisualSummaryPanel.modifyItemData(idx,newColor);

            if this.IsCompareSummaryOpen&&...
                any(this.SceneItemsCheckedIndices==idx)
                plot=this.findPlotHandle(labelName);
                if~isempty(plot)
                    plot.Color=newColor;
                end
            end
        end


        function deleteSceneItem(this,data)

            this.SceneVisualSummaryPanel.deleteItem(data);

            this.SceneLabelNames(data.Index)=[];

            this.NumberOfSceneItems=this.NumberOfSceneItems-1;
            if this.NumberOfSceneItems==0
                this.SceneVisualSummaryPanel.deleteScenePanel();
                delete(this.SceneVisualSummaryPanel);
                delete(this.SceneTitlePanel);
            end

            this.doPanelPositionUpdate();



            idxToDelete=find(this.SceneItemsCheckedIndices==data.Index);
            this.SceneItemsCheckedIndices(idxToDelete)=[];



            for idx=data.Index:numel(this.SceneItemsCheckedIndices)
                this.SceneItemsCheckedIndices(idx)=this.SceneItemsCheckedIndices(idx)-1;
            end

            if this.IsCompareSummaryOpen



















                if~isempty(idxToDelete)


                    if~isempty(this.ROIItemsCheckedIndices)







                        firstItemType=this.ComparePanel.Items{1}.LabelType;
                        secondItemType=this.ComparePanel.Items{2}.LabelType;
                        addIdx=0;
                        addIdx=addIdx+double((firstItemType==labelType.Rectangle)...
                        ||(firstItemType==labelType.Line)...
                        ||(firstItemType==labelType.Polygon)...
                        ||(firstItemType==labelType.ProjectedCuboid)...
                        ||(firstItemType==labelType.PixelLabel));
                        addIdx=addIdx+double((secondItemType==labelType.Rectangle)...
                        ||(secondItemType==labelType.Line)...
                        ||(secondItemType==labelType.Polygon)...
                        ||(secondItemType==labelType.ProjectedCuboid)...
                        ||(secondItemType==labelType.PixelLabel));
                        data.Index=idxToDelete+addIdx;
                    end
                    this.ComparePanel.deleteItem(data);
                end



                totalNumCheckedItems=numel(this.ROIItemsCheckedIndices)+numel(this.SceneItemsCheckedIndices);
                if totalNumCheckedItems==0
                    close(this.VisualSummaryFigure);
                    return;
                end
            end

            updateSelectAllCheckBox(this);

            totalNumItems=(this.NumberOfROIItems+this.NumberOfSceneItems);
            if totalNumItems==0
                close(this.VisualSummaryFigure);
            end
        end


        function doPanelPositionUpdate(this)

            positions=getPanelPositions(this);


            for i=1:this.NumberOfROIItems
                this.ROIVisualSummaryPanel.Items{i}.PanelHeight=this.ROIItemHeight;
            end

            for i=1:this.NumberOfSceneItems
                this.SceneVisualSummaryPanel.Items{i}.PanelHeight=this.SceneItemHeight;
            end


            if this.NumberOfROIItems>0
                this.ROIVisualSummaryPanel.Position=positions.ROIPanelPos;
                this.ROITitlePanel.Position=positions.ROITitlePanelPos;
            end

            if this.NumberOfSceneItems>0
                this.SceneVisualSummaryPanel.Position=positions.ScenePanelPos;
                this.SceneTitlePanel.Position=positions.SceneTitlePanelPos;
            end

            if this.IsCompareSummaryOpen
                this.ComparePanel.Position=positions.ComparePanelPos;
            end



            normSelectAllDims=hgconvertunits(this.VisualSummaryFigure,this.CharDimSelectAllBox,'char','normalized',this.VisualSummaryFigure);
            this.VisualSummaryCheckBox.Position(3)=normSelectAllDims(3);

            normCompareBtnDims=hgconvertunits(this.VisualSummaryFigure,this.CharDimCompareButton,'char','normalized',this.VisualSummaryFigure);
            this.CompareButton.Position(1)=this.CompareButtonXPos;
            this.CompareButton.Position(3)=normCompareBtnDims(3);
            this.VisualSummaryButton.Position=this.CompareButton.Position;

            btnLocPixel=hgconvertunits(this.VisualSummaryFigure,this.UnlabeledBtnLoc,'normalized','pixels',this.VisualSummaryFigure);
            prevUnlabeledBtnPos=[btnLocPixel(1),btnLocPixel(2),this.UnlabeledFrameBtnSize,this.UnlabeledFrameBtnSize];
            nextUnlabeledTypeBtnPos=[btnLocPixel(1)+20,btnLocPixel(2),this.UnlabeledFrameBtnSize,this.UnlabeledFrameBtnSize];
            this.PrevUnlabeledButton.Position=prevUnlabeledBtnPos;
            this.NextUnlabeledButton.Position=nextUnlabeledTypeBtnPos;
        end


        function updateSliderLine(this,currentTime)

            if this.IsSliderLineMoved

                return;
            end

            currentTime=getSliderValueInLimits(this,currentTime);
            for idx=1:this.NumberOfROIItems
                this.ROIVisualSummaryPanel.Items{idx}.SliderLine.XData=[currentTime,currentTime];
            end

            for idx=1:this.NumberOfSceneItems
                this.SceneVisualSummaryPanel.Items{idx}.SliderLine.XData=[currentTime,currentTime];
            end

            if this.IsCompareSummaryOpen
                totalNumCompareItems=length(this.ComparePanel.Items);
                for idx=1:totalNumCompareItems
                    this.ComparePanel.Items{idx}.SliderLine.XData=[currentTime,currentTime];
                end
            end
        end


        function updateROICounts(this,labelIds,signalName,labelCounts,currTimeIndex,isPixelLabel,isChanged,isChangeInLastFrame)
            for idx=1:this.NumberOfROIItems
                if~isempty(find(labelIds==idx,1))&&isChanged(idx)&&...
                    (isempty(signalName)||signalName==string(getSelectedSignalName(this)))
                    this.ROIVisualSummaryPanel.Items{idx}.PlotHandle.YData(currTimeIndex)=labelCounts(labelIds==idx);
                    if isChangeInLastFrame
                        this.ROIVisualSummaryPanel.Items{idx}.PlotHandle.YData(currTimeIndex+1)=this.ROIVisualSummaryPanel.Items{idx}.PlotHandle.YData(currTimeIndex);
                    end


                    if~isPixelLabel(idx)
                        this.ROIVisualSummaryPanel.Items{idx}.adjustYLimits(1);
                    end
                end
            end

            if this.IsCompareSummaryOpen


                lenCompareItems=length(this.ComparePanel.Items);
                for cIdx=1:lenCompareItems
                    if(this.ComparePanel.Items{cIdx}.LabelType==labelType.PixelLabel)

                        for roiIdx=1:numel(this.ROIItemsCheckedIndices)
                            checkedIndex=this.ROIItemsCheckedIndices(roiIdx);
                            checkedName=this.ROIVisualSummaryPanel.Items{checkedIndex}.LabelName;
                            plotHandle=findall(this.ComparePanel.Items{cIdx}.AxisHandle,'Tag',['Plot_',checkedName]);
                            if~isempty(plotHandle)
                                plotHandle.YData(currTimeIndex)=this.ROIVisualSummaryPanel.Items{checkedIndex}.PlotHandle.YData(currTimeIndex);
                            end
                        end
                    elseif(this.ComparePanel.Items{cIdx}.LabelType==labelType.Rectangle)...
                        ||(this.ComparePanel.Items{cIdx}.LabelType==labelType.Line)...
                        ||(this.ComparePanel.Items{cIdx}.LabelType==labelType.Polygon)...
                        ||(this.ComparePanel.Items{cIdx}.LabelType==labelType.ProjectedCuboid)

                        maxValue=0;
                        minValue=0;
                        for roiIdx=1:numel(this.ROIItemsCheckedIndices)
                            checkedIndex=this.ROIItemsCheckedIndices(roiIdx);
                            checkedName=this.ROIVisualSummaryPanel.Items{checkedIndex}.LabelName;
                            plotHandle=findall(this.ComparePanel.Items{cIdx}.AxisHandle,'Tag',['Plot_',checkedName]);
                            if~isempty(plotHandle)
                                plotHandle.YData(currTimeIndex)=this.ROIVisualSummaryPanel.Items{checkedIndex}.PlotHandle.YData(currTimeIndex);
                                maxValue=max(max(plotHandle.YData(:)),maxValue);
                                minValue=min(min(plotHandle.YData(:)),minValue);
                            end
                        end
                        this.ComparePanel.Items{1}.adjustYLimits(1,[minValue,maxValue]);
                    end
                end
            end
        end


        function updateSceneCounts(this,signalName,labelId,labelName,value,timeIndices,isChangeInLastFrame)

            if isempty(signalName)||(signalName==string(getSelectedSignalName(this)))
                this.SceneVisualSummaryPanel.Items{labelId}.PlotHandle.YData(timeIndices)=value;
                if(isChangeInLastFrame)
                    this.SceneVisualSummaryPanel.Items{labelId}.PlotHandle.YData(timeIndices+1)=this.SceneVisualSummaryPanel.Items{labelId}.PlotHandle.YData(timeIndices);
                end
                this.SceneVisualSummaryPanel.Items{labelId}.adjustYTicks(0);
            end

            if this.IsCompareSummaryOpen

                lenCompareItems=length(this.ComparePanel.Items);
                for cIdx=1:lenCompareItems
                    if(this.ComparePanel.Items{cIdx}.LabelType==labelType.Scene)&&...
                        (this.ComparePanel.Items{cIdx}.CheckBox.String==string(labelName))
                        this.ComparePanel.Items{cIdx}.PlotHandle.YData(timeIndices)=this.SceneVisualSummaryPanel.Items{labelId}.PlotHandle.YData(timeIndices);
                    end
                end
            end
        end


        function updateAllItems(this,annotationInfo)

            roiLabelDefs=annotationInfo.ROILabelDefs;
            sceneLabelDefs=annotationInfo.SceneLabelDefs;
            timeVector=annotationInfo.TimeVector;
            numROIAnnotationStruct=annotationInfo.NumROIAnnotations;
            numSceneAnnotationStruct=annotationInfo.NumSceneAnnotations;
            currentTime=annotationInfo.CurrentValue;

            if isempty(roiLabelDefs.Names)&&isempty(sceneLabelDefs.Names)
                return;
            end

            currentTime=this.getSliderValueInLimits(currentTime,[min(timeVector),max(timeVector)]);

            for idx=1:this.NumberOfROIItems
                if timeVector(1)==0
                    lastFrameExist_time=timeVector(end)-(timeVector(end)/length(timeVector));
                    this.ROIVisualSummaryPanel.Items{idx}.PlotHandle.XData=[timeVector(1:end-1);lastFrameExist_time;timeVector(end)];
                    this.ROIVisualSummaryPanel.Items{idx}.PlotHandle.YData=[numROIAnnotationStruct.(roiLabelDefs.Names{idx}),numROIAnnotationStruct.(roiLabelDefs.Names{idx})(end)];
                else
                    this.ROIVisualSummaryPanel.Items{idx}.PlotHandle.XData=timeVector;
                    this.ROIVisualSummaryPanel.Items{idx}.PlotHandle.YData=numROIAnnotationStruct.(roiLabelDefs.Names{idx});
                end
                this.ROIVisualSummaryPanel.Items{idx}.SliderLine.XData=[currentTime,currentTime];
                this.ROIVisualSummaryPanel.Items{idx}.AxisHandle.XLim=[min(timeVector),max(timeVector)];
                this.ROIVisualSummaryPanel.Items{idx}.adjustXTicks();

                if(this.ROIVisualSummaryPanel.Items{idx}.LabelType~=labelType.PixelLabel)
                    this.ROIVisualSummaryPanel.Items{idx}.adjustYLimits(1);
                end
            end

            for idx=1:this.NumberOfSceneItems
                if timeVector(1)==0
                    this.SceneVisualSummaryPanel.Items{idx}.PlotHandle.YData=[double(numSceneAnnotationStruct.(sceneLabelDefs.Names{idx})),double(numSceneAnnotationStruct.(sceneLabelDefs.Names{idx})(end))];
                    lastFrameExist_time=timeVector(end)-(timeVector(end)/length(timeVector));
                    this.SceneVisualSummaryPanel.Items{idx}.PlotHandle.XData=[timeVector(1:end-1);lastFrameExist_time;timeVector(end)];
                else
                    this.SceneVisualSummaryPanel.Items{idx}.PlotHandle.YData=double(numSceneAnnotationStruct.(sceneLabelDefs.Names{idx}));
                    this.SceneVisualSummaryPanel.Items{idx}.PlotHandle.XData=timeVector;
                end
                this.SceneVisualSummaryPanel.Items{idx}.SliderLine.XData=[currentTime,currentTime];
                this.SceneVisualSummaryPanel.Items{idx}.AxisHandle.XLim=[min(timeVector),max(timeVector)];
                this.SceneVisualSummaryPanel.Items{idx}.adjustXTicks();
                this.SceneVisualSummaryPanel.Items{idx}.adjustYTicks(0);
            end

            if this.IsCompareSummaryOpen
                shapeComparePanelAvailable=0;
                pixelComparePanelAvailable=0;

                totalNumCompareItems=length(this.ComparePanel.Items);

                for idx=1:totalNumCompareItems
                    if(this.ComparePanel.Items{idx}.LabelType==labelType.Rectangle)...
                        ||(this.ComparePanel.Items{idx}.LabelType==labelType.Line)...
                        ||(this.ComparePanel.Items{idx}.LabelType==labelType.Polygon)...
                        ||(this.ComparePanel.Items{idx}.LabelType==labelType.ProjectedCuboid)



                        maxValue=0;
                        minValue=0;

                        shapeComparePanelAvailable=1;



                        for roiIdx=1:numel(this.ROIItemsCheckedIndices)
                            checkedIndex=this.ROIItemsCheckedIndices(roiIdx);
                            checkedName=roiLabelDefs.Names{checkedIndex};
                            plotHandle=findall(this.ComparePanel.Items{idx}.AxisHandle,'Tag',['Plot_',checkedName]);
                            if~isempty(plotHandle)
                                plotHandle.XData=this.ROIVisualSummaryPanel.Items{checkedIndex}.PlotHandle.XData;
                                plotHandle.YData=this.ROIVisualSummaryPanel.Items{checkedIndex}.PlotHandle.YData;
                                maxValue=max(max(plotHandle.YData(:)),maxValue);
                                minValue=min(min(plotHandle.YData(:)),minValue);
                            end
                        end


                        this.ComparePanel.Items{idx}.AxisHandle.XLim=this.ROIVisualSummaryPanel.Items{checkedIndex}.AxisHandle.XLim;
                        this.ComparePanel.Items{idx}.SliderLine.XData=this.ROIVisualSummaryPanel.Items{checkedIndex}.SliderLine.XData;
                        this.ComparePanel.Items{idx}.adjustXTicks();
                        this.ComparePanel.Items{idx}.adjustYLimits(1,[minValue,maxValue]);
                    elseif(this.ComparePanel.Items{idx}.LabelType==labelType.PixelLabel)



                        pixelComparePanelAvailable=1;

                        for roiIdx=1:numel(this.ROIItemsCheckedIndices)
                            checkedIndex=this.ROIItemsCheckedIndices(roiIdx);
                            checkedName=roiLabelDefs.Names{checkedIndex};
                            plotHandle=findall(this.ComparePanel.Items{idx}.AxisHandle,'Tag',['Plot_',checkedName]);
                            if~isempty(plotHandle)
                                plotHandle.XData=this.ROIVisualSummaryPanel.Items{checkedIndex}.PlotHandle.XData;
                                plotHandle.YData=this.ROIVisualSummaryPanel.Items{checkedIndex}.PlotHandle.YData;
                                maxValue=max(max(plotHandle.YData(:)),maxValue);
                                minValue=min(min(plotHandle.YData(:)),minValue);
                            end
                        end
                        this.ComparePanel.Items{idx}.AxisHandle.XLim=this.ROIVisualSummaryPanel.Items{checkedIndex}.AxisHandle.XLim;
                        this.ComparePanel.Items{idx}.adjustXTicks();
                        this.ComparePanel.Items{idx}.SliderLine.XData=this.ROIVisualSummaryPanel.Items{checkedIndex}.SliderLine.XData;
                    elseif(this.ComparePanel.Items{idx}.LabelType==labelType.Scene)


                        indexValue=idx-shapeComparePanelAvailable-pixelComparePanelAvailable;
                        checkedIndex=this.SceneItemsCheckedIndices(indexValue);
                        this.ComparePanel.Items{idx}.PlotHandle.XData=this.SceneVisualSummaryPanel.Items{checkedIndex}.PlotHandle.XData;
                        this.ComparePanel.Items{idx}.PlotHandle.YData=this.SceneVisualSummaryPanel.Items{checkedIndex}.PlotHandle.YData;
                        this.ComparePanel.Items{idx}.AxisHandle.XLim=this.SceneVisualSummaryPanel.Items{checkedIndex}.AxisHandle.XLim;
                        this.ComparePanel.Items{idx}.adjustXTicks();
                        this.ComparePanel.Items{idx}.SliderLine.XData=this.SceneVisualSummaryPanel.Items{checkedIndex}.SliderLine.XData;
                    end
                end
            end
        end


        function configureSliderCallback(this,enable)

            if enable
                fcnHandle=@this.sliderButtonDownCallback;
            else
                fcnHandle=[];
            end
            for idx=1:this.NumberOfROIItems
                this.ROIVisualSummaryPanel.Items{idx}.SliderLine.ButtonDownFcn=fcnHandle;
            end

            for idx=1:this.NumberOfSceneItems
                this.SceneVisualSummaryPanel.Items{idx}.SliderLine.ButtonDownFcn=fcnHandle;
            end

            if this.IsCompareSummaryOpen
                lenCompareItems=length(this.ComparePanel.Items);
                for cIdx=1:lenCompareItems
                    this.ComparePanel.Items{cIdx}.SliderLine.ButtonDownFcn=fcnHandle;
                end
            end
        end


        function dockVisualSummary(this)
            doDock(this.VisualSummaryDockableFigure);
        end


        function undockVisualSummary(this)
            doUndock(this.VisualSummaryDockableFigure);
        end


        function close(this)

            if isvalid(this)
                if ishandle(this.VisualSummaryFigure)
                    close(this.VisualSummaryFigure);
                end
            end
            delete(this);
        end


        function compareLabelSummary(this)

            if this.IsCompareSummaryOpen
                return;
            end








            this.CompareButton.Visible='off';
            this.VisualSummaryButton.Visible='on';

            if this.NumberOfROIItems
                this.ROIVisualSummaryPanel.hidePanel();
                set(this.ROITitlePanel,'Visible','off');
            end

            if this.NumberOfSceneItems
                this.SceneVisualSummaryPanel.hidePanel();
                set(this.SceneTitlePanel,'Visible','off');
            end

            this.VisualSummaryCheckBox.Visible='off';
            this.VisualSummaryButton.Enable='on';
            this.PrevUnlabeledButton.Visible='off';
            this.NextUnlabeledButton.Visible='off';
            this.UnlabeledBtnText.Visible='off';
            this.SignalNameText.Enable='off';
            this.SignalNamePU.Enable='off';

            positions=getPanelPositions(this);
            this.ComparePanel=vision.internal.labeler.tool.VisualSummaryROIPanel(this.VisualSummaryFigure,positions.ComparePanelPos);
            this.IsCompareSummaryOpen=true;

            this.plotROICheckedItems();
            this.plotPixelCheckedItems();
            this.plotSceneCheckedItems();
        end


        function viewLabelSummary(this)

            if this.IsCompareSummaryOpen
                this.ComparePanel.deleteROIPanel();
                delete(this.ComparePanel);
                this.IsCompareSummaryOpen=false;
            end

            this.CompareButton.Visible='on';
            this.VisualSummaryButton.Visible='off';
            this.VisualSummaryCheckBox.Visible='on';
            this.PrevUnlabeledButton.Visible='on';
            this.NextUnlabeledButton.Visible='on';
            this.UnlabeledBtnText.Visible='on';
            if numel(this.AnnotationSummaryManager.SignalNames{:})>1
                this.SignalNameText.Enable='on';
                this.SignalNamePU.Enable='on';
            else
                this.SignalNameText.Enable='off';
                this.SignalNamePU.Enable='off';
            end

            if this.NumberOfROIItems>0
                this.ROIVisualSummaryPanel.show();
                set(this.ROITitlePanel,'Visible','on');
            end

            if this.NumberOfSceneItems>0
                this.SceneVisualSummaryPanel.show();
                set(this.SceneTitlePanel,'Visible','on');
            end
        end


        function selectSignalName(this)

            removeROISummaryPanel(this);
            this.SelectedSignalName=string(getSelectedSignalName(this));
            notify(this,'SignalChanged');

        end


        function updateVSummaryOnSignalChange(this,annoSummaryManager,signalType,isValidRange)

            if~isValidRange
                this.NumberOfROIItems=0;
                this.NumberOfSceneItems=0;

                this.ROIItemHeight=this.MinROIItemHeight;
                this.SceneItemHeight=this.MinSceneItemHeight;

                if isempty(this.SignalInvaild)
                    signalInvaild(this);
                else
                    this.ROIInvaild.Visible='off';
                    this.SignalInvaild.Visible='on';
                end

                if~isempty(this.ROIVisualSummaryPanel)
                    this.ROIVisualSummaryPanel.hidePanel();
                end

                if~isempty(this.SceneVisualSummaryPanel)
                    this.SceneVisualSummaryPanel.hidePanel();
                end
                vsDisplayItem(this);
            else
                thisAnnoSummaryInfo=annoSummaryManager;
                roiLabelDefs=thisAnnoSummaryInfo.ROILabelDefs;
                sceneLabelDefs=thisAnnoSummaryInfo.SceneLabelDefs;
                this.AnnotationSummaryManager.SignalType=signalType;

                this.NumberOfROIItems=size(roiLabelDefs.Names,2);
                this.NumberOfSceneItems=size(sceneLabelDefs.Names,2);

                this.ROIItemHeight=this.MinROIItemHeight;
                this.SceneItemHeight=this.MinSceneItemHeight;

                if thisAnnoSummaryInfo.CurrentValue>thisAnnoSummaryInfo.TimeVector(end)...
                    ||thisAnnoSummaryInfo.CurrentValue<thisAnnoSummaryInfo.TimeVector(1)
                    thisAnnoSummaryInfo.CurrentValue=thisAnnoSummaryInfo.TimeVector(end);
                end

                if isempty(thisAnnoSummaryInfo.ROILabelDefs.Type)&&isempty(thisAnnoSummaryInfo.SceneLabelDefs.Names)
                    if isempty(this.ROIInvaild)
                        ROIinvaild(this);
                    else
                        this.SignalInvaild.Visible='off';
                        this.ROIInvaild.Visible='on';
                    end
                    if~isempty(this.ROIVisualSummaryPanel)
                        this.ROIVisualSummaryPanel.hidePanel();
                    end
                    vsDisplayItem(this)
                else
                    this.ROIInvaild.Visible='off';
                    this.SignalInvaild.Visible='off';
                    this.CompareButton.Enable='on';
                    this.VisualSummaryCheckBox.Enable='on';
                    this.PrevUnlabeledButton.Enable='on';
                    this.NextUnlabeledButton.Enable='on';
                    this.UnlabeledBtnText.Enable='on';

                    if this.NumberOfROIItems>0
                        addROISummaryItems(this,thisAnnoSummaryInfo);
                    end

                    if this.NumberOfSceneItems>0
                        addSceneSummaryItems(this,thisAnnoSummaryInfo);
                    end

                    if this.NumberOfROIItems>0
                        this.ROIVisualSummaryPanel.show();
                        set(this.ROITitlePanel,'Visible','on');
                    end

                    if this.NumberOfSceneItems>0
                        this.SceneVisualSummaryPanel.show();
                        set(this.SceneTitlePanel,'Visible','on');
                    end

                    this.VisualSummaryFigure.SizeChangedFcn=@(varargin)this.doPanelPositionUpdate;
                    this.VisualSummaryFigure.WindowButtonMotionFcn=@(varargin)this.setScrollCallback();



                    this.VisualSummaryCheckBox.Value=1;
                    selectAllCheckBoxes(this);
                    this.doPanelPositionUpdate();
                end
            end
        end


        function updateVisualSummaryWithModifiedSignal(this,annoSummaryManager,toolType)
            if this.IsCompareSummaryOpen==0
                this.AnnotationSummaryManager=annoSummaryManager;
                signalType=annoSummaryManager.SignalType;

                layoutSignalName(this,annoSummaryManager);
                if numel(annoSummaryManager.SignalNames{:})>1
                    status='on';
                else
                    status='off';
                end
                this.SignalNameText.Enable=status;
                this.SignalNamePU.Enable=status;

                if((toolType==vision.internal.toolType.ImageLabeler)||...
                    (toolType==vision.internal.toolType.VideoLabeler)||...
                    (toolType==vision.internal.toolType.LidarLabeler))
                    this.SignalNameText.Visible='off';
                    this.SignalNamePU.Visible='off';
                end

                removeROISummaryPanel(this);
                annotationInfo=annoSummaryManager.AnnotationSummaries{1}.AnnotationSummary_;
                updateVSummaryOnSignalChange(this,annotationInfo,signalType,annoSummaryManager.SignalValid)
            end
        end

        function updateVisualSummaryInAlgorithm(this,annoSummaryManager,toolType)
            annotationInfo=annoSummaryManager.AnnotationSummaries{1}.AnnotationSummary_;
            if numel(annotationInfo.TimeVector)==1
                close(this.VisualSummaryFigure);
            else
                updateVisualSummaryWithModifiedSignal(this,annoSummaryManager,toolType);
            end
        end

    end

    methods(Access=public,Hidden)

        function TF=isCompareSummaryOpen(this)
            TF=this.IsCompareSummaryOpen;
        end


        function updateCompareSummaryButton(this,~,data)


            if strcmpi(data.CheckBoxTag,'ROI_Checkbox')
                if data.CheckBoxStatus==0
                    this.ROIItemsCheckedIndices(this.ROIItemsCheckedIndices==data.Index)=[];
                else
                    this.ROIItemsCheckedIndices(end+1)=data.Index;
                end
            else
                if data.CheckBoxStatus==0
                    this.SceneItemsCheckedIndices(this.SceneItemsCheckedIndices==data.Index)=[];
                else
                    this.SceneItemsCheckedIndices(end+1)=data.Index;
                end
            end

            numROIItemsChkd=numel(this.ROIItemsCheckedIndices);
            numSceneItemsChkd=numel(this.SceneItemsCheckedIndices);
            totalCheckedItems=(numROIItemsChkd+numSceneItemsChkd);



            if totalCheckedItems>=2
                this.CompareButton.Enable='on';
            else
                this.CompareButton.Enable='off';
            end

            updateSelectAllCheckBox(this);
        end


        function labelNames=getROILabelNames(this)
            labelNames=this.ROILabelNames;
        end


        function labelNames=getSceneLabelNames(this)
            labelNames=this.SceneLabelNames;
        end


        function flag=isPanelVisible(this)
            flag=strcmpi(this.VisualSummaryFigure.Visible,'on');
        end
    end

    methods(Access=private)

        function layoutDockableFigure(this)

            figurePos=this.calculateFigurePosition();

            this.VisualSummaryDockableFigure=vision.internal.uitools.DockableAppFigure(...
            'NumberTitle','off',...
            'IntegerHandle','off',...
            'Name',vision.getMessage('vision:labeler:LabelSummary'),...
            'Units','normalized',...
            'Position',figurePos,...
            'MenuBar','none',...
            'HandleVisibility','off',...
            'Visible','off');

            addlistener(this.VisualSummaryDockableFigure,'FigureDocked',@(~,~)notify(this,'FigureDocked'));
            addlistener(this.VisualSummaryDockableFigure,'FigureUndocked',@(~,~)notify(this,'FigureUndocked'));
            addlistener(this.VisualSummaryDockableFigure,'FigureClosed',@(~,~)notify(this,'FigureClosed'));
        end


        function layoutCheckBox(this)

            this.VisualSummaryCheckBox=uicontrol('Parent',this.VisualSummaryFigure,...
            'Style','checkbox',...
            'Value',1,...
            'Callback',@(varargin)this.selectAllCheckBoxes,...
            'Units','normalized',...
            'Position',[0.05,0.94,0.1,0.05],...
            'String',vision.getMessage('vision:labeler:SelectAll'),...
            'FontWeight','bold',...
            'HorizontalAlignment','left',...
            'HandleVisibility','callback',...
            'Tooltip',vision.getMessage('vision:labeler:SelectAllTooltip'),...
            'Tag','VisualSummaryCheckBox');

            this.CharDimSelectAllBox=hgconvertunits(this.VisualSummaryFigure,this.VisualSummaryCheckBox.Position,'normalized','char',this.VisualSummaryFigure);
        end


        function layoutSignalName(this,annoSummaryManager)


            signalNames=[annoSummaryManager.SignalNames{:}];
            signalId=annoSummaryManager.SelectedSignalID;

            this.SignalNamePanel=uipanel('Parent',this.VisualSummaryDockableFigure.Figure,...
            'BorderType','none',...
            'Title','',...
            'Units','Normalized',...
            'Position',[0.65,0.90,0.5,0.06],...
            'Visible','on',...
            'Tag','SignalNamePanel');

            this.SignalNameText=uicontrol('Parent',this.SignalNamePanel,...
            'Style','text',...
            'Units','characters',...
            'Position',[6,0.48,15,1.4],...
            'String',vision.getMessage('vision:labeler:SignalNameText'),...
            'FontWeight','bold',...
            'HorizontalAlignment','right',...
            'HandleVisibility','callback',...
            'Tag','SignalNameText');

            this.SignalNamePU=uicontrol('Parent',this.SignalNamePanel,...
            'Style','popupmenu',...
            'Value',signalId,...
            'Callback',@(varargin)this.selectSignalName,...
            'Units','characters',...
            'Position',[22,0.7,30,1.5],...
            'String',signalNames,...
            'FontWeight','bold',...
            'Enable','on',...
            'HorizontalAlignment','right',...
            'HandleVisibility','callback',...
            'Tag','SignalNamePulldown');

        end


        function layoutViewButtons(this)

            this.UnlabeledBtnText=uicontrol('Parent',this.VisualSummaryFigure,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.26,0.88,0.2,0.05],...
            'String',vision.getMessage('vision:labeler:PrevNextUnlabeledText'),...
            'HorizontalAlignment','right',...
            'HandleVisibility','callback',...
            'Tag','UnlabeledBtnText');

            iconLocation=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+videoLabeler','+tool');
            prevUnlabeledIcon=fullfile(iconLocation,'topreviousframe.png');
            btnCData=imread(prevUnlabeledIcon);
            btnLocPixel=hgconvertunits(this.VisualSummaryFigure,this.UnlabeledBtnLoc,'normalized','pixels',this.VisualSummaryFigure);
            prevUnlabeledBtnPos=[btnLocPixel(1),btnLocPixel(2),this.UnlabeledFrameBtnSize,this.UnlabeledFrameBtnSize];
            this.PrevUnlabeledButton=uicontrol('Parent',this.VisualSummaryFigure,...
            'Style','pushbutton',...
            'Callback',@(varargin)this.unlabeledBtnPressCallback(true),...
            'Units','pixels',...
            'Position',prevUnlabeledBtnPos,...
            'String','',...
            'HorizontalAlignment','left',...
            'HandleVisibility','callback',...
            'CData',btnCData,...
            'Tooltip',vision.getMessage('vision:labeler:PrevUnlabeledGlobal'),...
            'Tag','GlobalUnlabeledBtn_left');

            nextUnlabeledIcon=fullfile(iconLocation,'tonextframe.png');
            btnCData=imread(nextUnlabeledIcon);
            nextUnlabeledTypeBtnPos=[btnLocPixel(1)+20,btnLocPixel(2),this.UnlabeledFrameBtnSize,this.UnlabeledFrameBtnSize];
            this.NextUnlabeledButton=uicontrol('Parent',this.VisualSummaryFigure,...
            'Style','pushbutton',...
            'Callback',@(varargin)this.unlabeledBtnPressCallback(false),...
            'Units','pixels',...
            'Position',nextUnlabeledTypeBtnPos,...
            'String','',...
            'HorizontalAlignment','left',...
            'HandleVisibility','callback',...
            'CData',btnCData,...
            'Tooltip',vision.getMessage('vision:labeler:NextUnlabeledGlobal'),...
            'Tag','GlobalUnlabeledBtn_right');

            this.CompareButton=uicontrol('Parent',this.VisualSummaryFigure,...
            'Style','pushbutton',...
            'Callback',@(varargin)this.compareLabelSummary,...
            'Units','normalized',...
            'Position',[this.CompareButtonXPos,0.902,0.16,0.04],...
            'String',vision.getMessage('vision:labeler:CompareLabels'),...
            'HorizontalAlignment','left',...
            'Enable','off',...
            'HandleVisibility','callback',...
            'Tooltip',vision.getMessage('vision:labeler:CompareButtonTooltip'),...
            'Tag','CompareButton');

            this.CharDimCompareButton=hgconvertunits(this.VisualSummaryFigure,this.CompareButton.Position,'normalized','char',this.VisualSummaryFigure);

            this.VisualSummaryButton=uicontrol('Parent',this.VisualSummaryFigure,...
            'Style','pushbutton',...
            'Callback',@(varargin)this.viewLabelSummary,...
            'Units','normalized',...
            'Position',[0.2,0.92,0.16,0.04],...
            'String',vision.getMessage('vision:labeler:ViewLabelSummary'),...
            'HorizontalAlignment','left',...
            'HandleVisibility','callback',...
            'Visible','off',...
            'Tooltip',vision.getMessage('vision:labeler:ViewLabelSummaryButtonTooltip'),...
            'Tag','VisualSummaryButton');
        end


        function signalInvaild(this)
            this.SignalInvaild=uipanel('Parent',this.VisualSummaryDockableFigure.Figure,...
            'BorderType','none',...
            'Title','',...
            'Units','Normalized',...
            'Position',[0.2,-0.02,0.7,0.9],...
            'Visible','on',...
            'Tag','SignalInvaild');

            this.SignalInvaildText=uicontrol('Parent',this.SignalInvaild,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.2,0,0.7,0.9],...
            'String',vision.getMessage('vision:labeler:SignalInvaild'),...
            'FontWeight','bold',...
            'FontSize',9,...
            'HorizontalAlignment','left',...
            'HandleVisibility','callback',...
            'Tag','SignalInvaildText');
        end


        function ROIinvaild(this)
            this.ROIInvaild=uipanel('Parent',this.VisualSummaryDockableFigure.Figure,...
            'BorderType','none',...
            'Title','',...
            'Units','Normalized',...
            'Position',[0.2,-0.02,0.7,0.9],...
            'Visible','on',...
            'Tag','ROIInvaild');

            this.ROIInvaildText=uicontrol('Parent',this.ROIInvaild,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.2,0,0.7,0.9],...
            'String',vision.getMessage('vision:labeler:ROIinvaild'),...
            'FontWeight','bold',...
            'FontSize',9,...
            'HorizontalAlignment','left',...
            'HandleVisibility','callback',...
            'Tag','ROIInvaild');
        end


        function vsDisplayItem(this)
            this.ROITitlePanel.Visible='off';
            this.SceneTitlePanel.Visible='off';
            this.CompareButton.Enable='off';
            this.VisualSummaryButton.Enable='off';
            this.VisualSummaryCheckBox.Enable='off';
            this.PrevUnlabeledButton.Enable='off';
            this.NextUnlabeledButton.Enable='off';
            this.UnlabeledBtnText.Enable='off';
            this.SignalNameText.Enable='on';
            this.SignalNamePU.Enable='on';
        end


        function positions=getPanelPositions(this)




            totalPixelsRequired=this.NumberOfROIItems*this.MinROIItemHeight+this.NumberOfSceneItems*this.MinSceneItemHeight;
            screenSize=get(0,'ScreenSize');
            screenHeight=screenSize(4);

            buttonPosition=this.CompareButton.Position;



            height=this.VisualSummaryFigure.Position(4)-(buttonPosition(4)*this.VisualSummaryFigure.Position(4));




            if totalPixelsRequired<(height*screenHeight)
                this.ROIItemHeight=min(max((height*screenHeight*this.MinROIItemHeight)/totalPixelsRequired,this.MinROIItemHeight),this.MaxROIItemHeight);
                this.SceneItemHeight=min(max((height*screenHeight*this.MinSceneItemHeight)/totalPixelsRequired,this.MinSceneItemHeight),this.MaxSceneItemHeight);
            end


            totalPixelsRequired=this.NumberOfROIItems*this.ROIItemHeight+this.NumberOfSceneItems*this.SceneItemHeight;

            roiTitlePanelHeight=0;
            sceneTitlePanelHeight=0;

            if this.NumberOfROIItems
                roiTitlePanelHeight=0.03;
            end

            if this.NumberOfSceneItems
                sceneTitlePanelHeight=0.025;
            end


            spaceToStartPanelsFrom=buttonPosition(2)-0;
            remainingSpace=(spaceToStartPanelsFrom-roiTitlePanelHeight-sceneTitlePanelHeight);

            roiPanelHeight=remainingSpace*(this.NumberOfROIItems*this.ROIItemHeight)/totalPixelsRequired;
            scenePanelHeight=remainingSpace*(this.NumberOfSceneItems*this.SceneItemHeight)/totalPixelsRequired;

            x=0.02;
            width=0.96;

            roiPanelY=spaceToStartPanelsFrom-roiTitlePanelHeight-roiPanelHeight;
            scenePanelY=spaceToStartPanelsFrom-roiTitlePanelHeight-roiPanelHeight-sceneTitlePanelHeight-scenePanelHeight;

            positions.ROIPanelPos=[x,roiPanelY,width,roiPanelHeight];
            positions.ScenePanelPos=[x,scenePanelY,width,scenePanelHeight];
            positions.ComparePanelPos=[x,roiPanelY,width,roiPanelHeight];

            positions.ROITitlePanelPos=[x,(spaceToStartPanelsFrom-roiTitlePanelHeight),width,roiTitlePanelHeight];
            positions.SceneTitlePanelPos=[x,(spaceToStartPanelsFrom-roiTitlePanelHeight-roiPanelHeight-sceneTitlePanelHeight),width,sceneTitlePanelHeight];
        end


        function createROISummaryPanel(this)
            positions=getPanelPositions(this);
            createROITitlePanel(this,positions);
            this.ROIVisualSummaryPanel=vision.internal.labeler.tool.VisualSummaryROIPanel(this.VisualSummaryFigure,positions.ROIPanelPos);
            this.ROIVisualSummaryPanel.setBorder();

            addKeyPressCallback(this);
        end


        function createROITitlePanel(this,positions)
            this.ROITitlePanel=uipanel('Parent',this.VisualSummaryDockableFigure.Figure,...
            'BorderType','none',...
            'Title','',...
            'Units','Normalized',...
            'Position',positions.ROITitlePanelPos,...
            'Visible','on',...
            'Tag','ROITitlePanel');

            this.ROITitle=uicontrol('Parent',this.ROITitlePanel,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.46,0,0.5,0.9],...
            'String',vision.getMessage('vision:labeler:ROILabels'),...
            'FontWeight','bold',...
            'HorizontalAlignment','left',...
            'HandleVisibility','callback',...
            'Tag','ROITitleText');
        end


        function createSceneSummaryPanel(this)

            positions=getPanelPositions(this);
            createSceneTitlePanel(this,positions);
            this.SceneVisualSummaryPanel=vision.internal.labeler.tool.VisualSummaryScenePanel(this.VisualSummaryFigure,positions.ScenePanelPos);
            this.SceneVisualSummaryPanel.setBorder();

            addKeyPressCallback(this);
        end


        function createSceneTitlePanel(this,positions)
            this.SceneTitlePanel=uipanel('Parent',this.VisualSummaryDockableFigure.Figure,...
            'BorderType','none',...
            'Title','',...
            'Units','Normalized',...
            'Position',positions.SceneTitlePanelPos,...
            'Visible','on',...
            'Tag','ROITitlePanel');

            this.SceneTitle=uicontrol('Parent',this.SceneTitlePanel,...
            'Style','text',...
            'Units','normalized',...
            'Position',[0.46,0,0.2,0.9],...
            'String',vision.getMessage('vision:labeler:SceneLabels'),...
            'FontWeight','bold',...
            'HorizontalAlignment','left',...
            'HandleVisibility','callback',...
            'Tag','SceneTitleText');
        end


        function addKeyPressCallback(this)
            if~isempty(this.KeyPressCallbackCache)&&isa(this.KeyPressCallbackCache,'function_handle')
                this.VisualSummaryFigure.WindowKeyPressFcn=this.KeyPressCallbackCache;
            end
        end


        function setScrollCallback(this)
            currentPoint=get(this.VisualSummaryFigure,'CurrentPoint');

            if this.IsCompareSummaryOpen


                this.ComparePanel.setScrollPanelCallback();
                return;
            end






            if this.NumberOfROIItems==0
                this.SceneVisualSummaryPanel.setScrollPanelCallback();
            elseif this.NumberOfSceneItems==0
                this.ROIVisualSummaryPanel.setScrollPanelCallback();
            else
                roiPanelPosition=this.ROIVisualSummaryPanel.Position;

                if currentPoint(2)>roiPanelPosition(2)
                    this.ROIVisualSummaryPanel.setScrollPanelCallback();
                else
                    this.SceneVisualSummaryPanel.setScrollPanelCallback();
                end
            end
        end


        function summaryButtonDownCallback(this,~,evnt)

            if evnt.Button~=1
                return;
            end

            newPoint=get(this.VisualSummaryFigure,'CurrentPoint');
            sliderNewXValue=getSliderPosition(this,newPoint(1));

            data=vision.internal.labeler.tool.SliderLineMovedEvent(sliderNewXValue,this.IsSliderButtonUp);
            notify(this,'SliderLineMoved',data);


            for idx=1:this.NumberOfROIItems
                this.ROIVisualSummaryPanel.Items{idx}.SliderLine.XData=[sliderNewXValue,sliderNewXValue];
            end

            for idx=1:this.NumberOfSceneItems
                this.SceneVisualSummaryPanel.Items{idx}.SliderLine.XData=[sliderNewXValue,sliderNewXValue];
            end

            if this.IsCompareSummaryOpen
                totalNumCompareItems=numel(this.ComparePanel.Items);
                for idx=1:totalNumCompareItems
                    this.ComparePanel.Items{idx}.SliderLine.XData=[sliderNewXValue,sliderNewXValue];
                end
            end

        end


        function sliderButtonDownCallback(this,~,~)

            if this.IsSliderButtonUp
                this.IsSliderButtonUp=false;
            else
                return;
            end


            this.WindowMotionFcnCallback=get(this.VisualSummaryFigure,'WindowButtonMotionFcn');
            set(this.VisualSummaryFigure,'WindowButtonMotionFcn',@this.sliderMotionCallback);


            if isempty(this.MouseReleaseListener)
                this.MouseReleaseListener=addlistener(this.VisualSummaryFigure,'WindowMouseRelease',@this.sliderButtonUpCallback);
            end
        end


        function sliderMotionCallback(this,activeFigure,~)

            set(activeFigure,'Pointer','right');
            newPoint=get(activeFigure,'CurrentPoint');
            sliderNewXValue=getSliderPosition(this,newPoint(1));

            this.IsSliderLineMoved=true;

            data=vision.internal.labeler.tool.SliderLineMovedEvent(sliderNewXValue,this.IsSliderButtonUp);
            notify(this,'SliderLineMoved',data);


            for idx=1:this.NumberOfROIItems
                this.ROIVisualSummaryPanel.Items{idx}.SliderLine.XData=[sliderNewXValue,sliderNewXValue];
            end

            for idx=1:this.NumberOfSceneItems
                this.SceneVisualSummaryPanel.Items{idx}.SliderLine.XData=[sliderNewXValue,sliderNewXValue];
            end

            if this.IsCompareSummaryOpen
                totalNumCompareItems=numel(this.ComparePanel.Items);
                for idx=1:totalNumCompareItems
                    this.ComparePanel.Items{idx}.SliderLine.XData=[sliderNewXValue,sliderNewXValue];
                end
            end

            if this.CaughtExceptionDuringPlay
                sliderButtonUpCallback(this,activeFigure);
            end
        end


        function sliderButtonUpCallback(this,activeFigure,~)

            this.IsSliderButtonUp=true;

            if~(this.CaughtExceptionDuringPlay)




                notify(this,'SliderLineRelease');
            else


                resetExceptionDuringPlay(this);
            end

            set(activeFigure,'Pointer','arrow');
            set(this.VisualSummaryFigure,'WindowButtonMotionFcn',this.WindowMotionFcnCallback);

            delete(this.MouseReleaseListener);
            this.MouseReleaseListener=[];

            this.IsSliderLineMoved=false;
        end


        function sliderNewXValue=getSliderPosition(this,currentXPoint)


            if isempty(this.ROIVisualSummaryPanel)||~isvalid(this.ROIVisualSummaryPanel)
                summaryPanel=this.SceneVisualSummaryPanel;
            else
                summaryPanel=this.ROIVisualSummaryPanel;
            end

            axesPosition=get(summaryPanel.Items{end}.AxisHandle,'Position');

            axesXLimits=get(summaryPanel.Items{end}.AxisHandle,'XLim');

            panelPosition=summaryPanel.Items{end}.Panel.Position;
            panelPosition=hgconvertunits(this.VisualSummaryFigure,panelPosition,'pixels','normalized',this.VisualSummaryFigure);

            sliderIncrement=((currentXPoint-(0.02+(axesPosition(1)*panelPosition(3))))*(axesXLimits(2)-axesXLimits(1)))/(axesPosition(3)*panelPosition(3));
            sliderNewXValue=axesXLimits(1)+sliderIncrement;



            sliderNewXValue=this.getSliderValueInLimits(sliderNewXValue);
        end


        function newValue=getSliderValueInLimits(this,oldValue,axesXLimits)


            if nargin<3
                if isempty(this.ROIVisualSummaryPanel)||~isvalid(this.ROIVisualSummaryPanel)
                    summaryPanel=this.SceneVisualSummaryPanel;
                else
                    summaryPanel=this.ROIVisualSummaryPanel;
                end
                axesXLimits=get(summaryPanel.Items{end}.AxisHandle,'XLim');
            end
            oldValue=max(oldValue,axesXLimits(1));
            newValue=min(oldValue,axesXLimits(2));
        end


        function plotROICheckedItems(this)

            if isempty(this.ROIItemsCheckedIndices)
                return;
            end

            numPlots=0;
            for idx=this.ROIItemsCheckedIndices
                data.Name=this.ROIVisualSummaryPanel.Items{idx}.LabelName;
                if this.ROIVisualSummaryPanel.Items{idx}.LabelType~=labelType.PixelLabel
                    numPlots=numPlots+1;
                    this.IsShapeLabelPlotPresent=true;
                end
            end

            plotHandles=gobjects(numPlots,1);
            plotHandleCntr=1;
            maxValue=0;
            minValue=0;
            seenFirstROIIndex=false;

            for idx=this.ROIItemsCheckedIndices
                data.Name=this.ROIVisualSummaryPanel.Items{idx}.LabelName;
                if this.ROIVisualSummaryPanel.Items{idx}.LabelType==labelType.PixelLabel

                    continue;
                end

                data.Color=this.ROIVisualSummaryPanel.Items{idx}.PlotHandle.Color;
                data.Type=this.ROIVisualSummaryPanel.Items{idx}.LabelType;
                data.Time=this.ROIVisualSummaryPanel.Items{idx}.PlotHandle.XData;
                data.Data=this.ROIVisualSummaryPanel.Items{idx}.PlotHandle.YData;
                data.SignalType=this.AnnotationSummaryManager.SignalType;
                if~seenFirstROIIndex
                    seenFirstROIIndex=true;

                    data.CurrTime=this.ROIVisualSummaryPanel.Items{idx}.SliderLine.XData(1);






                    pixelsRequiredForSceneItems=50*(numel(this.SceneItemsCheckedIndices)+3);
                    screenSize=get(0,'ScreenSize');
                    screenHeight=screenSize(4);
                    remainingSpace=(this.VisualSummaryButton.Position(2)-0.01);
                    figureHeight=this.VisualSummaryFigure.Position(4);
                    totalAvailablePixels=remainingSpace*figureHeight*screenHeight;

                    data.ItemHeight=min(max(totalAvailablePixels-pixelsRequiredForSceneItems,300),this.MaxCompareROIItemHeight);

                    data.ComparisonMode=1;
                    this.ComparePanel.appendItem(data);
                    this.ComparePanel.updateItem();
                    this.ComparePanel.Items{1}.SliderLine.ButtonDownFcn=@this.sliderButtonDownCallback;
                    addlistener(this.ComparePanel.Items{end},'ButtonPressed',@this.notifyButtonPressed);

                    this.ComparePanel.Items{1}.AxisHandle.ButtonDownFcn=@this.summaryButtonDownCallback;
                else


                    this.ComparePanel.modify(1,data);
                end

                plotHandles(plotHandleCntr)=this.ROIVisualSummaryPanel.Items{idx}.PlotHandle;
                maxValue=max(max(plotHandles(plotHandleCntr).YData(:)),maxValue);
                minValue=min(min(plotHandles(plotHandleCntr).YData(:)),minValue);
                plotHandleCntr=plotHandleCntr+1;
            end

            if plotHandleCntr>1

                this.ComparePanel.Items{1}.adjustYLimits(1,[minValue,maxValue]);


                legend(this.ComparePanel.Items{1}.AxisHandle,plotHandles,'Location','northeast');
            end
        end


        function plotPixelCheckedItems(this)

            if isempty(this.ROIItemsCheckedIndices)
                return;
            end

            numPlots=0;
            for idx=this.ROIItemsCheckedIndices
                data.Name=this.ROIVisualSummaryPanel.Items{idx}.LabelName;
                if this.ROIVisualSummaryPanel.Items{idx}.LabelType==labelType.PixelLabel
                    numPlots=numPlots+1;
                    this.IsPixelLabelPlotPresent=true;
                end
            end

            plotHandles=gobjects(numPlots,1);
            plotHandleCntr=1;

            seenFirstPixelIndex=false;
            lenCompareItems=length(this.ComparePanel.Items);
            plotNames=cell(numPlots,1);

            for idx=this.ROIItemsCheckedIndices
                thisLabelName=this.ROIVisualSummaryPanel.Items{idx}.LabelName;
                if this.ROIVisualSummaryPanel.Items{idx}.LabelType~=labelType.PixelLabel

                    continue;
                end

                data.Time=this.ROIVisualSummaryPanel.Items{idx}.PlotHandle.XData;
                data.Type=this.ROIVisualSummaryPanel.Items{idx}.LabelType;

                if~seenFirstPixelIndex
                    data.Name=thisLabelName;
                    seenFirstPixelIndex=true;
                    data.Color=this.ROIVisualSummaryPanel.Items{idx}.PlotHandle.FaceColor;
                    data.Data=this.ROIVisualSummaryPanel.Items{idx}.PlotHandle.YData;
                    data.CurrTime=this.ROIVisualSummaryPanel.Items{idx}.SliderLine.XData(1);






                    pixelsRequiredForSceneItems=50*(numel(this.SceneItemsCheckedIndices)+3);
                    screenSize=get(0,'ScreenSize');
                    screenHeight=screenSize(4);
                    remainingSpace=(this.VisualSummaryButton.Position(2)-0.01);
                    figureHeight=this.VisualSummaryFigure.Position(4);
                    totalAvailablePixels=remainingSpace*figureHeight*screenHeight;

                    data.ItemHeight=min(max(totalAvailablePixels-pixelsRequiredForSceneItems,300),this.MaxCompareROIItemHeight);
                    data.ComparisonMode=3;

                else


                    data.Data=[data.Data;this.ROIVisualSummaryPanel.Items{idx}.PlotHandle.YData];
                    data.Color=[data.Color;this.ROIVisualSummaryPanel.Items{idx}.PlotHandle.FaceColor];
                    data.Name=[data.Name,'_',this.ROIVisualSummaryPanel.Items{idx}.LabelName];
                end

                plotHandles(plotHandleCntr)=this.ROIVisualSummaryPanel.Items{idx}.PlotHandle;
                plotNames{plotHandleCntr}=['Plot_',thisLabelName];
                plotHandles(plotHandleCntr).DisplayName=this.ROIVisualSummaryPanel.Items{idx}.LabelName;
                plotHandleCntr=plotHandleCntr+1;
            end

            if plotHandleCntr>1

                if size(data.Data,1)>1
                    data.Data=data.Data';
                end
                this.ComparePanel.appendItem(data);
                this.ComparePanel.updateItem();
                this.ComparePanel.Items{lenCompareItems+1}.SliderLine.ButtonDownFcn=@this.sliderButtonDownCallback;
                addlistener(this.ComparePanel.Items{end},'ButtonPressed',@this.notifyButtonPressed);

                this.ComparePanel.Items{lenCompareItems+1}.AxisHandle.ButtonDownFcn=@this.summaryButtonDownCallback;


                for idx=1:numel(this.ComparePanel.Items{lenCompareItems+1}.PlotHandle)
                    this.ComparePanel.Items{lenCompareItems+1}.PlotHandle(idx).Tag=plotNames{idx};
                    this.ComparePanel.Items{lenCompareItems+1}.PlotHandle(idx).FaceColor=data.Color(idx,:);
                end

                if~isempty(plotHandles)
                    legend(this.ComparePanel.Items{lenCompareItems+1}.AxisHandle,plotHandles,'Location','northeast');
                end
            end
        end


        function plotSceneCheckedItems(this)

            if isempty(this.SceneItemsCheckedIndices)
                return;
            end

            for idx=this.SceneItemsCheckedIndices
                data.Name=this.SceneVisualSummaryPanel.Items{idx}.CheckBox.String;
                data.Color=this.SceneVisualSummaryPanel.Items{idx}.PlotHandle.Color;
                data.Time=this.SceneVisualSummaryPanel.Items{idx}.PlotHandle.XData;
                data.Data=this.SceneVisualSummaryPanel.Items{idx}.PlotHandle.YData;
                data.Type=this.SceneVisualSummaryPanel.Items{idx}.LabelType;
                data.CurrTime=this.SceneVisualSummaryPanel.Items{idx}.SliderLine.XData(1);
                data.ItemHeight=70;
                data.ComparisonMode=2;



                data.LastSceneItem=false;
                if idx==this.SceneItemsCheckedIndices(end)
                    data.LastSceneItem=true;
                end
                this.ComparePanel.appendItem(data);
                this.ComparePanel.updateItem();
                this.ComparePanel.Items{end}.SliderLine.ButtonDownFcn=@this.sliderButtonDownCallback;
                addlistener(this.ComparePanel.Items{end},'ButtonPressed',@this.notifyButtonPressed);

                this.ComparePanel.Items{end}.AxisHandle.ButtonDownFcn=@this.summaryButtonDownCallback;
            end
        end


        function updateSelectAllCheckBox(this)
            numROIItemsChkd=numel(this.ROIItemsCheckedIndices);
            numSceneItemsChkd=numel(this.SceneItemsCheckedIndices);
            totalCheckedItems=(numROIItemsChkd+numSceneItemsChkd);

            totalItems=this.NumberOfROIItems+this.NumberOfSceneItems;

            this.VisualSummaryCheckBox.Value=(totalItems==totalCheckedItems);



            if totalCheckedItems>=2
                this.CompareButton.Enable='on';
            else
                this.CompareButton.Enable='off';
            end
        end


        function selectAllCheckBoxes(this)
            this.ROIItemsCheckedIndices=[];
            this.SceneItemsCheckedIndices=[];
            for idx=1:this.NumberOfROIItems
                this.ROIVisualSummaryPanel.Items{idx}.CheckBox.Value=this.VisualSummaryCheckBox.Value;
            end

            for idx=1:this.NumberOfSceneItems
                this.SceneVisualSummaryPanel.Items{idx}.CheckBox.Value=this.VisualSummaryCheckBox.Value;
            end

            if this.VisualSummaryCheckBox.Value
                this.ROIItemsCheckedIndices=1:this.NumberOfROIItems;
                this.SceneItemsCheckedIndices=1:this.NumberOfSceneItems;
            end

            numROIItemsChkd=numel(this.ROIItemsCheckedIndices);
            numSceneItemsChkd=numel(this.SceneItemsCheckedIndices);

            if(numROIItemsChkd+numSceneItemsChkd)>=2
                this.CompareButton.Enable='on';
            else
                this.CompareButton.Enable='off';
            end
        end


        function unlabeledBtnPressCallback(this,isLeftBtnPressed)
            SignalName=string(getSelectedSignalName(this));
            data=vision.internal.labeler.tool.VisualSummaryButtonPressEvent(isLeftBtnPressed,false,true,'','',SignalName);
            notify(this,'ButtonPressed',data);
        end


        function notifyButtonPressed(this,~,data)

            if data.IsCompareButton
                if(data.LabelType==labelType.Scene)
                    data.LabelName=this.SceneItemsCheckedIndices;
                else
                    data.LabelName=this.ROIItemsCheckedIndices;
                end
            end
            data.SignalName=getSelectedSignalName(this);
            notify(this,'ButtonPressed',data);
        end


        function removeROISummaryPanel(this)
            if this.NumberOfROIItems
                for idx=length(this.ROIVisualSummaryPanel.Items):-1:1
                    this.ROIVisualSummaryPanel.Items{idx}.Panel.Visible='off';
                    delete(this.ROIVisualSummaryPanel.Items{idx});
                    this.ROIVisualSummaryPanel.Items(idx)=[];
                end
                this.ROILabelNames={};
            end

            if this.NumberOfSceneItems
                for idx=length(this.SceneVisualSummaryPanel.Items):-1:1
                    this.SceneVisualSummaryPanel.Items{idx}.Panel.Visible='off';
                    delete(this.SceneVisualSummaryPanel.Items{idx});
                    this.SceneVisualSummaryPanel.Items(idx)=[];
                end
                this.SceneLabelNames={};
            end
        end


        function plot=findPlotHandle(this,name)


            plotTag=strcat('Plot_',name);
            for i=1:numel(this.ComparePanel.Items)
                plot=findall(this.ComparePanel.Items{i}.PlotHandle,'Tag',plotTag);
                if~isempty(plot)
                    break;
                end
            end
        end

    end

    methods(Static)

        function[figurePos]=calculateFigurePosition()
            height=0.6;
            width=0.6;
            x=(1-width)/2;
            y=(1-height)/2;
            figurePos=[x,y,width,height];
        end
    end
end
