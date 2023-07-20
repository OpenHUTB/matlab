classdef(Sealed,Hidden)AliveSwitch<handle









    properties(Constant,Access=private)
        pObj(1,1)Simulink.variant.reducer.AliveSwitch=Simulink.variant.reducer.AliveSwitch;
    end

    properties(Access=private)
        isLive(1,1)logical=false;
    end

    methods(Access=private)
        function obj=AliveSwitch()
        end
    end

    methods(Static,Hidden,Access=public)
        function obj=getInstance()
            obj=Simulink.variant.reducer.AliveSwitch.pObj;
        end
    end

    methods(Hidden,Access={?Simulink.variant.reducer.ReductionManager,?VRedUnitTest,?slvariants.internal.reducer.Core})
        function setAliveStatus(obj,aliveStatus)
            obj.isLive=aliveStatus;
        end
    end

    methods(Hidden,Access=public)
        function aliveStatus=getAliveStatus(obj)
            aliveStatus=obj.isLive;
        end
    end

end
