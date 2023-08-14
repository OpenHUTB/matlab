
classdef MultiPortSwitchCallback<characterization.STA.ImplementationCallback





    methods
        function self=MultiPortSwitchCallback()
            self@characterization.STA.ImplementationCallback();
        end

        function modelInfo=processConfig(~,modelInfo)
            x=modelInfo.modelDependantParams('Inputs');
            width=str2double(x{1});
            modelInfo.currentWidthSettings={1,width};

        end

    end

end
