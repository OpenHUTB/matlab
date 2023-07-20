classdef TargetCustom<dnnfpga.hardware.Target




    properties(Constant)

        Interface=dlhdl.TargetInterface.Custom;
    end

    properties(Access=protected)

        DefaultProgrammingMethod=hdlcoder.ProgrammingMethod.Custom;
    end

    methods(Access=public)
        function obj=TargetCustom(hFPGA,varargin)
            dnnfpga.hardware.Target.validateFPGAObject(hFPGA);
            obj=obj@dnnfpga.hardware.Target(hFPGA.Vendor);


            [varargin{:}]=convertStringsToChars(varargin{:});


            p=inputParser;
            p.addParameter('ProgrammingMethod',obj.DefaultProgrammingMethod);

            parse(p,varargin{:});


            obj.DefaultProgrammingMethod=p.Results.ProgrammingMethod;


            obj.setFPGAObject(hFPGA);
        end

        function validateConnection(~)
            warning('No connection validation for "%s" interface.',char(obj.Interface));
        end
    end

    methods(Hidden)
        function setFPGAObject(obj,hFPGA)
            obj.validateFPGAObject(hFPGA);
            obj.hFPGA=hFPGA;
        end
    end


    methods(Access=protected)
        function configureFPGAObjectForBitstream(obj,hBitstream)








            obj.validateFPGAObjectConfigurationForBitstream(hBitstream);
        end

        function resetFPGAObject(~)




        end
    end


    methods(Access=protected)
        function validateInterface(~,~)



        end
    end
end
