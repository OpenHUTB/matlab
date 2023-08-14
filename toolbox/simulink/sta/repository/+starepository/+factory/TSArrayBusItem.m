classdef TSArrayBusItem<starepository.factory.ContainerItem





    properties


name


data

    end

    methods
        function obj=TSArrayBusItem(name,data)
            obj=obj@starepository.factory.ContainerItem;
            obj.data=data;
            obj.name=name;
        end

        function BusItem=createSignalItemWithoutProperties(obj)
            members=obj.data.Members;
            obj.ListItems=cell(1,length(members));
            for index=1:length(obj.ListItems)
                membername=members(index).name;
                memberdata=obj.data.(membername);
                factory=starepository.factory.createSignalItemFactory(membername,memberdata);
                item=factory.createSignalItem();
                obj.addListItem(item,index);
            end
            BusItem=starepository.ioitem.Bus(obj.ListItems,obj.name);
            BusItem.UIProperties=starepository.ioitemproperty.BusUIProperties;

        end

        function BusItem=createSignalItemWithoutChildren(obj)
            BusItem=createSignalItemWithoutProperties(obj);
        end

        function busproperty=buildProperties(obj)

            busproperty=starepository.ioitem.BusProperties(obj.name);
        end
    end



    methods(Static)


        function bool=isSupported(dataValue)

            bool=false;

            if isa(dataValue,'Simulink.TsArray')
                bool=true;
            end
        end

    end

end

