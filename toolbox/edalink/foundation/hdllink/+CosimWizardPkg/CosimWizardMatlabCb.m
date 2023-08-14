

classdef CosimWizardMatlabCb<handle
    properties
        CbCmd='matlabcp';
        HdlComp='';
        TriggerMode=0;
        TriggerSignal='';
        Period='10';
        MfuncName='';
        FullCmd='';
    end
    methods
        function this=CosimWizardMatlabCb(CbCmd,HdlComp,TriggerMode,Period,TriggerSignal,MfuncName)

            this.CbCmd=CbCmd;
            this.HdlComp=HdlComp;
            this.TriggerMode=TriggerMode;
            this.Period=Period;
            this.TriggerSignal=TriggerSignal;

            assert(~isempty(HdlComp),'The HDL Component cannot be empty.');
            assert(~isempty(MfuncName),'The MATLAB callback function name cannot be empty.');

            if(isempty(regexp(MfuncName,'.m\s{0,}$','once')))

                this.MfuncName=[regexprep(MfuncName,'\s+$',''),'.m'];
            else

                this.MfuncName=regexprep(MfuncName,'\s+$','');
            end
            switch(TriggerMode)
            case 0
                PeriodNum=str2double(Period);
                assert(~isnan(PeriodNum),'Invalid sample time. It must be a valid number.');
                ScheduleCmd=[Period,' ns -repeat ',Period,' ns'];
            case{1,2,3}
                assert(~isempty(TriggerSignal),'The trigger signal cannot be empty.');

                allTriggerModes={'-rising','-falling','-sensitivity'};
                ScheduleCmd=[allTriggerModes{TriggerMode},' ',TriggerSignal];
            otherwise
                error('Invalid trigger mode %s',num2str(TriggerMode));
            end
            this.FullCmd=[this.CbCmd,' ',this.HdlComp,' ',ScheduleCmd];
            this.FullCmd=[this.FullCmd,' -mfunc ',this.MfuncName,' -use_instance_obj'];
        end

    end
end


