classdef BlockDataItem<starepository.factory.Item






    properties


name

Item

data

    end

    methods
        function obj=BlockDataItem(name,data)

            if isStringScalar(name)
                name=char(name);
            end
            obj=obj@starepository.factory.Item;
            obj.data=data;
            obj.name=name;
        end

        function Item=createSignalItemWithoutProperties(obj)


            itemFactory=starepository.factory.createSignalItemFactory(obj.name,obj.data.Values);
            obj.Item=itemFactory.createSignalItem;

            if isa(obj.Item,'starepository.ioitem.EmptyLoggedVariant')
                obj.Item.Data=obj.data;
            end

            obj.Item.isLogged=true;

            if isa(obj.Item,'starepository.ioitem.Signal')||...
                isa(obj.Item,'starepository.ioitem.MultiDimensionalTimeSeries')||...
                isa(obj.Item,'starepository.ioitem.NDimensionalTimeseries')

                obj.Item.SignalName=obj.data.Name;
                obj.Item.TSName=obj.data.Name;
                if~isa(obj.data,'Stateflow.SimulationData.State')&&...
                    ~isa(obj.data,'Simulink.SimulationData.State')&&...
                    ~isa(obj.data,'Simulink.SimulationData.DataStoreMemory')&&...
                    ~isa(obj.data,'Stateflow.SimulationData.Data')&&...
                    ~isa(obj.data,'Simulink.SimulationData.Parameter')||...
                    isprop(obj.data,'PortType')
                    obj.Item.PortType=obj.data.PortType;
                end
            end


            if obj.data.BlockPath.getLength()>0
                obj.Item.BlockPath=obj.data.BlockPath.convertToCell();

                obj.Item.BlockPathType=class(obj.data.BlockPath);
            else
                obj.Item.BlockPath='';
            end

            if isprop(obj.data.BlockPath,'SubPath')
                obj.Item.SubPath=obj.data.BlockPath.SubPath;
            end



            ItemProperties=properties(obj.data);
            obj.Item.BlockDataProperties=struct;
            for id=1:length(ItemProperties)



                if~any(strcmp(ItemProperties{id},{'Values','BlockPath'}))
                    obj.Item.BlockDataProperties.(ItemProperties{id})=...
                    obj.data.(ItemProperties{id});
                end
            end

            obj.Item.BlockDataProperties.('BlockDataSubClass')=class(obj.data);

            Item=obj.Item;
        end

        function BusItem=createSignalItemWithoutChildren(obj)
            BusItem=createSignalItemWithoutProperties(obj);
        end


        function signalproperty=buildProperties(obj)

            signalproperty=obj.Item.Properties;



        end
    end



    methods(Static)


        function bool=isSupported(dataValue)

            bool=false;

            if isa(dataValue,'Simulink.SimulationData.BlockData')
                bool=true;
            end
        end

    end

end
