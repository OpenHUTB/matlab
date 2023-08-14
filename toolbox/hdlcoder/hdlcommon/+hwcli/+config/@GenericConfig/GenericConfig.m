


classdef GenericConfig<hwcli.base.GenericBase






    properties

RunTaskGenerateRTLCodeAndTestbench
RunTaskVerifyWithHDLCosimulation
RunTaskAnnotateModelWithSynthesisResult


GenerateRTLCode
GenerateTestbench
GenerateValidationModel
SkipPreRouteTimingAnalysis
IgnorePlaceAndRouteErrors
CriticalPathSource
CriticalPathNumber
ShowAllPaths
ShowDelayData
ShowUniquePaths
ShowEndsOnly
    end

    properties(Hidden=true)


GenerateRTLTestbench
GenerateCosimulationModel
CosimulationModelForUseWith
    end





    methods
        function obj=GenericConfig(tool)
            obj=obj@hwcli.base.GenericBase('Generic ASIC/FPGA',tool);


            obj.RunTaskGenerateRTLCodeAndTestbench=true;
            obj.RunTaskVerifyWithHDLCosimulation=false;
            obj.RunTaskAnnotateModelWithSynthesisResult=true;
            obj.GenerateRTLCode=true;
            obj.GenerateTestbench=false;
            obj.GenerateValidationModel=false;
            obj.SkipPreRouteTimingAnalysis=false;
            obj.IgnorePlaceAndRouteErrors=false;
            obj.CriticalPathSource='pre-route';
            obj.CriticalPathNumber=1;
            obj.ShowAllPaths=false;
            obj.ShowDelayData=true;
            obj.ShowUniquePaths=false;
            obj.ShowEndsOnly=false;


            if(strcmp(tool,'Xilinx Vivado'))
                obj.Tasks={...
                'RunTaskGenerateRTLCodeAndTestbench',...
                'RunTaskVerifyWithHDLCosimulation',...
                'RunTaskCreateProject',...
                'RunTaskRunSynthesis',...
                'RunTaskRunImplementation',...
                'RunTaskAnnotateModelWithSynthesisResult'};
            elseif(strcmp(tool,'Microchip Libero SoC'))
                obj.Tasks={...
                'RunTaskGenerateRTLCodeAndTestbench',...
                'RunTaskVerifyWithHDLCosimulation',...
                'RunTaskCreateProject',...
                'RunTaskRunSynthesis',...
                'RunTaskRunImplementation',...
                };
            elseif(strcmp(tool,'Intel Quartus Pro'))
                obj.RunTaskAnnotateModelWithSynthesisResult=false;
                obj.Tasks={...
                'RunTaskGenerateRTLCodeAndTestbench',...
                'RunTaskVerifyWithHDLCosimulation',...
                'RunTaskCreateProject',...
                'RunTaskPerformLogicSynthesis',...
                'RunTaskPerformMapping',...
                'RunTaskPerformPlaceAndRoute'};

            else
                obj.Tasks={...
                'RunTaskGenerateRTLCodeAndTestbench',...
                'RunTaskVerifyWithHDLCosimulation',...
                'RunTaskCreateProject',...
                'RunTaskPerformLogicSynthesis',...
                'RunTaskPerformMapping',...
                'RunTaskPerformPlaceAndRoute',...
                'RunTaskAnnotateModelWithSynthesisResult'};

            end

            obj.Properties(...
            'RunTaskGenerateRTLCodeAndTestbench')={...
            'GenerateRTLCode',...
            'GenerateTestbench',...
            'GenerateValidationModel'};

            obj.Properties(...
            'RunTaskAnnotateModelWithSynthesisResult')=...
            {'CriticalPathSource',...
            'CriticalPathNumber',...
'ShowAllPaths'...
            ,'ShowDelayData',...
'ShowUniquePaths'...
            ,'ShowEndsOnly'};

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

        function set.RunTaskAnnotateModelWithSynthesisResult(obj,val)
            obj.errorCheckTask('RunTaskAnnotateModelWithSynthesisResult',val);
            obj.RunTaskAnnotateModelWithSynthesisResult=val;
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

        function set.GenerateRTLTestbench(~,~)
            error(message('hdlcoder:workflow:ParameterDepricated','GenerateRTLTestbench'));
        end

        function val=get.GenerateRTLTestbench(obj)%#ok<MANU,STOUT>
            error(message('hdlcoder:workflow:ParameterDepricated','GenerateRTLTestbench'));
        end


        function set.GenerateCosimulationModel(~,~)
            error(message('hdlcoder:workflow:ParameterDepricated','GenerateCosimulationModel'));
        end

        function val=get.GenerateCosimulationModel(obj)%#ok<MANU,STOUT>
            error(message('hdlcoder:workflow:ParameterDepricated','GenerateCosimulationModel'));
        end

        function set.CosimulationModelForUseWith(~,~)
            error(message('hdlcoder:workflow:ParameterDepricated','CosimulationModelForUseWith'));
        end

        function val=get.CosimulationModelForUseWith(obj)%#ok<MANU,STOUT>
            error(message('hdlcoder:workflow:ParameterDepricated','CosimulationModelForUseWith'));
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

        function set.SkipPreRouteTimingAnalysis(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                obj.SkipPreRouteTimingAnalysis=true;
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.SkipPreRouteTimingAnalysis=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','SkipPreRouteTimingAnalysis'));
            end
        end

        function set.IgnorePlaceAndRouteErrors(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                obj.IgnorePlaceAndRouteErrors=true;
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.IgnorePlaceAndRouteErrors=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','IgnorePlaceAndRouteErrors'));
            end
        end

        function set.CriticalPathSource(obj,val)
            if(~ischar(val))
                error(message('hdlcoder:workflow:ParamValueNotString','CosimulationModelForUseWith'));
            else
                downstream.tool.checkNonASCII(val,'CriticalPathSource');
            end

            if(strcmp(val,'pre-route'))
                obj.CriticalPathSource='pre-route';
            elseif(strcmp(val,'post-route'))
                obj.CriticalPathSource='post-route';
            else
                error(message('hdlcoder:workflow:InvalidPathSource',val));
            end
        end

        function set.CriticalPathNumber(obj,val)

            if(ischar(val))
                downstream.tool.checkNonASCII(val,'CriticalPathNumber');
                val=str2double(val);
            end
            if(isnumeric(val)&&(val==1||val==2||val==3))
                obj.CriticalPathNumber=val;
            else
                error(message('hdlcoder:workflow:InvalidPathNumber',val));
            end
        end

        function set.ShowAllPaths(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                obj.ShowAllPaths=true;
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.ShowAllPaths=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','ShowAllPaths'));
            end
        end

        function set.ShowDelayData(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                obj.ShowDelayData=true;
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.ShowDelayData=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','ShowDelayData'));
            end
        end

        function set.ShowUniquePaths(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                obj.ShowUniquePaths=true;
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.ShowUniquePaths=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','ShowUniquePaths'));
            end
        end

        function set.ShowEndsOnly(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                obj.ShowEndsOnly=true;
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.ShowEndsOnly=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','ShowEndsOnly'));
            end
        end

    end
end


