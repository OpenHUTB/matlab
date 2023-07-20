
classdef LabelSetDisplay<vision.internal.uitools.AppFig


    properties(Constant)
        AddButtonTextColor=repelem(160/255,1,3);

        DragItemThreshold=10
    end

    properties(Dependent)

CurrentSelection


NumItems



StopItemDragExec
    end

    properties(Access=protected)

ToolName


AddLabelPanel
LabelSetPanel


AddLabelButton
AddLabelText
HelperText



AddLabelButtonWidth
AddLabelButtonSizeInPixels



        ItemType=[];



        ItemVisibility=logical([]);



        BinEdges=[];
        CollapsedBinEdges=[];


DropLine


        DropIdx=[]


FirstClickPos


        DragSetupDone=false;


ItemHeight


DiffValue



        ButtonUpBeforeBtnDown=false;
    end

    events

PanelItemMoved
    end




    methods(Access=public)

        function this=LabelSetDisplay(hFig,toolName,nameDisplayedInTab)
            this=this@vision.internal.uitools.AppFig(hFig,nameDisplayedInTab,true);


            this.Fig.Resize='on';

            this.ToolName=toolName;

            initializeButtonWidth(this);

            this.Fig.WindowButtonUpFcn=@this.stopItemDrag;
        end
    end




    methods(Access=public)


        function flag=isPanelVisible(this)
            flag=strcmpi(this.Fig.Visible,'on');
        end




        function insertItem(this,data,idxInsertAfter)
            if nargin<3
                idxInsertAfter=this.NumItems;
            end
            this.LabelSetPanel.insertItem(data,idxInsertAfter);
            itemIdx=idxInsertAfter+1;
            itemType=findItemType(this,itemIdx);
            itemVisibility=true;

            if(itemType==vision.internal.labeler.tool.ItemType.Label||...
                itemType==vision.internal.labeler.tool.ItemType.Sublabel)

                groupItemsLogical=getGroupItemIndices(this);

                if any(groupItemsLogical)
                    if~this.ItemVisibility(idxInsertAfter)
                        makeItemInVisible(this,itemIdx);
                        itemVisibility=false;
                    end
                end
            end
            this.ItemType=[this.ItemType(1:idxInsertAfter),itemType,this.ItemType(itemIdx:end)];
            this.ItemVisibility=[this.ItemVisibility(1:idxInsertAfter),itemVisibility,this.ItemVisibility(itemIdx:end)];
        end


        function moveItem(this,currentIdx,destinationIdx)
            itemType=this.ItemType(currentIdx);
            itemVis=this.ItemVisibility(currentIdx);
            this.LabelSetPanel.moveItem(currentIdx,destinationIdx);


            if currentIdx<destinationIdx
                this.ItemType(currentIdx:destinationIdx)=[this.ItemType(currentIdx+1:destinationIdx),itemType];
                this.ItemVisibility(currentIdx:destinationIdx)=[this.ItemVisibility(currentIdx+1:destinationIdx),itemVis];
            else
                this.ItemType(destinationIdx:currentIdx)=[itemType,this.ItemType(destinationIdx:currentIdx-1)];
                this.ItemVisibility(destinationIdx:currentIdx)=[itemVis,this.ItemVisibility(destinationIdx:currentIdx-1)];
            end
        end


        function updateItem(this)
            this.LabelSetPanel.updateItem();
        end


        function appendItem(this,data)
            insertItem(this,data);
        end




        function selectItem(this,idx)
            this.LabelSetPanel.selectItem(idx);
        end


        function selectLastItem(this)
            this.LabelSetPanel.selectItem(this.NumItems);
        end


        function selectNextItem(this)
            this.LabelSetPanel.selectNextItem();
        end


        function selectPrevItem(this)
            this.LabelSetPanel.selectPrevItem();
        end


        function unselectToBeDisabledItems(this,idx)
            this.LabelSetPanel.unselectToBeDisabledItems(idx);
        end




        function unSelectItem(this,idx)
            this.LabelSetPanel.unSelectItem(idx);
        end




        function deleteItem(this,data)
            this.LabelSetPanel.deleteItem(data);
        end


        function deleteAllItems(this)
            this.LabelSetPanel.deleteAllItems();
            this.ItemType=[];
            this.ItemVisibility=[];
        end


        function deleteItemWithID(this,idx)
            this.LabelSetPanel.deleteItemWithID(idx);
            this.ItemType(idx)=[];
            this.ItemVisibility(idx)=[];
        end




        function modify(this,idx,data)
            this.LabelSetPanel.modify(idx,data);
        end


        function modifyItemDescription(this,idx,data)
            this.LabelSetPanel.modifyItemDescription(idx,data);
        end


        function modifyFrameItemColor(this,idx,data)
            this.LabelSetPanel.modifyItemColor(idx,data);
        end



        function modifyItemData(this,idx,data)
            this.LabelSetPanel.modifyItemData(idx,data);
        end




        function disableItem(this,idx)
            this.LabelSetPanel.disableItem(idx);
        end


        function disableAllItems(this)
            this.LabelSetPanel.disableAllItems();
        end


        function enableItem(this,idx)
            this.LabelSetPanel.enableItem(idx);
        end


        function enableAllItems(this)
            this.LabelSetPanel.enableAllItems();
        end




        function makeItemVisible(this,idx)
            makeItemVisible(this.LabelSetPanel,idx);
        end


        function makeItemInVisible(this,idx)
            makeItemInVisible(this.LabelSetPanel,idx);
        end
    end




    methods

        function value=get.CurrentSelection(this)
            value=this.LabelSetPanel.CurrentSelection;
        end


        function value=get.NumItems(this)
            value=this.LabelSetPanel.NumItems;
        end


        function panel=getLabelSetPanel(this)
            panel=this.LabelSetPanel;
        end


        function[labelNames,labelIndices]=getLabelNames(this)

            labelItems=this.LabelSetPanel.Items(this.ItemType==vision.internal.labeler.tool.ItemType.Label);

            labelNames=cell(1,numel(labelItems));
            labelIndices=zeros(1,numel(labelItems));

            for i=1:numel(labelItems)
                labelNames{i}=labelItems{i}.Data.Label;
                labelIndices(i)=labelItems{i}.Index;
            end
        end


        function TF=get.StopItemDragExec(this)
            TF=isempty(this.DropLine);
        end


        function button=getAddLabelButton(this)
            button=this.AddLabelButton;
        end


        function itemData=getSelectedItemData(this)
            idx=this.CurrentSelection;
            if isempty(idx)||(idx==0)
                itemData=[];
            else
                item=this.LabelSetPanel.getItem(idx);
                itemData=item.Data;
            end
        end


        function itemData=getItemData(this,idx)
            item=this.LabelSetPanel.getItem(idx);
            itemData=item.Data;
        end


        function indices=getLabelIDsByLabelType(this,labeltype)
            indices=[];
            for idx=1:this.NumItems
                if(this.ItemType(idx)==vision.internal.labeler.tool.ItemType.Label)
                    itemData=this.getItemData(idx);
                    if itemData.ROI==labeltype
                        indices=[indices,idx];%#ok<AGROW>
                    end
                end
            end
        end
    end




    methods

        function updateOnLabelAddition(this,data,labelSet)

            labelItemIdx=addLabelAndGroupItems(this,data,labelSet);

            updateItem(this);

            selectItem(this,labelItemIdx);

            remainingUIUpdates(this);


            updateDataOnItemMove(this);
        end

        function updateGroupOnLabelEdit(this,data,labelSet)


            labelInfo=data.Label;


            groupItemIdx=performGrouping(this,data,labelSet);


            items=this.LabelSetPanel.Items;

            currentItemIdx=find(cellfun(@(x)isaLabelItem(this,x.Index)...
            &&strcmp(x.Data.Label,labelInfo.Label),items),1);
            currentItem=items{currentItemIdx};


            if data.IsNewGroup
                moveIdx=groupItemIdx+double(groupItemIdx<currentItem.Index);
            else
                groupChanged=~strcmp(currentItem.Data.Group,labelInfo.Group);

                if groupChanged

                    groupItemIndices=getGroupItemIndices(this);
                    groupItems=items(groupItemIndices);
                    idxInGroupItems=find(cellfun(@(x)strcmp(x.Name,data.Label.Group),...
                    groupItems),1);

                    if idxInGroupItems~=numel(groupItems)
                        nextGroupItemIdx=groupItems{idxInGroupItems+1}.Index;
                        moveIdx=nextGroupItemIdx-double(nextGroupItemIdx>currentItem.Index);
                    else
                        moveIdx=this.NumItems;
                    end
                else
                    moveIdx=currentItem.Index;
                end
            end







            if currentItem.Index~=1&&isaGroupItem(this,currentItem.Index-1)
                prevItem=items{currentItem.Index-1};
            else
                prevItem=[];
            end


            moveItem(this,currentItem.Index,moveIdx);
            modifyItemData(this,currentItem.Index,data.Label);


            sublabelItemIndices=cellfun(@(x)isaSubLabelItem(this,x.Index)...
            &&strcmp(x.Data.LabelName,labelInfo.Label),this.LabelSetPanel.Items);

            if any(sublabelItemIndices)
                sublabelItems=this.LabelSetPanel.Items(sublabelItemIndices);
                for i=1:numel(sublabelItems)
                    moveItem(this,sublabelItems{i}.Index,moveIdx+double(sublabelItems{i}.Index>moveIdx)*i);
                end

            end


            groupItemNeedsRemoval=~isempty(prevItem)&&...
            ((prevItem.Index==this.NumItems)||...
            isaGroupItem(this,prevItem.Index+1));

            if groupItemNeedsRemoval
                deleteItemWithID(this,prevItem.Index);
            end


            deleteLastNoneGroupItem(this,labelSet);

            selectItem(this,currentItem.Index);

            updateDataOnItemMove(this);
        end

        function updateOnGroupDelete(this,data,labelSet)



            deleteFrom=data.Index;

            itemIndices=getGroupItemIndices(this);
            deleteUpto=findUptoIndex(this,itemIndices,data.Index);


            deleteItemWithID(this,deleteFrom);


            for itemIdx=deleteFrom+1:deleteUpto
                currentItemData=this.LabelSetPanel.Items{deleteFrom}.Data;
                itemData=vision.internal.labeler.tool.ItemSelectedEvent(deleteFrom,currentItemData);
                doPanelItemDeleted(this,[],itemData);
            end


            deleteLastNoneGroupItem(this,labelSet);

            remainingUIUpdates(this);

        end

        function updateOnGroupNameChange(this,id,groupName)



            modifyItemData(this,id,groupName);

            itemIndices=(this.ItemType==vision.internal.labeler.tool.ItemType.Group);


            currentIdx=this.CurrentSelection;
            uptoIdx=findUptoIndex(this,itemIndices,currentIdx);
            data.Group=groupName;
            for id=currentIdx+1:uptoIdx
                if this.ItemType(id)==vision.internal.labeler.tool.ItemType.Label
                    modifyItemData(this,id,data);
                end
            end
        end

        function updateOnLabelDelete(this,data,labelSet)


            if isaLabelItem(this,data.Index)


                deleteFrom=data.Index;

                itemIndices=cellfun(@(x)(isaGroupItem(this,x.Index)||isaLabelItem(this,x.Index)),...
                this.LabelSetPanel.Items);
                deleteUpto=findUptoIndex(this,itemIndices,data.Index);


                for itemIdx=deleteUpto:-1:deleteFrom
                    deleteItemWithID(this,itemIdx);
                end


                groupRemoveCond=(data.Index~=1&&isaGroupItem(this,data.Index-1))...
                &&(data.Index-1==this.NumItems||isaGroupItem(this,data.Index));
                if groupRemoveCond
                    deleteItemWithID(this,data.Index-1);
                end


                deleteLastNoneGroupItem(this,labelSet);

            elseif isaSubLabelItem(this,data.Index)

                deleteItemWithID(this,data.Index);

            else

            end

            remainingUIUpdates(this);

        end

        function updateDataOnItemMove(this,data)



            if nargin<2
                data.GroupChanged=false;
                data.Group='';
                data.Label='';
                data.LabelNames={};
            end

            labelItems=this.LabelSetPanel.Items(this.ItemType==vision.internal.labeler.tool.ItemType.Label);
            for i=1:numel(labelItems)
                data.LabelNames(end+1)={labelItems{i}.Data.Label};
            end
            data=vision.internal.labeler.tool.ItemMovedEvent(this.CurrentSelection,data);
            notify(this,'PanelItemMoved',data);
        end

        function itemIdx=addLabelAndGroupItems(this,data,labelSet)

            if this.NumItems==0
                hideHelperText(this);
            end

            addLabelItemAfterIdx=performGrouping(this,data,labelSet);

            itemIdx=addLabelItem(this,data,addLabelItemAfterIdx);
        end

    end

    methods(Abstract)
        remainingUIUpdates(this)
    end




    methods(Access=private)

        function groupAddedIdx=performGrouping(this,data,labelSet)




            [noGrouping,anyNoneGroupInLabelSet]=isAllGroupsNone(this,labelSet);

            if noGrouping

                groupAddedIdx=this.NumItems;
            else
                noGroupItems=~any(this.ItemType==vision.internal.labeler.tool.ItemType.Group);





                if anyNoneGroupInLabelSet&&noGroupItems&&this.NumItems>0
                    addNoneItemAtTop(this);
                end

                groupAddedIdx=addGroupItem(this,data);
            end

        end

        function[allNoneGroups,anyNoneGroup]=isAllGroupsNone(~,labelset)


            definitionStruct=labelset.DefinitionStruct;
            currentGroups={definitionStruct.Group};
            uniqueGroups=unique(currentGroups,'stable');


            allNoneGroups=(numel(uniqueGroups)==1)&&...
            strcmp(uniqueGroups{1},'None');

            anyNoneGroup=~allNoneGroups&&(any(find(cellfun(@(x)strcmp(x,'None'),...
            uniqueGroups))));
        end

        function noneItemIdx=addNoneItemAtTop(this)




            [noneItemExists,noneItemIdx]=doesNoneItemExist(this);


            if~noneItemExists
                noneItemData.Group='None';

                insertItem(this,noneItemData,0);
                updateItem(this);
                noneItemIdx=1;
            end
        end

        function[TF,index]=doesNoneItemExist(this)
            index=[];
            items=this.LabelSetPanel.Items;
            if~isempty(items)
                groupItemsWithNone=cellfun(@(x)isaGroupItem(this,x.Index)...
                &&strcmp(x.Name,'None'),items);
                TF=any(groupItemsWithNone);
                if TF
                    index=items{find(groupItemsWithNone,1)}.Index;
                end
            else
                TF=false;
            end
        end

        function groupItemIdx=addGroupItem(this,data)
            if data.IsNewGroup
                groupItemInsertAfter=this.NumItems;
                groupItemData.Group=data.Label.Group;
                insertItem(this,groupItemData,groupItemInsertAfter);
                updateItem(this);
                groupItemIdx=groupItemInsertAfter+1;
            else
                groupItemIdx=[];
            end
        end

        function itemIdx=addLabelItem(this,data,insertAfterIdx)
            if nargin<3
                insertAfterIdx=0;
            end

            roiLabel=data.Label;

            if isempty(insertAfterIdx)
                items=this.LabelSetPanel.Items;
                groupItemIndices=getGroupItemIndices(this);
                groupItems=items(groupItemIndices);
                idxInGroupItems=find(cellfun(@(x)strcmp(x.Name,roiLabel.Group),...
                groupItems),1);

                if idxInGroupItems~=numel(groupItems)
                    nextGroupItemIdx=groupItems{idxInGroupItems+1}.Index;
                    insertAfterIdx=nextGroupItemIdx-1;
                else
                    insertAfterIdx=this.NumItems;
                end
            end

            insertItem(this,roiLabel,insertAfterIdx);
            itemIdx=insertAfterIdx+1;
        end

        function uptoIdx=findUptoIndex(this,itemIndices,index)



            itemIndices=find(itemIndices(index:end))+(index-1);
            if isscalar(itemIndices)
                uptoIdx=this.NumItems;
            else
                uptoIdx=itemIndices(2)-1;
            end
        end

        function deleteLastNoneGroupItem(this,labelSet)
            if isAllGroupsNone(this,labelSet)
                [noneItemExists,noneItemIdx]=doesNoneItemExist(this);
                if noneItemExists
                    unSelectItem(this,this.CurrentSelection);
                    deleteItemWithID(this,noneItemIdx);
                    for idx=1:this.NumItems
                        if~this.ItemVisibility(idx)
                            makeItemVisible(this,idx);
                            this.ItemVisibility(idx)=true;
                            selectItem(this,idx);
                        end
                    end

                    updateItem(this);
                else
                    groupIdx=find(this.ItemType==vision.internal.labeler.tool.ItemType.Group);
                    if~isempty(groupIdx)
                        deleteItemWithID(this,groupIdx);
                    end
                end
            end
        end

    end




    methods(Access=protected)
        function itemType=findItemType(this,index)
            if isa(this.LabelSetPanel.Items{index},'vision.internal.labeler.tool.GroupItem')
                itemType=vision.internal.labeler.tool.ItemType.Group;
            elseif(isa(this.LabelSetPanel.Items{index}.Data,'vision.internal.labeler.ROILabel')||...
                isa(this.LabelSetPanel.Items{index}.Data,'vision.internal.labeler.FrameLabel'))
                itemType=vision.internal.labeler.tool.ItemType.Label;
            elseif isa(this.LabelSetPanel.Items{index}.Data,'vision.internal.labeler.ROISublabel')
                itemType=vision.internal.labeler.tool.ItemType.Sublabel;
            else
                itemType=vision.internal.labeler.tool.ItemType.Label;
            end
        end

        function TF=isaGroupItem(this,index)
            if index<=numel(this.ItemType)
                TF=(this.ItemType(index)==vision.internal.labeler.tool.ItemType.Group);
            else
                TF=false;
            end
        end

        function TF=isaLabelItem(this,index)
            if index<=numel(this.ItemType)
                TF=(this.ItemType(index)==vision.internal.labeler.tool.ItemType.Label);
            else
                TF=false;
            end
        end

        function TF=isaSubLabelItem(this,index)
            if index<=numel(this.ItemType)
                TF=(this.ItemType(index)==vision.internal.labeler.tool.ItemType.Sublabel);
            else
                TF=false;
            end
        end

        function binEdges=findBinEdges(this,itemType)




            if itemType==vision.internal.labeler.tool.ItemType.Group

                binEdges=find((fliplr(this.ItemType)==itemType))*this.ItemHeight;
                binEdges(end+1)=binEdges(end)+this.ItemHeight;


                itemTypes=this.ItemType(this.ItemVisibility==true);
                collapsedBinEdges=find((fliplr(itemTypes)==itemType))*this.ItemHeight;
                collapsedBinEdges(end+1)=collapsedBinEdges(end)+this.ItemHeight;

                if~isequal(binEdges,collapsedBinEdges)
                    this.CollapsedBinEdges=collapsedBinEdges;
                end

            elseif itemType==vision.internal.labeler.tool.ItemType.Label
                isLabel=this.ItemType==itemType;
                isGroup=this.ItemType==vision.internal.labeler.tool.ItemType.Group;
                isLabelOrGroup=isLabel|isGroup;
                isSubLabel=this.ItemType==vision.internal.labeler.tool.ItemType.Sublabel;
                nextElementFlag=circshift(isLabelOrGroup,-1);
                nextElementFlag(end)=true;
                isSubBeforeLabelOrGroup=isSubLabel&nextElementFlag;

                binEdges=find(((fliplr(this.ItemType)==itemType)|...
                (fliplr(this.ItemType)==vision.internal.labeler.tool.ItemType.Group)|...
                fliplr(isSubBeforeLabelOrGroup))...
                &this.ItemVisibility)*this.ItemHeight;
                if isaLabelItem(this,1)
                    binEdges(end+1)=binEdges(end)+this.ItemHeight;
                end

            else
                binEdges=[];
            end
        end

        function indices=getGroupItemIndices(this)
            indices=(this.ItemType==vision.internal.labeler.tool.ItemType.Group);
        end
    end




    methods


        function doPanelItemSelected(this,data)

            if strcmpi(this.Fig.SelectionType,'normal')&&~isaSubLabelItem(this,data.Index)
                isMouseClick=this.LabelSetPanel.Items{this.CurrentSelection}.IsClicked;
                if isMouseClick&&isempty(this.Fig.WindowButtonMotionFcn)&&...
                    ~this.ButtonUpBeforeBtnDown

                    this.FirstClickPos=this.Fig.CurrentPoint;

                    this.Fig.WindowButtonMotionFcn=@this.doItemDrag;
                end
            end
        end


        function doItemDrag(this,src,~)


            currentPoint=src.CurrentPoint;



            if~isempty(this.FirstClickPos)&&(abs(currentPoint(2)-this.FirstClickPos(2))<this.DragItemThreshold)
                return;
            else
                this.FirstClickPos=[];
            end


            if~this.DragSetupDone


                for i=1:this.NumItems
                    if isaLabelItem(this,i)||isaSubLabelItem(this,i)
                        shrink(this.LabelSetPanel.Items{i});
                    end
                end


                item=this.LabelSetPanel.Items{this.CurrentSelection};
                itemType=this.ItemType(this.CurrentSelection);
                this.ItemHeight=item.Panel.Position(4);



                this.BinEdges=findBinEdges(this,itemType);



                this.LabelSetPanel.insertItem(item.Data,this.NumItems);
                updateItem(this);
                makeInvisible(this.LabelSetPanel.Items{this.NumItems});
                newItem=this.LabelSetPanel.Items{this.NumItems};
                newItem.Position=item.Position;


                dropLinePos=[newItem.Position(1),newItem.Position(2),newItem.Position(3),0.1*newItem.Position(4)];
                this.DropLine=uipanel('Parent',item.Panel.Parent,...
                'Units','pixels','Position',dropLinePos,...
                'BackgroundColor',[0,0,0],...
                'BorderType','line',...
                'Visible','off');
                if~useAppContainer
                    this.DropLine.ForegroundColor=[0,0,0];
                    this.DropLine.HighlightColor=[0,0,0];
                end
                this.DragSetupDone=true;
            end


            item=this.LabelSetPanel.Items{this.NumItems};
            makeVisible(this.LabelSetPanel.Items{this.NumItems});
            fixedPanelPos=hgconvertunits(this.Fig,item.Panel.Parent.Parent.Position,...
            item.Panel.Parent.Parent.Units,item.Panel.Parent.Units,this.Fig);
            movingPanelPos=item.Panel.Parent.Position;


            if movingPanelPos(4)<fixedPanelPos(4)
                diff=fixedPanelPos(4)-movingPanelPos(4);
                diff=hgconvertunits(this.Fig,[0,diff,0,0],item.Panel.Parent.Units,...
                item.Panel.Units,this.Fig);

                for idx=1:this.NumItems-1
                    this.LabelSetPanel.Items{idx}.Position(2)=this.LabelSetPanel.Items{idx}.Position(2)+diff(2);
                end

                this.DiffValue=diff(2);
                item.Panel.Parent.Position=fixedPanelPos;
            elseif movingPanelPos(4)>fixedPanelPos(4)
                this.DiffValue=0;
            else

            end


            if useAppContainer
                this.DiffValue=0;
            end


            [currentPointY,limitsFP]=getCurrentPtInMovingPanel(this.LabelSetPanel,currentPoint);
            yPtForItem=currentPointY;
            item.Position(2)=yPtForItem;



            if~isempty(this.CollapsedBinEdges)
                binEdges=this.CollapsedBinEdges;
            else
                binEdges=this.BinEdges;
            end
            [~,i]=min(abs(currentPointY-(binEdges+this.DiffValue)));
            itemIdx=round(this.BinEdges(i)/this.ItemHeight);
            this.DropIdx=this.NumItems-itemIdx;

            if isaGroupItem(this,this.CurrentSelection)

                if currentPointY>=this.LabelSetPanel.Items{this.NumItems-1}.Position(2)
                    this.DropIdx=this.DropIdx-1;
                else
                    this.DropIdx=this.NumItems-1;
                end
            else

                if(this.DropIdx+1<this.NumItems)&&...
                    this.ItemType(this.DropIdx+1)==vision.internal.labeler.tool.ItemType.Sublabel
                    if currentPointY>=this.LabelSetPanel.Items{this.NumItems-1}.Position(2)
                        this.DropIdx=this.DropIdx-1;
                    else
                        this.DropIdx=this.NumItems-1;
                    end
                end
            end


            if this.DropIdx>0
                dropLinePos=this.LabelSetPanel.Items{this.DropIdx}.Position(2);
            else
                dropLinePos=this.LabelSetPanel.Items{1}.Position(2)+this.ItemHeight-3;
            end
            this.DropLine.Position(2)=dropLinePos;
            this.DropLine.Visible='on';


            if(currentPoint(2)<limitsFP(1))
                if~isItemVisible(this.LabelSetPanel,this.NumItems-1)
                    scrollTo(this.LabelSetPanel,this.DropIdx+1);
                    verticalScroll(this.LabelSetPanel);
                end
            else
                if(currentPoint(2)>limitsFP(2)+10)
                    if~isItemVisible(this.LabelSetPanel,1)
                        scrollTo(this.LabelSetPanel,this.DropIdx-1);
                        verticalScroll(this.LabelSetPanel);
                    end
                end
            end
        end


        function stopItemDrag(this,~,~)


            if~isempty(this.Fig.WindowButtonMotionFcn)


                if this.DragSetupDone
                    delete(this.DropLine);
                    this.DropLine=[];



                    this.LabelSetPanel.deleteItemWithID(this.NumItems);
                end

                this.Fig.WindowButtonMotionFcn=[];
                this.DragSetupDone=false;

                if isempty(this.FirstClickPos)
                    dropItem(this);
                end
                this.ButtonUpBeforeBtnDown=false;
            else


                isClicked=false;
                for idx=1:this.NumItems
                    if this.LabelSetPanel.Items{idx}.IsClicked
                        isClicked=true;
                        break;
                    end
                end
                this.ButtonUpBeforeBtnDown=isClicked;
            end
        end


        function dropItem(this)




            if this.CurrentSelection>this.DropIdx
                if this.DropIdx>0
                    this.DropIdx=min(this.DropIdx+1,this.NumItems);
                else
                    this.DropIdx=1;
                end
            end

            if~isempty(this.DropIdx)&&this.CurrentSelection~=this.DropIdx


                itemType=this.ItemType(this.CurrentSelection);
                if itemType==vision.internal.labeler.tool.ItemType.Group
                    itemIndices=getGroupItemIndices(this);

                    moveFrom=this.CurrentSelection;
                    moveUpto=findUptoIndex(this,itemIndices,moveFrom);
                elseif itemType==vision.internal.labeler.tool.ItemType.Label
                    itemIndices=cellfun(@(x)isaGroupItem(this,x.Index)||...
                    isaLabelItem(this,x.Index),...
                    this.LabelSetPanel.Items);
                    moveFrom=this.CurrentSelection;
                    moveUpto=findUptoIndex(this,itemIndices,moveFrom);
                else
                    moveFrom=this.CurrentSelection;
                    moveUpto=this.CurrentSelection;
                end


                for idx=moveFrom:moveUpto
                    if this.DropIdx>moveFrom

                        srcIdx=moveFrom;
                        dropIdx=this.DropIdx;
                    else

                        srcIdx=idx;
                        dropIdx=this.DropIdx+(srcIdx-moveFrom);
                    end
                    moveItem(this,srcIdx,dropIdx);
                end

                if(itemType==vision.internal.labeler.tool.ItemType.Label)&&...
                    (any(this.ItemType==vision.internal.labeler.tool.ItemType.Group))


                    if this.DropIdx>moveFrom
                        chkItemIdx=moveFrom-1;
                    else
                        chkItemIdx=moveUpto;
                    end

                    hangingGrp=(chkItemIdx~=0)&&isaGroupItem(this,chkItemIdx)...
                    &&((chkItemIdx==(this.NumItems))||...
                    ((chkItemIdx~=(this.NumItems))&&...
                    isaGroupItem(this,chkItemIdx+1)));
                    if hangingGrp
                        deleteItemWithID(this,chkItemIdx);
                        if this.DropIdx>moveFrom
                            this.DropIdx=this.DropIdx-1;
                        end
                    end



                    groupIndices=find(this.ItemType==vision.internal.labeler.tool.ItemType.Group);
                    if~isempty(groupIndices)&&isscalar(groupIndices)&&...
                        strcmp(this.LabelSetPanel.Items{groupIndices}.Name,'None')
                        deleteItemWithID(this,groupIndices);
                        this.DropIdx=this.DropIdx-1;
                    end
                end




                if this.DropIdx>moveFrom
                    selectItemIdx=this.DropIdx-(numel(moveFrom:moveUpto)-1);
                else
                    selectItemIdx=this.DropIdx;
                end
                selectItem(this,selectItemIdx);
                updateItem(this);

                data.GroupChanged=false;
                data.Group='';
                data.Label='';
                data.LabelNames={};



                if(itemType==vision.internal.labeler.tool.ItemType.Label)

                    if(any(this.ItemType==vision.internal.labeler.tool.ItemType.Group))


                        groupIndices=(this.ItemType(1:this.CurrentSelection-1)...
                        ==vision.internal.labeler.tool.ItemType.Group);
                        currentGroupIdx=find(groupIndices,1,'last');

                        groupName=this.LabelSetPanel.Items{currentGroupIdx}.Name;
                    else
                        groupName='None';
                    end

                    labelGroupName=this.LabelSetPanel.Items{this.CurrentSelection}.Data.Group;


                    data.GroupChanged=~strcmp(groupName,labelGroupName);
                    if data.GroupChanged
                        data.Group=groupName;
                        modifyItemData(this,this.CurrentSelection,data);
                    end

                    data.Label=this.LabelSetPanel.Items{this.CurrentSelection}.Data.Label;
                end
                updateDataOnItemMove(this,data);

            end
            this.DropIdx=[];
        end


        function doPanelItemShrinked(this,~,data)

            if isaGroupItem(this,data.Index)
                if this.DragSetupDone
                    stopItemDrag(this,[],[]);
                end

                itemIndices=getGroupItemIndices(this);
                shrinkUpto=findUptoIndex(this,itemIndices,data.Index);
                shrinkFrom=data.Index+1;


                for itemIdx=shrinkFrom:shrinkUpto
                    makeItemInVisible(this,itemIdx);
                    this.ItemVisibility(itemIdx)=false;
                end
            end
        end


        function doPanelItemExpanded(this,~,data)


            if isaGroupItem(this,data.Index)

                if this.DragSetupDone
                    stopItemDrag(this,[],[]);
                end

                itemIndices=getGroupItemIndices(this);
                expandUpto=findUptoIndex(this,itemIndices,data.Index);
                expandFrom=data.Index+1;


                for itemIdx=expandFrom:expandUpto
                    makeItemVisible(this,itemIdx);
                    this.ItemVisibility(itemIdx)=true;
                end
            end
        end
    end




    methods(Access=private)






        function initializeButtonWidth(this)



            pos=hgconvertunits(...
            this.Fig,[0,0,0,this.AddLabelButtonHeight],'char','pixels',this.Fig);
            pos=hgconvertunits(this.Fig,[0,0,pos(4),pos(4)],'pixels','char',this.Fig);

            this.AddLabelButtonWidth=pos(3);


            pos=hgconvertunits(...
            this.Fig,[0,0,pos(3),pos(4)],'char','pixels',this.Fig);
            this.AddLabelButtonSizeInPixels=pos(3:4);
        end
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end