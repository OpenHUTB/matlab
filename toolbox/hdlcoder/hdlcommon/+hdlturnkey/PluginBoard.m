


classdef PluginBoard<hdlturnkey.plugin.PluginBaseWithInterface



    properties


        BoardName='';


        FPGAVendor='';
        FPGAFamily='';
        FPGADevice='';
        FPGAPackage='';
        FPGASpeed='';

    end

    properties(Hidden=true)


        isSupported=true;


        RequiredTool={};
        RequiredToolVersion={};


        DefaultIOPadConstrain={};




        TopLevelNamePostfix='';


        AttachConstrainFile='';


        ConstrainFileNamePostfix='';
        PinAssignFileNamePostfix='';


        hClockModule=[];


        hDeviceConfig=[];


        isxPCBoard=false;
        xPCSetupBlkPath='';
        xPCSetupBlkBoardID='';
        xPCPCIReadBlkPath='';
        xPCPCIWriteBlkPath='';
        xPCPCIRWBlkPath='';
        xPCModelGenMaskDisp='FPGA Board';
        xPCModelGenMaskType='FPGA Board Interface Block';


        PostSWInterfaceFcn=[];

    end

    methods

        function obj=PluginBoard()

        end

        function validateBoard(~)
        end



    end

    methods(Static)

        function plugin=loadPluginFile(pluginPackage,pluginName)

            cmdStr=sprintf('%s.%s',pluginPackage,pluginName);

            plugin=eval(cmdStr);
        end

    end

end

