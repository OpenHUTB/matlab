



classdef ClientServerInterface<autosar.ui.wizard.builder.Interface
    properties(SetAccess=private)
        OperationCount;
    end

    methods
        function obj=ClientServerInterface(name,count,type)
            obj=obj@autosar.ui.wizard.builder.Interface(name,type);
            obj.OperationCount=count;
        end

        function setOperationCount(obj,count)
            n=str2num(count);%#ok<ST2NM>
            if~isempty(n)&&n>0&&rem(n,1)==0
                obj.OperationCount=count;
            end
        end


        function dataType=getPropDataType(obj,propName)
            if strcmp(propName,'OperationCount')
                dataType='string';
            else
                dataType=getPropDataType@autosar.ui.wizard.builder.Interface(obj,propName);
            end
        end

    end

end
