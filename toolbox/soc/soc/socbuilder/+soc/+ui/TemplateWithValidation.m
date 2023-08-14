classdef TemplateWithValidation<soc.ui.TemplateBaseWithSteps








    properties
Description
StatusTable
ValidationResult
ValidationAction
    end

    methods
        function this=TemplateWithValidation(workflow)
            this@soc.ui.TemplateBaseWithSteps(workflow);


            this.Description=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.StatusTable=matlab.hwmgr.internal.hwsetup.StatusTable.getInstance(this.ContentPanel);


            this.ValidationResult=matlab.hwmgr.internal.hwsetup.StatusTable.getInstance(this.ContentPanel);
            this.ValidationAction=matlab.hwmgr.internal.hwsetup.Button.getInstance(this.ContentPanel);


            this.Title.Text='<Validation Template>';

            this.Description.shiftVertically(250);
            this.Description.addWidth(350);
            this.Description.addHeight(20);

            this.StatusTable.Position(1)=20;
            this.StatusTable.shiftVertically(-20);
            this.StatusTable.addWidth(300);
            this.StatusTable.addHeight(100);
            this.StatusTable.Position(3)=435;
            this.clearStatusTable();

            this.ValidationResult.Position=[20,60,320,120];
            this.ValidationResult.Status={''};
            this.ValidationResult.Steps={''};
            this.ValidationResult.Border='off';

            this.ValidationAction.Position=[350,this.ValidationResult.Position(2)+95,100,24];
            this.ValidationAction.Color=matlab.hwmgr.internal.hwsetup.util.Color.MWBLUE;
            this.ValidationAction.FontColor=matlab.hwmgr.internal.hwsetup.util.Color.WHITE;

            this.NextButton.Enable='off';
        end
    end

    methods(Access=protected)
        function clearStatusTable(this)
            steps=cell(1,numel(this.StatusTable.Steps));
            steps(:)={''};
            this.StatusTable.Status=steps;
        end

        function setBusy(this,step)
            if step<=numel(this.StatusTable.Steps)
                this.StatusTable.Status{step}=matlab.hwmgr.internal.hwsetup.StatusIcon.Busy;
            end
        end

        function setSuccess(this,step)
            if step<=numel(this.StatusTable.Steps)
                this.StatusTable.Status{step}=matlab.hwmgr.internal.hwsetup.StatusIcon.Pass;
            end
        end

        function setFailure(this,step)
            if step<=numel(this.StatusTable.Steps)
                this.StatusTable.Status{step}=matlab.hwmgr.internal.hwsetup.StatusIcon.Fail;
            end
        end

        function setWarn(this,step)
            if step<=numel(this.StatusTable.Steps)
                this.StatusTable.Status{step}=matlab.hwmgr.internal.hwsetup.StatusIcon.Warn;
            end
        end

        function setValidationStatus(this,status,statusText)
            this.ValidationAction.Enable='on';
            switch(status)
            case 'busy'
                statusIcon=matlab.hwmgr.internal.hwsetup.StatusIcon(5);
                this.ValidationAction.Enable='off';
            case 'pass'
                statusIcon=matlab.hwmgr.internal.hwsetup.StatusIcon(1);
            case 'fail'
                statusIcon=matlab.hwmgr.internal.hwsetup.StatusIcon(0);
            case 'warn'
                statusIcon=matlab.hwmgr.internal.hwsetup.StatusIcon(2);
            end
            this.ValidationResult.Status={statusIcon};
            this.ValidationResult.Steps={statusText};
        end
    end
end