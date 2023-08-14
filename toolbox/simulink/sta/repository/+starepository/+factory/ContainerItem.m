classdef ContainerItem<starepository.factory.Item





    properties

ContainerItemState
ListItems

    end

    methods
        function obj=ContainerItem
            obj=obj@starepository.factory.Item;
            obj.ContainerItemState=starepository.ioitemproperty.ItemState.Normal;
        end

        function addListItem(obj,item,itemcounter)
            obj.ListItems{itemcounter}=item;
        end

    end

end