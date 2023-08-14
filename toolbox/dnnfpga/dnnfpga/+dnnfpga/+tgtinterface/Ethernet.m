


classdef Ethernet<dnnfpga.tgtinterface.TargetInterfaceBase


    properties(Constant,Hidden)
        InterfaceType=dlhdl.TargetInterface.Ethernet;
    end

    properties(Access=protected)
        DeepLearningProcessorWriteDeviceName string="mwipcore_dl0:mmwr0";
        DeepLearningProcessorReadDeviceName string="mwipcore_dl0:mmrd0";
        MemoryWriteDeviceName string="mwipcore_ddr0:mm2s0";
        MemoryReadDeviceName string="mwipcore_ddr0:s2mm0";
    end

    methods
        function obj=Ethernet(varargin)
            p=inputParser;
            p.addParameter("DeepLearningProcessorWriteDeviceName",obj.DeepLearningProcessorWriteDeviceName);
            p.addParameter("DeepLearningProcessorReadDeviceName",obj.DeepLearningProcessorReadDeviceName);
            p.addParameter("MemoryWriteDeviceName",obj.MemoryWriteDeviceName);
            p.addParameter("MemoryReadDeviceName",obj.MemoryReadDeviceName);

            p.parse(varargin{:});

            obj.DeepLearningProcessorWriteDeviceName=p.Results.DeepLearningProcessorWriteDeviceName;
            obj.DeepLearningProcessorReadDeviceName=p.Results.DeepLearningProcessorReadDeviceName;
            obj.MemoryWriteDeviceName=p.Results.MemoryWriteDeviceName;
            obj.MemoryReadDeviceName=p.Results.MemoryReadDeviceName;
        end

        function[writeDevName,readDevName]=getDLProcessorDeviceNames(obj)
            writeDevName=char(obj.DeepLearningProcessorWriteDeviceName);
            readDevName=char(obj.DeepLearningProcessorReadDeviceName);
        end

        function[writeDevName,readDevName]=getMemoryDeviceNames(obj)
            writeDevName=char(obj.MemoryWriteDeviceName);
            readDevName=char(obj.MemoryReadDeviceName);
        end
    end
end