classdef ModelReference<fixed.internal.simulationmodehandler.Model




    properties(SetAccess=private,GetAccess=public)
OriginalFastRestartSetting
CurrentFastRestartSetting

OriginalSignalLoggingMode

OriginalDirtyFlag

OriginalFPTRunName

OriginalInstrumentationMode
CurrentInstrumentationMode
    end


    methods

        function this=ModelReference(name)
            this.Name=name;
            this.initialize();
        end

        function restoreDirtyFlag(this)
            set_param(this.Name,'dirty',this.OriginalDirtyFlag)
        end

        function restoreRunName(this)
            set_param(this.Name,'FPTRunName',this.OriginalFPTRunName)
        end

        function restoreFastRestart(this)


            set_param(this.Name,'FastRestart',this.OriginalFastRestartSetting);
            this.CurrentFastRestartSetting=this.OriginalFastRestartSetting;
        end

        function switchFastRestartMode(this,settingValue)


            set_param(this.Name,'FastRestart',settingValue);
            this.CurrentFastRestartSetting=settingValue;

            this.restoreDirtyFlag();
        end

        function switchSimulationMode(this,settingValue)


            set_param(this.Name,'SimulationMode',settingValue);
            this.CurrentSimulationMode=settingValue;

            this.restoreDirtyFlag();
        end

        function switchSignalLoggingMode(this,settingValue)
            this.OriginalSignalLoggingMode=get_param(this.Name,'SignalLogging');

            configSet=getActiveConfigSet(this.Name);
            configset.internal.setParam(configSet,'SignalLogging',settingValue);
        end

        function switchInstrumentationMode(this,settingValue)

            set_param(this.Name,'MinMaxOverflowLogging',settingValue);
            this.CurrentInstrumentationMode=settingValue;
        end

        function restoreInstrumentationMode(this)

            this.switchInstrumentationMode(this.OriginalInstrumentationMode);
        end

        function restoreSignalLoggingMode(this)

            configSet=getActiveConfigSet(this.Name);
            configset.internal.setParam(configSet,'SignalLogging',this.OriginalSignalLoggingMode);
        end

    end

    methods(Access={?fixed.internal.simulationmodehandler.Model,?ModeHandlerTestCase})
        function initialize(this)

            this.setOriginalSimulationMode();
            this.setOriginalDirtyFlag();
            this.setOriginalFastRestartSetting();
            this.setOriginalFPTRunName();
            this.setOriginalInstrumenationMode();
            this.setOriginalSignalLoggingMode();
        end

        function setOriginalDirtyFlag(this)

            this.OriginalDirtyFlag=get_param(this.Name,'dirty');
        end

        function setOriginalFastRestartSetting(this)

            this.OriginalFastRestartSetting=get_param(this.Name,'FastRestart');
            this.CurrentFastRestartSetting=this.OriginalFastRestartSetting;
        end

        function setOriginalInstrumenationMode(this)

            this.OriginalInstrumentationMode=get_param(this.Name,'MinMaxOverflowLogging');
            this.CurrentInstrumentationMode=this.OriginalInstrumentationMode;
        end

        function setOriginalFPTRunName(this)

            this.OriginalFPTRunName=get_param(this.Name,'FPTRunName');
        end

        function setOriginalSignalLoggingMode(this)

            this.OriginalSignalLoggingMode=get_param(this.Name,'SignalLogging');
        end
    end
end

