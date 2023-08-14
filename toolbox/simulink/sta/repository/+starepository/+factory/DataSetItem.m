classdef DataSetItem<starepository.factory.ContainerItem





    properties


name


data

    end

    methods
        function obj=DataSetItem(name,data)

            if isStringScalar(name)
                name=char(name);
            end

            obj=obj@starepository.factory.ContainerItem;
            obj.data=data;
            obj.name=name;
        end

        function BusItem=createSignalItemWithoutProperties(obj)
            obj.ListItems=cell(1,obj.data.getLength);
            elementNames=obj.data.getElementNames();
            for index=1:length(obj.ListItems)
                element=obj.data.getElement(index);
                elementname=elementNames{index};
                factory=starepository.factory.createSignalItemFactory(elementname,...
                element);
                item=factory.createSignalItem();
                item.isDataSetElement=true;
                item.DataSetIdx=index;
                obj.addListItem(item,index);
            end
            BusItem=starepository.ioitem.DataSet(obj.ListItems,obj.name);
            BusItem.DatasetName=obj.data.Name;
            BusItem.UIProperties=starepository.ioitemproperty.DataSetUIProperties;

        end

        function BusItem=createSignalItemWithoutChildren(obj)
            listitems=[];
            BusItem=starepository.ioitem.DataSet(listitems,obj.name);
            BusItem.DatasetName=obj.data.Name;
            BusItem.UIProperties=starepository.ioitemproperty.DataSetUIProperties;

        end

        function busproperty=buildProperties(obj)

            busproperty=starepository.ioitem.BusProperties(obj.name);


        end
    end



    methods(Static)


        function bool=isSupported(dataValue)

            bool=false;

            if isa(dataValue,'Simulink.SimulationData.Dataset')||...
                isa(dataValue,'Simulink.SimulationData.DatasetRef')
                bool=true;
            end
        end

    end

end


