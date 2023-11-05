classdef ResetInterface<eda.internal.boardmanager.PredefinedInterface

    properties(Constant)
        Name='Reset';
    end

    methods

        function obj=ResetInterface
            obj=obj@eda.internal.boardmanager.PredefinedInterface;
        end
        function defineInterface(obj)
            obj.addSignalDefinition('Reset','Reset','in',1);
            obj.addParameterDefinition('ActiveLevel','Active-Low');
        end
    end

    methods
        function setActiveLow(obj,value)
            if value
                obj.setParam('ActiveLevel','Active-Low');
            else
                obj.setParam('ActiveLevel','Active-High');
            end
        end
        function r=isActiveLow(obj)
            r=strcmpi(obj.getParam('ActiveLevel'),'Active-Low');
        end
        function r=getResetPin(obj)
            signal=obj.getSignal('Reset');
            r=signal.getPinsInFilFormat;
        end

    end
end

