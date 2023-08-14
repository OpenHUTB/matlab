





classdef ServiceInterface<autosar.ui.wizard.builder.Interface
    properties(SetAccess=private)
        EventCount;
        MethodCount;
    end

    methods
        function obj=ServiceInterface(name,eventCount,methodCount,type)
            obj=obj@autosar.ui.wizard.builder.Interface(name,type);
            obj.EventCount=eventCount;
            obj.MethodCount=methodCount;
        end

        function setEventCount(obj,count)
            n=str2num(count);%#ok<ST2NM>
            if~isempty(n)&&rem(n,1)==0
                obj.EventCount=count;
            end
        end

        function setMethodCount(obj,count)
            n=str2num(count);%#ok<ST2NM>
            if~isempty(n)&&rem(n,1)==0
                obj.MethodCount=count;
            end
        end


        function dataType=getPropDataType(obj,propName)
            if strcmp(propName,'MethodCount')||strcmp(propName,'EventCount')||...
                strcmp(propName,'FieldCount')
                dataType='string';
            else
                dataType=getPropDataType@autosar.ui.wizard.builder.Interface(obj,propName);
            end
        end

    end

end
