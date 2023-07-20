classdef GroundOrPartialSpecificationItem<starepository.factory.Item



    properties
Name
DefaultFactory

Item
    end


    methods


        function obj=GroundOrPartialSpecificationItem(Name,~)

            if isStringScalar(Name)
                Name=char(Name);
            end

            obj=obj@starepository.factory.Item;
            obj.Name=Name;
            obj.DefaultFactory=starepository.factory.DefaultItem(obj.Name);
        end


        function SignalItem=createSignalItemWithoutProperties(obj)

            SignalItem=starepository.ioitem.GroundOrPartialSpecification();
            SignalItem.UIProperties=starepository.ioitemproperty.SignalUIProperties;
            SignalItem.Name=obj.Name;

            obj.Item=SignalItem;


        end

        function SignalItem=createSignalItemWithoutChildren(obj)
            SignalItem=createSignalItemWithoutProperties(obj);
        end


        function signalproperty=buildProperties(obj)

            signalproperty=obj.DefaultFactory.buildProperties();




            signalproperty.DataType=class([]);


            signalproperty.SignalType=getString(message('sl_sta_general:common:Real'));


            signalproperty.Dimension=0;
        end
    end



    methods(Static)


        function bool=isSupported(dataValue)
            bool=false;




            if(isempty(dataValue)&&isnumeric(dataValue))
                bool=true;
            end
        end

    end
end
