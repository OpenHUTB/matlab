




classdef BaseItemList<handle


    properties(SetAccess=private)
        itemList={};
        observers={};
    end




    methods
        function addObserver(this,newObserver)
            for i=1:numel(this.observers)
                if this.observers{i}==newObserver

                    return;
                end
            end
            this.observers{end+1}=newObserver;
        end

        function removeObserver(this,observer)
            this.observers=removeArrayElementHelper(this.observers,observer);
        end

        function removeAllObservers(this)
            observerList=this.observers;

            for i=1:numel(observerList)
                this.removeObserver(observerList{i});
            end
        end

        function outputList=getAllItems(this)
            outputList=getNonEmptyEntries(this.itemList);
        end
    end

    methods(Access=protected)
        function notifyObserversItemAdded(this,newItem)
            for i=1:numel(this.observers)
                observer=this.observers{i};

                try


                    observer.notifyObserverOfItemAddition(newItem);
                catch ME %#ok<NASGU>
                end
            end
        end

        function notifyObserversItemHasBeenRemoved(this,item)
            for i=1:numel(this.observers)
                observer=this.observers{i};
                try
                    observer.notifyObserverOfItemRemoval(item);
                catch ME %#ok<NASGU>
                end
            end
        end

        function notifyObserversListUpdated(this)
            for i=1:numel(this.observers)
                observer=this.observers{i};

                try
                    observer.notifyObserverOfListUpdate();
                catch ME %#ok<NASGU>
                end
            end
        end

        function loadItems(this,itemList)
            for i=1:numel(itemList)
                item=itemList{i};
                loadedSuccessfully=item.reload();
                if loadedSuccessfully
                    this.addItemToList(item);
                end
            end
            this.notifyObserversListUpdated();
        end

        function outputList=getActiveItems(this)
            outputList=getActiveItemsFromList(this.getAllItems());
        end

        function addItemToList(this,newItem)
            this.itemList{end+1}=newItem;
            this.notifyObserversItemAdded(newItem);

            addlistener(newItem,'ObjectBeingDestroyed',@(itemToBeRemoved,unused)this.removeItemFromList(itemToBeRemoved));
        end

        function deleteAllItems(this,listFilter)
            itemsToDelete=this.getAllItems();

            if nargin<2
                newList={};
            else
                newList=itemsToDelete(~listFilter);
                itemsToDelete=itemsToDelete(listFilter);
            end

            for i=1:numel(itemsToDelete)
                item=itemsToDelete{i};
                deleter=item.getDeleter();
                deleter.execute();
            end

            this.itemList=newList;

            this.notifyObserversListUpdated();
        end

        function removeItemFromList(this,item)
            foundItem=false;
            try
                [this.itemList,foundItem]=removeArrayElementHelper(this.itemList,item);
            catch




            end

            if foundItem
                this.notifyObserversItemHasBeenRemoved(item);
            end
        end

        function reactToModelLoad(this,modelName)
            nonEmptyItemList=this.getAllItems();
            for i=1:numel(nonEmptyItemList)
                item=nonEmptyItemList{i};

                if item.belongsToModel(modelName)
                    item.activate();
                end
            end
        end

        function reactToModelClose(this,modelName)
            nonEmptyItemList=this.getAllItems();
            for i=1:numel(nonEmptyItemList)
                item=nonEmptyItemList{i};

                if item.belongsToModel(modelName)
                    item.deactivate();
                end
            end
        end
    end
end

function outputList=getActiveItemsFromList(itemList)
    logicalArrayOfActiveItems=cellfun(@(item)item.isActive,itemList);




    outputList=itemList(logicalArrayOfActiveItems);
end

function outputList=getNonEmptyEntries(itemsList)
    nonEmptyIndices=cellfun(@(c)~isempty(c),itemsList);
    outputList=itemsList(nonEmptyIndices);
end

function[newList,foundItem]=removeArrayElementHelper(origList,elementToRemove)
    foundItem=false;
    for i=1:numel(origList)
        if origList{i}==elementToRemove
            origList(i)=[];
            foundItem=true;
            break;
        end
    end

    if~foundItem
        newList=origList;
        return;
    end

    if numel(origList)==1&&isempty(origList{1})



        origList={};
    end

    newList=origList;
end
