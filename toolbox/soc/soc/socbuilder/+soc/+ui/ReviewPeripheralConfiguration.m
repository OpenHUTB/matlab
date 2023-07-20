classdef ReviewPeripheralConfiguration<soc.ui.TemplateBaseWithSteps






    properties
Description
ViewOrEdit
ViewOrEditLabel
    end

    properties(Access='protected')
periphObj
    end

    methods
        function this=ReviewPeripheralConfiguration(varargin)
            this@soc.ui.TemplateBaseWithSteps(varargin{:});


            this.Description=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.ViewOrEditLabel=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.ViewOrEdit=matlab.hwmgr.internal.hwsetup.Button.getInstance(this.ContentPanel);


            this.setCurrentStep(1);
            this.Title.Text=message('soc:workflow:PeripheralConfig_Title').getString();

            this.Description.Text='';
            this.Description.shiftVertically(180);
            this.Description.addWidth(350);
            this.Description.addHeight(100);
            this.Description.Text=message('soc:workflow:PeripheralConfig_Description').getString();

            this.ViewOrEditLabel.Text=message('soc:workflow:PeripheralConfig_ViewEditText').getString();
            this.ViewOrEditLabel.addWidth(350);
            this.ViewOrEditLabel.Position(2)=this.Description.Position(2)-this.Description.Position(4);
            this.ViewOrEditLabel.shiftVertically(130);

            this.ViewOrEdit.Text='';
            this.ViewOrEdit.Visible='off';
            this.ViewOrEdit.Tag='soc_workflow_ReviewPeripheralConfig_ViewOrEdit';
            this.ViewOrEdit.Position(1)=350;
            this.ViewOrEdit.addHeight(2);
            this.ViewOrEdit.Position(2)=this.ViewOrEditLabel.Position(2)+3;
            this.ViewOrEdit.Color=matlab.hwmgr.internal.hwsetup.util.Color.MWBLUE;
            this.ViewOrEdit.FontColor=matlab.hwmgr.internal.hwsetup.util.Color.WHITE;
            this.ViewOrEdit.ButtonPushedFcn=@this.openPeripheralConfigAppCB;
            this.ViewOrEdit.Text=message('soc:workflow:PeripheralConfig_ViewEditButton').getString();

            this.NextButton.Enable='off';
            this.NextButton.Tag='soc_workflow_ReviewPeripheralConfig_Next';

            this.HelpText.WhatToConsider='';
            this.HelpText.AboutSelection='';

            this.HelpText.WhatToConsider=message('soc:workflow:PeripheralConfig_WhatToConsider').getString();

            this.ViewOrEdit.Visible='on';
            this.NextButton.Enable='on';
        end

        function screen=getNextScreenID(this)
            if isequal(this.Workflow.ModelType,this.Workflow.SocFpga)
                screen='soc.ui.ReviewMemoryMap';
            else
                screen='soc.ui.SelectProjectFolder';
            end
        end

        function screen=getPreviousScreenID(~)
            screen='soc.ui.ModelInfo';
        end
    end

    methods(Access=private)
        function timerCb(this,~,~)
            if isvalid(this)&&isvalid(this.NextButton)
                view=codertarget.peripherals.AppView.getInstance();
                if view.isAppOpen()
                    stopTimer=false;
                else
                    this.NextButton.Enable='on';
                    stopTimer=true;
                end
            else
                stopTimer=true;
            end

            if stopTimer
                t=timerfind('Name','PeripheralConfigAppOpenTimer');
                stop(t);
                delete(t);
                this.Workflow.Window.bringToFront();
            end
        end

        function openPeripheralConfigAppCB(this,~,~)

            if~bdIsLoaded(this.Workflow.sys)
                load_system(this.Workflow.sys);
            end
            this.NextButton.Enable='off';

            hCS=getActiveConfigSet(this.Workflow.sys);
            codertarget.peripherals.utils.openPeripheralConfiguration(hCS);

            timerName='PeripheralConfigAppOpenTimer';
            t=timerfind('Name',timerName);
            if isempty(t)
                t=timer('Name',timerName,...
                'Period',1,...
                'StartDelay',1,...
                'TasksToExecute',inf,...
                'ExecutionMode','fixedSpacing',...
                'TimerFcn',@this.timerCb);
                start(t);
            end
        end
    end
end
