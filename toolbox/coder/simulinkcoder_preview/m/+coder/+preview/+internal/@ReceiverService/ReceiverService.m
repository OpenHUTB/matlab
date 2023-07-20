classdef ReceiverService<coder.preview.internal.ReceiverSenderService




    methods
        function obj=ReceiverService(sourceDD,type,name)

            obj@coder.preview.internal.ReceiverSenderService(sourceDD,type,name);
            obj.IdentifierResolver.dN='IN';
        end

        out=getDeclaration(obj)
        out=getUsage(obj)
    end
end
