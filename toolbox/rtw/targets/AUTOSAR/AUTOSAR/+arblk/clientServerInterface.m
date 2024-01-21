classdef clientServerInterface

    properties
identifier
operation
isService
    end


    methods
        function obj=clientServerInterface(thisIdentifier)
            obj.identifier=thisIdentifier;
            obj.operation=arblk.operationPrototype.empty();
            obj.isService=false;
        end


        function obj=set.operation(obj,value)
            if isa(value,'arblk.operationPrototype')
                obj.operation=value;
            else
                DAStudio.error('RTW:autosar:invalidOperationPrototype');
            end
        end


        function obj=set.isService(obj,value)
            if value==0||value==1
                obj.isService=value;
            else
                DAStudio.error('RTW:autosar:unknownIsService');
            end
        end

    end
end
