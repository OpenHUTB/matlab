

classdef IPTestbench<handle

    properties
        hIP=[];
        hUVMGenerator=[];
    end

    methods

        function obj=IPTestbench(hIP)
            obj.hIP=hIP;
            obj.hUVMGenerator=hdlturnkey.iptestbench.IPTestbenchUVMGenerator(obj);
        end

        function generateIPTestbench(obj)

            obj.hUVMGenerator.getIPCoreCodeGenPIRInfo;


            obj.hUVMGenerator.runUVMBuild;


            obj.hUVMGenerator.configUVMComponent;


            obj.hUVMGenerator.generateInterface;


            obj.hUVMGenerator.generateDriver;


            obj.hUVMGenerator.generateAgent;


            obj.hUVMGenerator.generateMonitor;


            obj.hUVMGenerator.generateMonitorInput;


            obj.hUVMGenerator.generateTest;


            obj.hUVMGenerator.generateTop;


            obj.hUVMGenerator.generateExtension;


            obj.hUVMGenerator.generateUVMScripts;
        end
    end
end