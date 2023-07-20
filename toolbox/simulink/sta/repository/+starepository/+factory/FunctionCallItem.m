classdef FunctionCallItem<starepository.factory.Item




    properties


name

data
    end

    methods
        function obj=FunctionCallItem(name,data)

            if isStringScalar(name)
                name=char(name);
            end

            obj=obj@starepository.factory.Item;
            obj.data=data;
            obj.name=name;
        end

        function FunctionCallItem=createSignalItemWithoutProperties(obj)
            FunctionCallItem=starepository.ioitem.FunctionCall;
            FunctionCallItem.Data=obj.data;
            FunctionCallItem.setName(obj.name);
            FunctionCallItem.UIProperties=starepository.ioitemproperty.FunctionCallUIProperties;

        end

        function FunctionCallItem=createSignalItemWithoutChildren(obj)
            FunctionCallItem=createSignalItemWithoutProperties(obj);
        end

        function dataarrayproperty=buildProperties(obj)

            dataarrayproperty=starepository.ioitem.FunctionCallProperties(obj.name);

        end
    end



    methods(Static)


        function bool=isSupported(dataValue)

            bool=false;





            if ismatrix(dataValue)&&~iscell(dataValue)&&~ischar(dataValue)&&~isstring(dataValue)...
                &&~isempty(dataValue)&&~isstruct(dataValue)&&...
                (all(isnumeric(dataValue))||all(islogical(dataValue)))&&...
                iscolumn(dataValue)
                bool=true;
            end
        end

    end
end


