
classdef BitShiftCallback<characterization.STA.ImplementationCallback





    methods
        function self=BitShiftCallback()
            self@characterization.STA.ImplementationCallback();
        end


        function modelInfo=processConfig(~,modelInfo)
            x=modelInfo.modelIndependantParams('N');
            width=str2double(x{1});
            modelInfo.currentWidthSettings={1,width};

        end

    end

end
