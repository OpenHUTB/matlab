

classdef PassReset<CosimWizardPkg.StepBase
    methods
        function obj=PassReset(WizardData)
            obj=obj@CosimWizardPkg.StepBase(WizardData);
        end

        function WidgetGroup=getDialogSchema(this)
            selectTimeUnit=getHdlTimeUnitName(this.Wizard.UserData);


            RunTime.Type='edit';
            RunTime.Name=['HDL time to start cosimulation (',selectTimeUnit,'):'];
            RunTime.Tag='edaRunTime';
            RunTime.RowSpan=[1,1];
            RunTime.ColSpan=[1,1];
            RunTime.Value=this.Wizard.UserData.ResetRunTimeStr;

            UpdatePlot.Type='pushbutton';
            UpdatePlot.Name='Update Diagram';
            UpdatePlot.Tag='edaUpdatePlot';
            UpdatePlot.RowSpan=[1,1];
            UpdatePlot.ColSpan=[2,2];
            UpdatePlot.ObjectMethod='onUpdatePlot';
            UpdatePlot.MethodArgs={'%dialog'};
            UpdatePlot.ArgDataTypes={'handle'};


            Waveform.Type='image';
            Waveform.Name='Waveform';
            Waveform.Tag='edaWaveform';
            Waveform.FilePath=this.Wizard.UserData.WaveformFile;

            Waveform.RowSpan=[2,2];
            Waveform.ColSpan=[1,4];
            Waveform.Alignment=2;

            WidgetGroup.LayoutGrid=[2,4];
            WidgetGroup.ColStretch=[0,1,1,1];
            WidgetGroup.RowStretch=[0,1];
            WidgetGroup.Items={RunTime,UpdatePlot,Waveform};


            this.Wizard.UserData.CurrentStep=8;

        end

        function Description=getDescription(~)

            Description=[...
'The diagram below shows the current settings for forced ''Clock'' and ''Reset'' signals. '...
            ,'The red line represents the time in the HDL simulation at which MATLAB/Simulink will start '...
            ,'(i.e. cosimulation will start).',char(10),char(10)...
            ,'To change the MATLAB/Simulink start time relative to the HDL simulation time, enter the new '...
            ,'start time below. To avoid a race condition, make sure the start time does not coincide '...
            ,'with the active edge of any clock signal. You can do so by moving the start time or by '...
            ,'changing the clock active edge in the previous step (click Back).'];
        end
        function onBack(this,~)

            this.Wizard.NextStepID=7;
        end
        function EnterStep(~,~)
            return;
        end
        function onNext(this,dlg)

            runtime=getWidgetValue(this.Wizard,dlg,'edaRunTime');
            this.Wizard.UserData.ResetRunTimeStr=runtime;
            switch(this.Wizard.UserData.Workflow)
            case 'Simulink'
                this.Wizard.NextStepID=9;
            case 'MATLAB System Object'
                this.Wizard.NextStepID=12;
            end
        end
    end
end


