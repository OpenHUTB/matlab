


classdef FILConfig<hwcli.base.FILBase&hwcli.base.DeployBase






    properties

        RunTaskGenerateRTLCodeAndTestbench;
        RunTaskVerifyWithHDLCosimulation;
        RunTaskBuildFPGAInTheLoop;


GenerateRTLCode
GenerateTestbench
GenerateValidationModel


        IPAddress;
        MACAddress;
        SourceFiles;
        Connection;
EnableDataBufferingOnFPGA

        RunExternalBuild=true;
    end





    methods
        function obj=FILConfig(tool)
            obj=obj@hwcli.base.FILBase('FPGA-in-the-Loop',tool);
            obj=obj@hwcli.base.DeployBase();


            obj.GenerateRTLCode=true;
            obj.GenerateTestbench=true;
            obj.GenerateValidationModel=true;

            obj.RunTaskGenerateRTLCodeAndTestbench=true;
            obj.RunTaskVerifyWithHDLCosimulation=false;
            obj.RunTaskBuildFPGAInTheLoop=true;
            obj.IPAddress='0.0.0.0';
            obj.MACAddress='00-00-00-00-00-00';
            obj.SourceFiles='';
            obj.Connection='JTAG';
            obj.EnableDataBufferingOnFPGA=true;



            obj.Tasks={...
            'RunTaskGenerateRTLCodeAndTestbench',...
            'RunTaskVerifyWithHDLCosimulation',...
            'RunTaskBuildFPGAInTheLoop'};
            obj.Properties('RunTaskGenerateRTLCodeAndTestbench')={...
            'GenerateRTLCode',...
            'GenerateTestbench',...
            'GenerateValidationModel'};
            obj.Properties('RunTaskBuildFPGAInTheLoop')=...
            {'IPAddress','MACAddress','SourceFiles',...
            'Connection','EnableDataBufferingOnFPGA','RunExternalBuild'};
        end
    end





    methods

        function set.RunTaskGenerateRTLCodeAndTestbench(obj,val)
            obj.errorCheckTask('RunTaskGenerateRTLCodeAndTestbench',val);
            obj.RunTaskGenerateRTLCodeAndTestbench=val;
        end

        function set.RunTaskVerifyWithHDLCosimulation(obj,val)
            obj.errorCheckTask('RunTaskVerifyWithHDLCosimulation',val);
            obj.RunTaskVerifyWithHDLCosimulation=val;
        end

        function set.RunTaskBuildFPGAInTheLoop(obj,val)
            obj.errorCheckTask('RunTaskBuildFPGAInTheLoop',val);
            obj.RunTaskBuildFPGAInTheLoop=val;
        end

        function set.GenerateRTLCode(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                obj.GenerateRTLCode=true;
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.GenerateRTLCode=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','GenerateRTLCode'));
            end
        end

        function set.GenerateTestbench(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                obj.GenerateTestbench=true;
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.GenerateTestbench=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','GenerateRTLCode'));
            end
        end

        function set.GenerateValidationModel(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                obj.GenerateValidationModel=true;
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.GenerateValidationModel=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','GenerateValidationModel'));
            end
        end







        function set.IPAddress(obj,val)
            if(~ischar(val))
                error(message('hdlcoder:workflow:ParamValueNotString','IPAddress'));
            else
                downstream.tool.checkNonASCII(val,'IPAddress');
            end
            obj.IPAddress=val;
        end

        function set.MACAddress(obj,val)
            if(~ischar(val))
                error(message('hdlcoder:workflow:ParamValueNotString','MACAddress'));
            else
                downstream.tool.checkNonASCII(val,'MACAddress');
            end
            obj.MACAddress=val;
        end

        function addSourceFile(obj,filePath,fileType)
            if(~ischar(filePath)||~ischar(fileType))
                error(message('hdlcoder:workflow:ParamValueNotString','SourceFiles'));
            else
                downstream.tool.checkNonASCII(filePath,'FilePath');
                downstream.tool.checkNonASCII(fileType,'FileType');
            end
            obj.SourceFiles=[obj.SourceFiles,';',filePath,';',fileType];
        end

        function set.Connection(obj,val)
            if(~ischar(val))
                error(message('hdlcoder:workflow:ParamValueNotString','Connection'));
            else
                downstream.tool.checkNonASCII(val,'Connection');
            end
            obj.Connection=val;
        end

        function set.EnableDataBufferingOnFPGA(obj,val)
            if(~islogical(val))
                error(message('hdlcoder:workflow:InvalidLogical','EnableDataBufferingOnFPGA'));
            end
            obj.EnableDataBufferingOnFPGA=val;
        end
    end
end


