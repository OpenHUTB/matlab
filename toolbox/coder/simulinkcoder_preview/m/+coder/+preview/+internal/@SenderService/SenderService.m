classdef SenderService<coder.preview.internal.ReceiverSenderService




    methods
        function obj=SenderService(sourceDD,type,name)

            obj@coder.preview.internal.ReceiverSenderService(sourceDD,type,name);
            obj.IdentifierResolver.dN='OUT';
        end

        out=getDeclaration(obj)
        out=getUsage(obj)
    end
end
