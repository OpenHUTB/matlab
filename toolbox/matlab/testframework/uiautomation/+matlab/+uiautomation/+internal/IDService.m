classdef IDService<...
...
    matlab.ui.internal.componentframework.services.core.identification.IdentificationService




    methods(Static)

        function id=getId(h)
            id=char(h.getId());
        end

    end

end