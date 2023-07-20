classdef ZynqArmClockInterface<eda.internal.boardmanager.ClockInterface

    properties(Constant)
    end

    methods
        function obj=ZynqArmClockInterface
            obj=obj@eda.internal.boardmanager.ClockInterface;
        end

    end

    methods

        function setFrequency(obj,freq)
            tmp=num2str(freq);
            obj.setParam('Frequency',tmp);
        end

        function r=getFrequency(obj)
            r=str2double(obj.getParam('Frequency'));
        end


    end
end

