function applySUTSettings(this)






    set_params={};
    if(this.SimIn.OverrideSILPILMode)

        this.RunTestCfg.SimulationInput=coder.internal.GetOverridenSimulationModes(this.RunTestCfg.SimulationInput);
    end

    if(this.SimIn.IsStartTimeEnabled)
        set_params=[set_params,'StartTime',num2str(this.SimIn.StartTime)];
    end

    if(this.SimIn.IsInitialStateEnabled)
        set_params=[set_params,'LoadInitialState','on'];
        set_params=[set_params,'InitialState',this.SimIn.InitialState];
    end

    if~isempty(this.SimIn.InputType)&&...
        this.SimIn.InputType==stm.internal.InputTypes.Sldv&&...
        ~isempty(this.SimIn.StopTime)
        set_params=[set_params,'StopTime',num2str(this.SimIn.StopTime)];
    elseif(this.SimIn.IsStopTimeEnabled)
        set_params=[set_params,'StopTime',num2str(this.SimIn.StopTime)];
    end

    if(this.SimIn.GenerateReport)
        set_params=[set_params,'GenerateReport','on'];
    end

    overrideSimMode(this);

    if(~isempty(set_params))

        this.RunTestCfg.SimulationInput=this.RunTestCfg.SimulationInput.setModelParameter(set_params{:});
    end

end

function overrideSimMode(this)
    [simMode,blockOrModelName]=this.RunTestCfg.getSimMode(this.SimIn,this.SimWatcher);
    if strlength(simMode)>0

        hInfo='';
        functionInterfaceName='';
        isSILPILMode=string(simMode).contains(["Software","Processor"],"IgnoreCase",true);
        if~isempty(this.SimWatcher.harnessName)
            hInfo=Simulink.harness.find(this.SimWatcher.ownerName,'Name',this.SimWatcher.harnessName);


            if isfield(hInfo,'functionInterfaceName')
                functionInterfaceName=hInfo.functionInterfaceName;
            end
        end
        if isSILPILMode&&...
            ~isempty(hInfo)&&~isempty(functionInterfaceName)

            simIn=this.RunTestCfg.SimulationInput.setModelParameter(...
            'CodeVerificationMode',simMode);
            this.SimWatcher.NeedSubsystemManager=true;
        elseif isSILPILMode&&...
            ~isempty(hInfo)&&isequal(hInfo.ownerType,'Simulink.SubSystem')
            [isSupported,errmsg]=stm.internal.util.isSupportedAtomicSS(hInfo.ownerFullPath);
            this.SimWatcher.NeedSubsystemManager=isSupported;
            if isSupported

                simIn=this.RunTestCfg.SimulationInput.setModelParameter(...
                'CodeVerificationMode',simMode);


                simModeIdx={simIn.ModelParameters.Name}=="SimulationMode";
                simIn.ModelParameters(simModeIdx)=[];
            else
                if~isempty(errmsg)

                    rtw.pil.SubsystemManager.reportWarningsAndErrors(errmsg,[]);
                end
            end
        elseif isequal(bdroot(blockOrModelName),blockOrModelName)
            simIn=this.RunTestCfg.SimulationInput.setModelParameter(...
            'SimulationMode',simMode);
        else
            simIn=this.RunTestCfg.SimulationInput.setBlockParameter(...
            blockOrModelName,'SimulationMode',simMode);



            if(~isempty(simIn.HarnessName)&&isSILPILMode&&...
                Simulink.CodeMapping.isMappedToAutosarComponent(simIn.ModelName))
                simIn=simIn.setBlockParameter(blockOrModelName,'CodeInterface','Top Model');
            end
        end
        this.RunTestCfg.SimulationInput=simIn;
    end
end
