classdef ParamDesc






    properties
name
type
values
doNotOutput
regenerateModel
toolDepedentParam
    end

    properties(Hidden=true,Constant)
        INPORT_PARAM=2;
        SIMULINK_PARAM=1;
        HDL_PARAM=0;
    end

    methods
        function self=ParamDesc()
            self.name='Undefined';
            self.type=characterization.ParamDesc.SIMULINK_PARAM;
            self.values={};
            self.doNotOutput=false;
            self.regenerateModel=false;
            self.toolDepedentParam=false;
        end
    end
end
