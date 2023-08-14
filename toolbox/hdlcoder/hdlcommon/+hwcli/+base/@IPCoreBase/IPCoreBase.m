




classdef IPCoreBase<hwcli.base.WorkflowBase





    properties(Hidden)

AddLinuxDeviceDriver
GenerateIPCoreTestbench
CustomIPTopHDLFile
ReportTimingFailure
ReportTimingFailureTolerance
    end





    properties(Hidden,Transient)

RunTaskGenerateSoftwareInterfaceModel
    end

    properties

RunTaskGenerateRTLCodeAndIPCore
RunTaskGenerateSoftwareInterface
RunTaskBuildFPGABitstream


ReferenceDesignToolVersion
IgnoreToolVersionMismatch
IPCoreRepository
IPDataCaptureBufferSize

GenerateIPCoreReport
HostTargetInterface
GenerateHostInterfaceModel
GenerateHostInterfaceScript
GenerateSoftwareInterfaceScript
GenerateSoftwareInterfaceModel
OperatingSystem
RunExternalBuild
DefaultCheckpointFile
EnableDesignCheckpoint
MaxNumOfCoresForBuild
TclFileForSynthesisBuild
CustomBuildTclFile
RoutedDesignCheckpointFilePath
EnableIPCaching
    end





    methods
        function obj=IPCoreBase(workflow,tool)
            obj=obj@hwcli.base.WorkflowBase(workflow,tool);
            isVivado=strcmp(tool,'Xilinx Vivado');
            isALteraSoC=strcmp(tool,'Altera QUARTUS II');
            isIntelQuartus=strcmp(tool,'Intel Quartus Pro');
            isXilinxISE=strcmp(tool,'Xilinx ISE');


            obj.RunTaskGenerateRTLCodeAndIPCore=true;
            obj.RunTaskGenerateSoftwareInterfaceModel=true;
            obj.RunTaskGenerateSoftwareInterface=true;
            obj.RunTaskBuildFPGABitstream=true;
            obj.ReferenceDesignToolVersion='';
            obj.IgnoreToolVersionMismatch=false;
            obj.IPCoreRepository='';
            obj.GenerateIPCoreReport=true;
            if isVivado||isALteraSoC||isIntelQuartus||isXilinxISE
                obj.GenerateSoftwareInterfaceModel=true;
                obj.GenerateHostInterfaceScript=true;
            else

                obj.GenerateSoftwareInterfaceModel=false;
                obj.GenerateHostInterfaceScript=false;
            end
            obj.GenerateHostInterfaceModel=false;
            obj.OperatingSystem='';
            obj.HostTargetInterface='';
            obj.RunExternalBuild=true;
            obj.TclFileForSynthesisBuild=hdlcoder.BuildOption.Default;
            obj.CustomBuildTclFile='';
            obj.EnableIPCaching=false;
            obj.GenerateIPCoreTestbench=false;
            obj.CustomIPTopHDLFile='';
            obj.ReportTimingFailure=hdlcoder.ReportTiming.Error;
            obj.ReportTimingFailureTolerance=0;
            if isVivado
                obj.DefaultCheckpointFile='Default';
                obj.RoutedDesignCheckpointFilePath='';
                obj.EnableDesignCheckpoint=false;
                obj.MaxNumOfCoresForBuild='synthesis tool default';
            end


            p=obj.Properties('TopLevelTasks');
            p{end+1}='ReferenceDesignToolVersion';
            p{end+1}='IgnoreToolVersionMismatch';
            obj.Properties('TopLevelTasks')=p;


            if strcmp(obj.SynthesisTool,'Xilinx Vivado')
                p=obj.Properties('RunTaskCreateProject');
                p{end+1}='EnableIPCaching';
                obj.Properties('RunTaskCreateProject')=p;
            end


            obj.Properties(...
            'RunTaskGenerateRTLCodeAndIPCore')=...
            {'IPCoreRepository',...
            'GenerateIPCoreReport',...
            'GenerateIPCoreTestbench',...
            'CustomIPTopHDLFile'};
            obj.Properties(...
            'RunTaskGenerateSoftwareInterface')=...
            {'GenerateSoftwareInterfaceModel',...
            'OperatingSystem',...
            'HostTargetInterface',...
            'GenerateHostInterfaceModel',...
            'GenerateHostInterfaceScript'};
            if isVivado
                obj.Properties(...
                'RunTaskBuildFPGABitstream')=...
                {'RunExternalBuild',...
                'EnableDesignCheckpoint',...
                'TclFileForSynthesisBuild',...
                'CustomBuildTclFile',...
                'DefaultCheckpointFile',...
                'RoutedDesignCheckpointFilePath',...
                'MaxNumOfCoresForBuild',...
                'ReportTimingFailureTolerance',...
                'ReportTimingFailure'};
            else
                obj.Properties(...
                'RunTaskBuildFPGABitstream')=...
                {'RunExternalBuild',...
                'TclFileForSynthesisBuild',...
                'CustomBuildTclFile',...
                'ReportTimingFailureTolerance',...
                'ReportTimingFailure'};
            end


            obj.HiddenProperties('GenerateIPCoreTestbench')=true;
            obj.HiddenProperties('CustomIPTopHDLFile')=true;
            obj.HiddenProperties('ReportTimingFailure')=true;
            obj.HiddenProperties('ReportTimingFailureTolerance')=true;

        end
    end





    methods
        function set.RunTaskGenerateRTLCodeAndIPCore(obj,val)
            obj.errorCheckTask('RunTaskGenerateRTLCodeAndIPCore',val);
            obj.RunTaskGenerateRTLCodeAndIPCore=val;
        end

        function set.RunTaskGenerateSoftwareInterface(obj,val)
            obj.errorCheckTask('RunTaskGenerateSoftwareInterface',val);
            obj.RunTaskGenerateSoftwareInterface=val;
        end

        function set.RunTaskGenerateSoftwareInterfaceModel(obj,val)



            if(strcmp(val,'On')||(islogical(val)&&val==true))
                if strcmp(obj.SynthesisTool,'Microchip Libero SoC')
                    obj.RunTaskGenerateSoftwareInterface=false;
                    obj.GenerateSoftwareInterfaceModel=false;
                    obj.RunTaskGenerateSoftwareInterfaceModel=false;
                else
                    obj.RunTaskGenerateSoftwareInterface=true;
                    obj.GenerateSoftwareInterfaceModel=true;
                    obj.RunTaskGenerateSoftwareInterfaceModel=true;
                end
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))






                obj.RunTaskGenerateSoftwareInterface=false;
                obj.GenerateSoftwareInterfaceModel=false;
                obj.RunTaskGenerateSoftwareInterfaceModel=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','RunTaskGenerateSoftwareInterfaceModel'));
            end
        end

        function set.RunTaskBuildFPGABitstream(obj,val)
            obj.errorCheckTask('RunTaskBuildFPGABitstream',val);
            obj.RunTaskBuildFPGABitstream=val;
        end

        function set.TclFileForSynthesisBuild(obj,val)
            if(~isa(val,'hdlcoder.BuildOption'))
                error(message('hdlcoder:workflow:InvalidBuildOption'));
            end
            obj.TclFileForSynthesisBuild=val;
        end

        function set.DefaultCheckpointFile(obj,val)
            if(~ischar(val))
                error(message('hdlcoder:workflow:ParamValueNotString','DefaultCheckpointFile'));
            else
                downstream.tool.checkNonASCII(val,'DefaultCheckpointFile');
            end
            obj.DefaultCheckpointFile=val;
        end

        function set.ReportTimingFailure(obj,val)
            if(~isa(val,'hdlcoder.ReportTiming'))
                error(message('hdlcoder:workflow:InvalidReportTiming'));
            end
            obj.ReportTimingFailure=val;
        end

        function set.ReportTimingFailureTolerance(obj,val)
            obj.ReportTimingFailureTolerance=val;
        end

        function set.CustomBuildTclFile(obj,val)
            if(~ischar(val))
                error(message('hdlcoder:workflow:ParamValueNotString','CustomBuildTclFile'));
            else
                downstream.tool.checkNonASCII(val,'CustomBuildTclFile');
            end
            obj.CustomBuildTclFile=val;
        end

        function set.RoutedDesignCheckpointFilePath(obj,val)
            if(~ischar(val))
                error(message('hdlcoder:workflow:ParamValueNotString','RoutedDesignCheckpointFilePath'));
            else
                downstream.tool.checkNonASCII(val,'RoutedDesignCheckpointFilePath');
            end
            obj.RoutedDesignCheckpointFilePath=val;
        end

        function set.MaxNumOfCoresForBuild(obj,val)
            if(~ischar(val))
                error(message('hdlcoder:workflow:ParamValueNotString','MaxNumOfCoresForBuild'));
            else
                downstream.tool.checkNonASCII(val,'MaxNumOfCoresForBuild');
            end
            obj.MaxNumOfCoresForBuild=val;
        end

        function set.ReferenceDesignToolVersion(obj,val)
            if(~ischar(val))
                error(message('hdlcoder:workflow:ParamValueNotString','ReferenceDesignToolVersion'));
            else
                downstream.tool.checkNonASCII(val,'ReferenceDesignToolVersion');
            end
            obj.ReferenceDesignToolVersion=val;
        end

        function set.IgnoreToolVersionMismatch(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                obj.IgnoreToolVersionMismatch=true;
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.IgnoreToolVersionMismatch=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','IgnoreToolVersionMismatch'));
            end
        end

        function set.IPCoreRepository(obj,val)
            if(~ischar(val))
                error(message('hdlcoder:workflow:ParamValueNotString','IPCoreRepository'));
            else
                downstream.tool.checkNonASCII(val,'IPCoreRepository');
            end
            obj.IPCoreRepository=val;
        end

        function set.GenerateIPCoreReport(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                obj.GenerateIPCoreReport=true;
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.GenerateIPCoreReport=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','GenerateIPCoreReport'));
            end
        end

        function set.GenerateSoftwareInterfaceModel(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                if~strcmp(obj.SynthesisTool,'Microchip Libero SoC')
                    obj.GenerateSoftwareInterfaceModel=true;
                else
                    error(message('hdlcommon:workflow:HostInterfaceModelGenerationCLI',obj.SynthesisTool));
                end
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.GenerateSoftwareInterfaceModel=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','GenerateSoftwareInterfaceModel'));
            end
        end

        function set.GenerateHostInterfaceScript(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                if~strcmp(obj.SynthesisTool,'Microchip Libero SoC')
                    obj.GenerateHostInterfaceScript=true;
                else
                    error(message('hdlcommon:workflow:HostInterfaceScriptGenerationCLI',obj.SynthesisTool));
                end
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.GenerateHostInterfaceScript=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','GenerateHostInterfaceScript'));
            end
        end


        function set.GenerateSoftwareInterfaceScript(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                obj.GenerateHostInterfaceScript=true;
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.GenerateHostInterfaceScript=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','GenerateHostInterfaceScript'));
            end
        end

        function set.GenerateHostInterfaceModel(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                if~strcmp(obj.SynthesisTool,'Microchip Libero SoC')
                    obj.GenerateHostInterfaceModel=true;
                else
                    error(message('hdlcommon:workflow:HostInterfaceModelGenerationCLI',obj.SynthesisTool));
                end
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.GenerateHostInterfaceModel=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','GenerateHostInterfaceModel'));
            end
        end

        function set.OperatingSystem(obj,val)
            if(~ischar(val))
                error(message('hdlcoder:workflow:ParamValueNotString','OperatingSystem'));
            else
                downstream.tool.checkNonASCII(val,'OperatingSystem');
            end
            obj.OperatingSystem=val;
        end

        function set.HostTargetInterface(obj,val)
            if(~ischar(val))
                error(message('hdlcoder:workflow:ParamValueNotString','HostTargetInterface'));
            else
                downstream.tool.checkNonASCII(val,'HostTargetInterface');
            end
            obj.HostTargetInterface=val;
        end


        function set.RunExternalBuild(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                obj.RunExternalBuild=true;
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.RunExternalBuild=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','RunExternalBuild'));
            end
        end

        function set.EnableDesignCheckpoint(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                if strcmp(obj.SynthesisTool,'Xilinx Vivado')
                    obj.EnableDesignCheckpoint=true;
                else
                    error(message('hdlcommon:workflow:DesignCheckPointCLI',obj.SynthesisTool));
                end
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.EnableDesignCheckpoint=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','EnableDesignCheckpoint'));
            end
        end

        function set.EnableIPCaching(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                if strcmp(obj.SynthesisTool,'Xilinx Vivado')
                    obj.EnableIPCaching=true;
                else
                    error(message('hdlcommon:workflow:VivadoToolGtr20154',obj.SynthesisTool,char(8)));
                end
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.EnableIPCaching=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','EnableIPCaching'));
            end
        end

        function set.GenerateIPCoreTestbench(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                obj.GenerateIPCoreTestbench=true;
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.GenerateIPCoreTestbench=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','GenerateIPCoreTestbench'));
            end
        end




        function set.AddLinuxDeviceDriver(~,~)
            warning(message('hdlcoder:workflow:ParameterDepricated','AddLinuxDeviceDriver'));
            warning(message('hdlcoder:workflow:AddLinuxDeviceDriverDepricated'));
        end

    end
end


