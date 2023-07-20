classdef CustomHWTargetHook<coder.oneclick.TargetHook








    properties(Constant)
        HardwareName='DefaultHardwareBoard';
    end

    methods

        function this=CustomHWTargetHook(varargin)
            this@coder.oneclick.TargetHook(varargin{:});
        end


        function hardwareName=getHardwareName(this)%#ok<MANU>
            hardwareName=coder.oneclick.CustomHWTargetHook.HardwareName;
        end

        function configureExternalModeSettings(this)
            forceApplicationStop=false;
            launcher=coder.oneclick.TargetLaunchersManager.getLauncher(this.ModelName,this.HardwareName,forceApplicationStop);

            if~isempty(launcher)



                launcher.extModeEnable(true);
            end
        end


        function downloadAndRunTargetExecutable(this)
            forceApplicationStop=true;
            launcher=coder.oneclick.TargetLaunchersManager.getLauncher(this.ModelName,this.HardwareName,forceApplicationStop);
            if isempty(launcher)

                DAStudio.error('Simulink:Extmode:NoTargetConnectivityConfigLauncher',this.ModelName);
            end


            Simulink.output.info(DAStudio.message(...
            'coder_sltoolstrip_base_hw:sltoolstrip_base_hw:ExtModeDeployMessage'));
            launcher.startApplication;




            launcher.extModeEnable(true);
        end
    end
end
