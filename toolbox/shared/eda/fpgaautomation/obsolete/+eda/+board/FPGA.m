classdef FPGA<handle







    properties(SetAccess=protected)
FPGAVendor
FPGAFamily
FPGADevice
FPGASpeed
FPGAPackage
SynthesisFrequencies
    end
    properties(Dependent)
FPGAPartInfo
    end

    methods
        function result=get.FPGAPartInfo(h)
            if strcmpi(h.FPGAVendor,'Xilinx')
                result=sprintf('%s %s%s-%s',h.FPGAFamily,...
                upper(h.FPGADevice),upper(h.FPGASpeed),...
                upper(h.FPGAPackage));
            else
                result=sprintf('%s %s',h.FPGAFamily,h.FPGADevice);
            end
        end

        function arg=findPVPair(varargin)
            tmp=varargin(2:end);
            for i=1:2:length(tmp{:})
                arg.(tmp{1}{i})=tmp{1}{i+1};
            end

        end

    end
end


