





classdef PersistencyKeyValueInterface<autosar.ui.wizard.builder.Interface

    properties(SetAccess=private)
        DataElementCount;
    end

    methods
        function obj=PersistencyKeyValueInterface(name,dataElementCount,type)
            obj=obj@autosar.ui.wizard.builder.Interface(name,type);
            obj.DataElementCount=dataElementCount;
        end

        function setDataElementCount(obj,count)
            n=str2num(count);%#ok<ST2NM>
            if~isempty(n)&&rem(n,1)==0
                obj.DataElementCount=count;
            end
        end


        function dataType=getPropDataType(obj,propName)
            if strcmp(propName,'DataElementCount')
                dataType='string';
            else
                dataType=getPropDataType@autosar.ui.wizard.builder.Interface(obj,propName);
            end
        end

    end
end
