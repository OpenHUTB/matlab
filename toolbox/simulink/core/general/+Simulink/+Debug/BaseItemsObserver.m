




classdef BaseItemsObserver<handle
    properties(SetAccess=private)
        propertyListeners={};
        fcnHandleToGetItemContainer=[];
    end

    methods
        function this=BaseItemsObserver(fcnHandleToGetItemContainer)

            this.fcnHandleToGetItemContainer=fcnHandleToGetItemContainer;

            itemContainer=this.fcnHandleToGetItemContainer();

            itemContainer.addObserver(this);

            items=itemContainer.getAllItems();
            for i=1:length(items)
                item=items{i};
                this.setupPropertyListeners(item);
            end
        end

        function delete(this)
            try
                itemContainer=this.fcnHandleToGetItemContainer();
                itemContainer.removeObserver(this);
            catch ME
                disp(ME.message);
            end

        end

        function notifyObserverOfItemAddition(this,item)
            this.setupPropertyListeners(item);
            this.onItemAdded(item);
        end

        function notifyObserverOfItemRemoval(this,item)
            this.onItemRemoved(item);
        end

        function notifyObserverOfListUpdate(this)
            this.onItemListUpdate();
        end
    end

    methods(Abstract)
        onItemListUpdate(this);
        onItemAdded(this,newItem);
        onItemRemoved(this,item);
        onItemChanged(this,changedItem);
    end

    methods(Access=private)
        function setupPropertyListeners(this,item)
            meta=metaclass(item);
            props=meta.PropertyList;

            for i=1:numel(props)
                if props(i).SetObservable
                    this.propertyListeners{end+1}=event.proplistener(item,props(i),'PostSet',@(src,evt)this.onItemChanged(evt.AffectedObject));
                end
            end
        end
    end
end