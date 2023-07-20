classdef EmptyLoggedVariant<starepository.factory.ContainerItem




    properties

name
data
DefaultFactory
    end


    methods


        function obj=EmptyLoggedVariant(name,data)

            if isStringScalar(name)
                name=char(name);
            end

            obj=obj@starepository.factory.ContainerItem;
            obj.data=data;
            obj.name=name;
            obj.DefaultFactory=starepository.factory.DefaultItem(obj.name);
        end


        function loggedVariantItem=createSignalItemWithoutProperties(obj)
            loggedVariantItem=starepository.ioitem.EmptyLoggedVariant();
            loggedVariantItem.Name=obj.name;
            loggedVariantItem.Data=obj.data;
            loggedVariantItem.Properties=obj.DefaultFactory.buildProperties();
            loggedVariantItem.UIProperties=starepository.ioitemproperty.SignalUIProperties;
        end


        function loggedVariantItem=createSignalItemWithoutChildren(obj)
            listitems=[];
            loggedVariantItem=starepository.ioitem.EmptyLoggedVariant(listitems,obj.name);
            loggedVariantItem.Properties=obj.DefaultFactory.buildProperties();
            loggedVariantItem.UIProperties=starepository.ioitemproperty.SignalUIProperties;
        end


        function loggedVariantProperties=buildProperties(obj)

            loggedVariantProperties=obj.DefaultFactory.buildProperties();
        end
    end



    methods(Static)


        function bool=isSupported(dataValue)
            bool=false;






            if(isa(dataValue,'timeseries')&&...
                isempty(dataValue))||...
                iscell(dataValue)&&isempty(dataValue)||...
                isa(dataValue,'timetable')&&isempty(dataValue)
                bool=true;
            end
        end

    end
end