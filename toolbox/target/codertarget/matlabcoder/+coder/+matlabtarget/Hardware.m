classdef Hardware<coder.Hardware



    properties
BuildAction
    end

    properties(Hidden,Constant)
        ValidBuildActions={'Build','Build, load, and run'}
    end

    methods
        function set.BuildAction(obj,value)
            obj.BuildAction=validatestring(value,obj.ValidBuildActions);
            setpref('MathWorks_targetHardware','BuildAction',value);
        end

        function ret=get.BuildAction(~)
            if ispref('MathWorks_targetHardware','BuildAction')
                ret=getpref('MathWorks_targetHardware','BuildAction');
            else
                ret='Build, load, and run';
            end
        end
    end
end
