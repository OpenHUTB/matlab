classdef(Abstract)ImageSource<handle




    methods(Abstract)

        loadImage(obj)
    end

    methods


        function setDPIScale(~,~)
        end
    end

    events
        SourceChanged;
    end
end