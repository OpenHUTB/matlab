classdef MATLABStructBusItem<starepository.factory.ContainerItem




    properties


name

data

    end

    methods
        function obj=MATLABStructBusItem(name,data)

            if isStringScalar(name)
                name=char(name);
            end

            obj=obj@starepository.factory.ContainerItem;
            obj.data=data;
            obj.name=name;
        end

        function BusItem=createSignalItemWithoutProperties(obj)

            fieldNames=fieldnames(obj.data);
            obj.ListItems=cell(1,length(fieldNames));
            itemcounter=0;


            for index=1:length(fieldNames)
                itemFactory=starepository.factory.createSignalItemFactory(fieldNames{index},obj.data.(fieldNames{index}));
                if~isempty(itemFactory)
                    item=itemFactory.createSignalItem();
                    if~isempty(item)
                        itemcounter=itemcounter+1;
                        obj.addListItem(item,itemcounter);
                    end
                end
            end
            if isempty(obj.ListItems)||isequal(itemcounter,0)
                BusItem=starepository.ioitem.Bus([],obj.name);
                BusItem.UIProperties=starepository.ioitemproperty.BusUIProperties;

            else
                listitems=obj.ListItems(1:itemcounter);
                BusItem=starepository.ioitem.Bus(listitems,obj.name);
                BusItem.UIProperties=starepository.ioitemproperty.BusUIProperties;


            end

        end

        function BusItem=createSignalItemWithoutChildren(obj)
            listitems=[];
            BusItem=starepository.ioitem.Bus(listitems,obj.name);
            BusItem.UIProperties=starepository.ioitemproperty.BusUIProperties;

        end

        function busproperty=buildProperties(obj)

            busproperty=starepository.ioitem.BusProperties(obj.name);

        end
    end



    methods(Static)


        function bool=isSupported(dataValue)
            bool=false;



            if((isstruct(dataValue)&&~isempty(fieldnames(dataValue)))&&...
                length(dataValue)==1&&...
                ~all(isfield(dataValue,{'time','signals'}))||...
                (isstruct(dataValue)&&isempty(fieldnames(dataValue))))

                bool=true;

            end
        end

    end
end

