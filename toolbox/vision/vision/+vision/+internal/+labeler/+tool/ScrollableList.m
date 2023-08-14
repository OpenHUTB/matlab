

classdef ScrollableList<vision.internal.labeler.tool.ScrollablePanel

    properties

        Items={}



CurrentSelection


DisabledItems


InvisibleItems

ItemFactory




        MultiSelectSupport=false;




        IsSelectionInProgress=false;
    end

    properties(Constant)


        KeyboardUpDownScrollIncrement=1;
        KeyboardPageUpDownScrollIncrement=5;
    end

    events

        ItemSelected;


        ItemModified;


        ItemRemoved;


        ItemBeingEdited;


ItemShrinked


ItemExpanded



ItemROIVisibility
    end




    methods

        function this=ScrollableList(parent,position,itemFactory)

            this=this@vision.internal.labeler.tool.ScrollablePanel(parent,position);

            this.ItemFactory=itemFactory;

            show(this);
            update(this);


            if this.NumItems>0
                this.CurrentSelection=1;
            else
                this.CurrentSelection=0;
            end

            this.DisabledItems=0;
        end
    end




    methods(Access=public)

        function item=getItem(this,idx)
            if(idx<=this.NumItems)
                item=this.Items{idx};
            else
                item=[];
            end
        end


        function names=getItemDataNames(this)
            names=cell(1,this.NumItems);

            for i=1:this.NumItems
                names{i}=getDataNames(this.Items{i});
            end

        end


        function str=getRootName(this)
            if(this.NumItems>=1)
                str=getRootName(this.Items{1});
            else
                str='';
            end
        end


        function str=getHeaderText(this)
            if(this.NumItems>=1)
                str=getHeaderText(this.Items{1});
            else
                str='';
            end
        end


        function itemID=getItemID(this,varargin)
            for i=1:this.NumItems
                hasMatch=compareDataElement(this.Items{i},varargin{:});
                if hasMatch
                    itemID=i;
                    return;
                end
            end
            itemID=-inf;
        end


        function[currentPointYInMP,limits]=getCurrentPtInMovingPanel(this,currentPoint)



            [fpTop,fpBot]=getFixedPanelViewArea(this);
            [~,mpBot]=getMovingPanelLimits(this);



            currentPointYInFP=currentPoint(2);

            currentPointYInFP=min(max(currentPointYInFP,fpBot),fpTop);

            if this.UseAppContainer
                diff=this.MovingPanel.ScrollableViewportLocation(2);
            else
                diff=max(abs(mpBot)-abs(fpBot),0);
            end

            currentPointYInMP=currentPointYInFP+diff;

            limits=[fpBot,fpTop];

        end
    end




    methods(Access=public)

        function createItems(this,data)
            numItems=numel(data);
            this.Items=cell(numItems,1);
            for i=1:numItems
                this.Items{i}=this.ItemFactory.buildAndConfigure(this,i,data(i));
            end

            if this.NumItems>0

                this.CurrentSelection=1;
                select(this.Items{1});
            end
        end


        function appendItem(this,data)
            idx=this.NumItems+1;
            this.Items{end+1}=this.ItemFactory.buildAndConfigure(this,idx,data);
        end


        function updateItem(this)
            update(this);
        end


        function insertItem(this,data,idxInsertAfter)

            numExistignItems=length(this.Items);
            if idxInsertAfter>numExistignItems
                return;
            elseif idxInsertAfter==numExistignItems
                appendItem(this,data);
                unselect(this.Items{end});
            else
                appendItem(this,data);
                moveItem(this,this.NumItems,idxInsertAfter+1);
            end
            this.DisabledItems=this.DisabledItems+(this.DisabledItems>idxInsertAfter);
            this.InvisibleItems=this.InvisibleItems+(this.InvisibleItems>idxInsertAfter);
        end


        function moveItem(this,currentIdx,destinationIdx)

            if destinationIdx>currentIdx
                incrementVal=1;
            else
                incrementVal=-1;
            end

            currentItem=this.Items{currentIdx};

            while currentItem.Index~=destinationIdx
                i=currentItem.Index;
                j=i+incrementVal;

                temp1Pos=this.Items{i}.Position;
                temp1Pos(3:4)=this.Items{j}.Position(3:4);
                temp2Pos=this.Items{j}.Position;
                temp2Pos(3:4)=this.Items{i}.Position(3:4);

                if incrementVal==1
                    temp1Pos(2)=temp2Pos(2)+temp2Pos(4);
                else
                    temp2Pos(2)=temp1Pos(2)+temp1Pos(4);
                end

                temp1Item=this.Items{i};
                temp2Item=this.Items{j};
                this.Items{i}=temp2Item;
                this.Items{j}=temp1Item;

                modifyItemPosition(this,i,temp1Pos);
                modifyItemPosition(this,j,temp2Pos);

                modifyItemIndex(this,i);
                modifyItemIndex(this,j);

                currentItem=this.Items{j};
            end

            this.DisabledItems=find(cellfun(@(x)x.IsDisabled,this.Items));
            this.InvisibleItems=find(cellfun(@(x)~x.Visible,this.Items));

        end


        function repositionItem(this,index,position)
            modifyPosition(this.Items{index},position);
        end






        function modify(this,idx,data)
            modify(this.Items{idx},data);
        end


        function modifyItemData(this,idx,data)
            modifyData(this.Items{idx},data);
        end


        function modifyItemPosition(this,idx,position)
            modifyPosition(this.Items{idx},position);
        end


        function modifyItemIndex(this,idx)
            modifyIndex(this.Items{idx},idx);
        end


        function recreateContextMenu(this,idx,cMenu)
            recreateContextMenu(this.Items{idx},cMenu);
        end


        function resetChildContextMenu(this,idx)
            resetChildContextMenu(this.Items{idx});
        end


        function updateFirstItemData(this,data)
            updateFirstItemData(this.Items{1},data);
        end


        function updateItemDataValue(this,itemID,val)
            if(itemID<=this.NumItems)
                updateItemDataValue(this.Items{itemID},val);
            end
        end


        function unselectToBeDisabledItems(this,toBeDisabledItemsIdx)

            validItemIdx=setdiff(1:this.NumItems,[toBeDisabledItemsIdx,this.DisabledItems]);

            validSelectedItemIdx=intersect(this.CurrentSelection,validItemIdx);
            hasValidSelection=~isempty(validSelectedItemIdx);


            if~hasValidSelection&&~isempty(validItemIdx)


                this.selectItem(validItemIdx(1));

                this.CurrentSelection=validItemIdx(1);
            end


            invalidSelectedItemIdx=intersect(this.CurrentSelection,toBeDisabledItemsIdx);

            for i=1:numel(invalidSelectedItemIdx)

                itemIdx=invalidSelectedItemIdx(i);

                unselect(this.Items{itemIdx});


                this.CurrentSelection(this.CurrentSelection==itemIdx)=[];
            end
        end
    end




    methods(Access=public)

        function disableItem(this,idx)

            disable(this.Items{idx});

            if~isequal(this.DisabledItems,0)
                this.DisabledItems=[this.DisabledItems,idx];
            else
                this.DisabledItems=idx;
            end

        end


        function disableAllItems(this)

            if this.NumItems>0
                for n=1:this.NumItems
                    disableItem(this,n);
                end
            end
        end


        function enableItem(this,idx)

            enable(this.Items{idx});

            if~isequal(this.DisabledItems,0)
                this.DisabledItems=this.DisabledItems(this.DisabledItems~=idx);
            end

        end


        function enableAllItems(this)

            if this.NumItems>0
                for n=1:this.NumItems
                    enableItem(this,n);
                end
            end
        end


        function freezeAllItems(this)
            if this.NumItems>0
                for n=1:this.NumItems
                    freeze(this.Items{n});
                end
            end
        end


        function unfreezeAllItems(this)
            if this.NumItems>0
                for n=1:this.NumItems
                    unfreeze(this.Items{n});
                end



                if isempty(this.CurrentSelection)||any(this.CurrentSelection==0)
                    this.CurrentSelection=1;
                    select(this.Items{1});

                    eventData=vision.internal.labeler.tool.ItemSelectedEvent(1);
                    notify(this,'ItemSelected',eventData);
                end
            end
        end


        function makeItemVisible(this,idx)
            makeVisible(this.Items{idx});
            this.InvisibleItems=this.InvisibleItems(this.InvisibleItems~=idx);
        end


        function makeItemInVisible(this,idx)
            makeInvisible(this.Items{idx});
            this.InvisibleItems=[this.InvisibleItems,idx];
        end
    end




    methods(Access=public)

        function deleteItem(this,data)
            deleteItemWithID(this,data.Index);
        end


        function deleteAllItems(this)


            if this.NumItems>0
                for idx=this.NumItems:-1:1
                    if isvalid(this.Items{idx})
                        delete(this.Items{idx});
                    end
                    this.Items(idx)=[];
                end

                update(this);
                this.CurrentSelection=0;
            end
        end


        function deleteItemWithID(this,idx)

            delete(this.Items{idx});
            this.Items(idx)=[];


            for i=1:this.NumItems
                this.Items{i}.Index=i;
            end

            update(this);

            if this.NumItems>0
                if this.CurrentSelection>=idx
                    this.CurrentSelection=0;
                    idx=min(idx,this.NumItems);
                    selectItem(this,idx);
                end
            else
                this.CurrentSelection=0;
            end

        end
    end




    methods(Access=public)

        function selectNextItem(this)

            enabledItems=setdiff(1:this.NumItems,this.DisabledItems);
            enabledItems=setdiff(enabledItems,this.InvisibleItems);


            if numel(enabledItems)<2
                return;
            end

            currentIdx=find(enabledItems==this.CurrentSelection,1);
            nextIdx=currentIdx+1;



            if nextIdx>numel(enabledItems)
                nextIdx=1;
            end

            selectItem(this,enabledItems(nextIdx));
        end


        function selectPrevItem(this)

            enabledItems=setdiff(1:this.NumItems,this.DisabledItems);
            enabledItems=setdiff(enabledItems,this.InvisibleItems);


            if numel(enabledItems)<2
                return;
            end

            currentIdx=find(enabledItems==this.CurrentSelection,1);
            prevIdx=currentIdx-1;



            if prevIdx<1
                prevIdx=numel(enabledItems);
            end

            selectItem(this,enabledItems(prevIdx));
        end


        function selectAllItems(this)
            if this.NumItems>0
                for i=1:this.NumItems
                    select(this.Items{i});
                end

                this.CurrentSelection=1:this.NumItems;

                eventData=vision.internal.labeler.tool.ItemSelectedEvent(this.CurrentSelection);

                notify(this,'ItemSelected',eventData);
            end
        end


        function selectItem(this,idx)



            if this.IsSelectionInProgress
                return;
            end



            this.IsSelectionInProgress=true;
            resetSelection=onCleanup(@()resetSelectionStatus(this));

            if(idx<0||idx>this.NumItems)
                return;
            end

            if this.MultiSelectSupport&&isCtrlClick(this)

                if not(any(this.CurrentSelection==idx))
                    select(this.Items{idx});


                    boolarray([this.CurrentSelection,idx])=true;
                    this.CurrentSelection=find(boolarray);

                    eventData=vision.internal.labeler.tool.ItemSelectedEvent(this.CurrentSelection);

                    notify(this,'ItemSelected',eventData);
                end
            else





                if this.CurrentSelection>0
                    for i=1:this.NumItems
                        unselect(this.Items{i});
                    end
                end

                select(this.Items{idx});





                if~this.UseAppContainer
                    drawnow;
                end

                if isempty(this.CurrentSelection)||numel(this.CurrentSelection)>1||this.CurrentSelection~=idx


                    this.CurrentSelection=idx;


                    if~isItemVisible(this,this.CurrentSelection)
                        this.scrollTo(this.CurrentSelection);
                    end
                end

                eventData=vision.internal.labeler.tool.ItemSelectedEvent(idx);

                notify(this,'ItemSelected',eventData);
            end
        end


        function unSelectItem(this,idx)
            if this.NumItems>1
                unselect(this.Items{idx});
            end
        end
    end


    methods(Access=private)
        function resetSelectionStatus(this)
            this.IsSelectionInProgress=false;
        end
    end




    methods(Access=public)

        function listItemSelected(this,~,data)
            selectItem(this,data.Index);
        end


        function listItemChecked(this,index)
            checkStatus(this.Items{index});
        end


        function listItemUnchecked(this,index)
            UncheckStatus(this.Items{index});
        end


        function listItemExpanded(this,~,data)
            expand(this.Items{data.Index});


            for i=1:this.NumItems
                if data.Index~=i
                    shrink(this.Items{i});
                end
            end

            update(this);
        end


        function listItemShrinked(this,~,data)
            shrink(this.Items{data.Index});

            update(this);
        end


        function listItemModified(this,~,data)
            notify(this,'ItemModified',data);
        end


        function listItemDeleted(this,~,data)
            notify(this,'ItemRemoved',data);
        end


        function listItemBeingEdited(this,~,data)
            notify(this,'ItemBeingEdited',data);
        end


        function listItemROIVisibility(this,~,data)
            notify(this,'ItemROIVisibility',data);
        end
    end




    methods(Access=public)

        function keyboardScroll(this,src,event)

            if this.NumItems<1
                return;
            end

            isCtrlPressed=any(strcmp(event.Modifier,'control'))||...
            any(strcmp(event.Modifier,'command'));

            ctrl_a_pressed=this.MultiSelectSupport&&...
            isCtrlPressed&&strcmp(event.Key,'a');

            if ctrl_a_pressed

                selectAllItems(this);

            else

                switch event.Key
                case 'downarrow'
                    increment=this.KeyboardUpDownScrollIncrement;
                case 'uparrow'
                    increment=-this.KeyboardUpDownScrollIncrement;
                case 'pageup'
                    increment=-this.KeyboardPageUpDownScrollIncrement;
                case 'pagedown'
                    increment=this.KeyboardPageUpDownScrollIncrement;
                case 'home'
                    increment=-Inf;
                case 'end'
                    increment=Inf;
                otherwise

                    return;
                end




                if numel(this.CurrentSelection)>1
                    for i=this.CurrentSelection
                        unselect(this.Items{i});
                    end
                    this.CurrentSelection=this.CurrentSelection(end);
                end


                selection=max(1,...
                min(this.CurrentSelection+increment,this.NumItems));

                selectItem(this,selection);


                if~isItemVisible(this,selection)
                    keyboardScroll@vision.internal.labeler.tool.ScrollablePanel(this,src,event);
                end
            end
        end


        function tf=isCtrlClick(this)


            modifier=get(this.Figure,'CurrentModifier');
            ctrlPressed=~isempty(modifier)&&strcmpi(modifier,'control');

            tf=ctrlPressed&&strcmpi(this.Figure.SelectionType,'alt');
        end

    end

end
