

classdef ListItemFactory

    methods(Static,Abstract)




        item=create(varargin)
    end

    methods(Sealed)





        function item=buildAndConfigure(factory,list,positionInList,data)
            item=factory.create(getParentForItem(list),positionInList,data);
            addlistener(item,'ListItemSelected',@list.listItemSelected);
            addlistener(item,'ListItemExpanded',@list.listItemExpanded);
            addlistener(item,'ListItemShrinked',@list.listItemShrinked);
            addlistener(item,'ListItemModified',@list.listItemModified);
            addlistener(item,'ListItemDeleted',@list.listItemDeleted);
            addlistener(item,'ListItemBeingEdited',@list.listItemBeingEdited);
            addlistener(item,'ListItemROIVisibility',@list.listItemROIVisibility);
        end

    end
end