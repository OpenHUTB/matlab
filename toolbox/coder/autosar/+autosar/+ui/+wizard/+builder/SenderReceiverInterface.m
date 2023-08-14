



classdef SenderReceiverInterface<autosar.ui.wizard.builder.Interface
    properties(SetAccess=private)
        DataElementCount;
    end

    methods
        function obj=SenderReceiverInterface(name,count,type)
            obj=obj@autosar.ui.wizard.builder.Interface(name,type);
            obj.DataElementCount=count;
        end

        function setDataElementCount(obj,count)
            n=str2num(count);%#ok<ST2NM>
            if~isempty(n)&&n>0&&rem(n,1)==0
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
