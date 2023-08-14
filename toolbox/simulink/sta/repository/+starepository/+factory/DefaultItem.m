classdef DefaultItem<starepository.factory.Item





    properties

name
    end

    methods
        function obj=DefaultItem(name)
            obj=obj@starepository.factory.Item;
            obj.name=name;
        end

        function SignalItem=createSignalItemWithoutProperties(obj)


            SignalItem=starepository.ioitem.Signal();
            SignalItem.Data=[];
            if~isempty(obj.name)
                SignalItem.setName(obj.name);
            else
                SignalItem.setName([]);
            end

        end

        function Item=createSignalItemWithoutChildren(obj)
            Item=createSignalItemWithoutProperties(obj);
        end

        function signalproperty=buildProperties(obj)
            signalproperty=starepository.ioitem.SignalProperties(obj.name);

        end
    end



    methods(Static)


        function bool=isSupported(dataValue)

            bool=false;

        end

    end

end

