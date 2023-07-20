
classdef ProductCallback<characterization.STA.ImplementationCallback





    methods
        function self=ProductCallback()
            self@characterization.STA.ImplementationCallback();
        end

        function preprocessModelDependentParams(~,modelInfo)
            set_param(modelInfo.blockPath,'OutDataTypeStr','Inherit: Same as first input');
            set_param(modelInfo.blockPath,'RndMeth','Zero');
            set_param(modelInfo.blockPath,'SaturateOnIntegerOverflow','on');
        end

        function preprocessModelIndependentParams(~,modelInfo)

        end

        function preprocessWidthSettings(~,modelInfo)

        end

        function modelInfo=processConfig(~,modelInfo)

        end

    end

end
