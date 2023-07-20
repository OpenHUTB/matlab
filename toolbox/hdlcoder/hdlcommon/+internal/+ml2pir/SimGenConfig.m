




classdef SimGenConfig<handle

    properties(Hidden)

        Debug(1,1)logical=false;

        OpenModel(1,1)logical=true;

        EnableConstrainer(1,1)logical=true;

        AllowForLoops(1,1)logical=false;
    end

    properties
        SaturateOnIntegerOverflow(1,1)logical=true;
    end

    properties(Access='private')

        SimGenMode(1,1)internal.ml2pir.simgen.SimGenMode=internal.ml2pir.simgen.SimGenMode.Default;
    end

    methods(Access='public')
        function enableHDLMode(this)
            this.SimGenMode=internal.ml2pir.simgen.SimGenMode.HDL;
        end

        function disableHDLMode(this)
            this.SimGenMode=internal.ml2pir.simgen.SimGenMode.Default;
        end

        function val=getSimGenMode(this)
            val=this.SimGenMode;
        end
    end

    methods
        function set.SimGenMode(this,val)
            assert(isa(val,'internal.ml2pir.simgen.SimGenMode'));
            this.SimGenMode=val;
        end
    end

    methods(Static)

        function name=buildOutputModelName(origName)
            name=[origName,'_mdl'];
        end
    end
end


