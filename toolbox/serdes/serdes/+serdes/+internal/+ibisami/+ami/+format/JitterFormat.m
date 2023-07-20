classdef(Abstract)JitterFormat<serdes.internal.ibisami.ami.format.AmiFormat





    properties
    end

    methods
        function format=JitterFormat()
            format.AllowedTypeNames=[serdes.internal.ibisami.ami.type.Float().Name,...
            serdes.internal.ibisami.ami.type.UI().Name];
        end
    end
    methods

        function verified=verifyValueForType(~,~,~)


            verified=false;
        end
    end
end

