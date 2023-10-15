classdef Settings < handle

    properties
        Logger
    end

    methods
        function obj = Settings( Logger )


            arguments
                Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
            end
            obj.Logger = Logger;
        end
    end
end

