classdef FPGAExecution<handle




    properties
hW
    end
    methods
        function obj=FPGAExecution(dlquantObj,execParams)




            if(~isa(dlquantObj,'dlquantizer'))
                error(message('dnnfpga:quantization:InvalidQuantizerObj'));
            end


            obj.hW=dlhdl.Workflow('Network',dlquantObj,...
            'BitStream',execParams.Bitstream,...
            'Target',execParams.Target);

            obj.hW.compile;
            obj.hW.deploy;

        end
    end

    methods

        function predictFcnHandle=hilSim(obj)




            predictFcnHandle=@predictWithProfile;
        end
    end
end