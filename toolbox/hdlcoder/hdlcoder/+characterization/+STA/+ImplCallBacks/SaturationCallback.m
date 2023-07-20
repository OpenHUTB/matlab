
classdef SaturationCallback<characterization.STA.ImplementationCallback





    methods
        function self=SaturationCallback()
            self@characterization.STA.ImplementationCallback();
        end

        function preprocessWidthSettings(~,modelInfo)

            width=modelInfo.wmap(1);
            np=floor((width{1}-1)/2);
            value=pow2(np);
            up=modelInfo.modelIndependantParams('UpperLimit');
            modelInfo.modelIndependantParams('UpperLimit')={num2str(value),up{2}};
            down=modelInfo.modelIndependantParams('LowerLimit');
            modelInfo.modelIndependantParams('LowerLimit')={num2str(-value),down{2}};

        end

    end

end
