classdef EmbeddedFigureDisabler<handle







    properties(Access=private)
        InitialValue=false;
    end

    methods(Hidden)


        function obj=EmbeddedFigureDisabler()
            obj.InitialValue=matlab.ui.internal.EmbeddedWebFigureStateManager.setEnabled(false);
        end

        function delete(obj)


            if(obj.InitialValue)
                matlab.ui.internal.EmbeddedWebFigureStateManager.setEnabled(true);
            end
        end
    end
end