classdef ArrayOfBusItem<starepository.factory.ContainerItem





    properties


name

data
    end

    methods
        function obj=ArrayOfBusItem(name,data)

            if isStringScalar(name)
                name=char(name);
            end
            obj=obj@starepository.factory.ContainerItem;
            obj.data=data;
            obj.name=name;
        end

        function DataArrayItem=createSignalItemWithoutProperties(obj)

            obj.ListItems=cell(1,numel(obj.data));
            subscript=cell(1,length(size(obj.data)));
            for index=1:length(obj.ListItems)


                [subscript{:}]=ind2sub(size(obj.data),index);
                subcriptwithcomma=num2str(subscript{1});
                for id=2:length(subscript)
                    subcriptwithcomma=[subcriptwithcomma,',',num2str(subscript{id})];
                end
                itemname=sprintf('%s(%s)',obj.name,subcriptwithcomma);
                itemFactory=starepository.factory.createSignalItemFactory(itemname,obj.data(index));
                item=itemFactory.createSignalItem();
                obj.addListItem(item,index);

                item.UIProperties.isDisplayParentName=false;
            end
            DataArrayItem=starepository.ioitem.ArrayOfBus(obj.ListItems,obj.name);

            DataArrayItem.UIProperties=starepository.ioitemproperty.BusUIProperties;

        end

        function DataArrayItem=createSignalItemWithoutChildren(obj)
            listitems=[];
            DataArrayItem=starepository.ioitem.ArrayOfBus(listitems,obj.name);

            DataArrayItem.UIProperties=starepository.ioitemproperty.BusUIProperties;

        end
        function dataarrayproperty=buildProperties(obj)

            dataarrayproperty=starepository.ioitem.ArrayOfBusProperties(obj.name);
            dataarrayproperty.Dimension=mat2str(size(obj.data));



        end
    end



    methods(Static)


        function bool=isSupported(dataValue)
            bool=false;


            if(isstruct(dataValue)&&~isempty(fieldnames(dataValue)))&&...
                length(dataValue)~=1

                bool=true;

            end
        end

    end

end


