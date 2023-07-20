classdef DataTransferService<coder.preview.internal.ServiceInterface




    methods
        function obj=DataTransferService(sourceDD,type,name)

            obj@coder.preview.internal.ServiceInterface(sourceDD,type,name);
        end

        out=getDeclaration(obj)
        out=getUsage(obj)

        function out=getReceiverFunctionName(obj)

            out=obj.getReceiverSenderFunctionName('DataReceiverFunctionName','IN');
        end

        function out=getSenderFunctionName(obj)

            out=obj.getReceiverSenderFunctionName('DataSenderFunctionName','OUT');
        end
    end

    methods(Access=private)
        function out=getReceiverSenderFunctionName(obj,property,dN)

            tmp=obj.IdentifierResolver.dN;
            obj.IdentifierResolver.dN=dN;
            out=obj.getFunctionName(obj.getProperty(property));
            obj.IdentifierResolver.dN=tmp;
        end
    end
end
