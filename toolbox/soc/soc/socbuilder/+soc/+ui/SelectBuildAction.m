classdef SelectBuildAction<soc.ui.TemplateBaseWithSteps




    properties
Description
BuildActions
NextSteps
    end

    methods
        function this=SelectBuildAction(varargin)
            this@soc.ui.TemplateBaseWithSteps(varargin{:});


            this.Description=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.BuildActions=matlab.hwmgr.internal.hwsetup.RadioGroup.getInstance(this.ContentPanel);
            this.NextSteps=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);


            this.setCurrentStep(1);
            this.Title.Text=message('soc:workflow:SelectBuildAction_Title').getString();

            this.Description.Text=message('soc:workflow:SelectBuildAction_Description').getString();
            this.Description.shiftVertically(260);
            this.Description.addWidth(350);
            this.Description.addHeight(20);

            this.BuildActions.Title='';
            this.BuildActions.Items={
            message('soc:workflow:SelectBuildAction_Option1').getString(),...
            message('soc:workflow:SelectBuildAction_Option2').getString()...
            };

            if~strcmpi(this.Workflow.ModelType,'fpga')
                this.BuildActions.Items{end+1}=message('soc:workflow:SelectBuildAction_Option3').getString();
            end
            this.BuildActions.addWidth(350);
            this.BuildActions.Position(1)=40;
            this.BuildActions.shiftVertically(100);
            this.BuildActions.SelectionChangedFcn=@this.buildActionChangedCB;

            this.NextSteps.Text=message('soc:workflow:SelectBuildAction_NextSteps').getString();
            this.NextSteps.addWidth(350);
            this.NextSteps.addHeight(30);
            this.NextSteps.shiftVertically(120);

            this.HelpText.WhatToConsider='';
            this.HelpText.AboutSelection=message('soc:workflow:SelectBuildAction_AboutSelection_Option1').getString();
        end

        function screen=getNextScreenID(this)
            this.Workflow.BuildAction=this.BuildActions.ValueIndex;
            if(this.Workflow.BuildAction==this.Workflow.OpenExternalModeModel)&&...
                this.Workflow.isModelMultiCPU(this.Workflow.sys)
                screen='soc.ui.SelectCpuForExternalMode';
            else
                screen='soc.ui.ValidateModel';
            end
        end

        function screen=getPreviousScreenID(~)
            screen='soc.ui.SelectProjectFolder';
        end
    end

    methods(Access=private)
        function buildActionChangedCB(this,~,~)
            if~this.Workflow.isModelProcessorOnly(this.Workflow.sys)
                msgId=sprintf('soc:workflow:SelectBuildAction_AboutSelection_Option%d',this.BuildActions.ValueIndex);
            else
                msgId=sprintf('soc:workflow:SelectBuildAction_AboutSelection_proc_Option%d',this.BuildActions.ValueIndex);
                if isequal(this.BuildActions.ValueIndex,this.Workflow.OpenExternalModeModel)
                    this.NextSteps.Text=message('soc:workflow:SelectBuildAction_NextStepsExt').getString();
                end
            end
            this.HelpText.AboutSelection=message(msgId).getString();
        end
    end
end