classdef ReviewMemoryMap<soc.ui.TemplateBaseWithSteps






    properties
Description
ViewOrEdit
ViewOrEditLabel
    end


    methods
        function this=ReviewMemoryMap(varargin)
            this@soc.ui.TemplateBaseWithSteps(varargin{:});


            this.Description=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.ViewOrEditLabel=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.ViewOrEdit=matlab.hwmgr.internal.hwsetup.Button.getInstance(this.ContentPanel);


            this.setCurrentStep(1);
            this.Title.Text=message('soc:workflow:ReviewMemoryMap_Title').getString();

            this.Description.Text='';
            this.Description.shiftVertically(180);
            this.Description.addWidth(350);
            this.Description.addHeight(100);

            this.ViewOrEditLabel.Text='';
            this.ViewOrEditLabel.addWidth(350);
            this.ViewOrEditLabel.Position(2)=this.Description.Position(2)-this.Description.Position(4);
            this.ViewOrEditLabel.shiftVertically(130);

            this.ViewOrEdit.Text='';
            this.ViewOrEdit.Visible='off';
            this.ViewOrEdit.Tag='soc_workflow_ReviewMemoryMap_ViewOrEdit';
            this.ViewOrEdit.Position(1)=350;
            this.ViewOrEdit.addHeight(2);
            this.ViewOrEdit.Position(2)=this.ViewOrEditLabel.Position(2)+3;
            this.ViewOrEdit.Color=matlab.hwmgr.internal.hwsetup.util.Color.MWBLUE;
            this.ViewOrEdit.FontColor=matlab.hwmgr.internal.hwsetup.util.Color.WHITE;
            this.ViewOrEdit.ButtonPushedFcn=@this.openMemoryMapAppCB;

            this.NextButton.Enable='off';
            this.NextButton.Tag='soc_workflow_ReviewMemoryMap_Next';

            this.HelpText.WhatToConsider='';
            this.HelpText.AboutSelection='';


            this.Description.Text=message('soc:workflow:ReviewMemoryMap_Description',this.getMemoryMapStatusCB).getString();
            this.ViewOrEditLabel.Text=message('soc:workflow:ReviewMemoryMap_ViewOrEditLabel').getString();
            this.ViewOrEdit.Text='View / Edit ...';
            this.HelpText.WhatToConsider=message('soc:workflow:ReviewMemoryMap_WhatToConsider').getString();

            this.ViewOrEdit.Visible='on';
            this.NextButton.Enable='on';
        end

        function screen=getNextScreenID(~)
            screen='soc.ui.SelectProjectFolder';
        end

        function screen=getPreviousScreenID(this)
            switch(this.Workflow.ModelType)
            case this.Workflow.SocFpga
                if this.Workflow.SupportsPeripherals||this.Workflow.HasEventDrivenTasks
                    screen='soc.ui.ReviewPeripheralConfiguration';
                else
                    screen='soc.ui.ModelInfo';
                end
            case this.Workflow.FpgaOnly
                screen='soc.ui.ModelInfo';
            otherwise
                assert(false,'SoC Builder model: wrong model type');
            end
        end
    end

    methods(Access=private)
        function status=getMemoryMapStatusCB(this,~,~)

            status=message('soc:workflow:ReviewMemoryMap_Status_Default').getString;
            memMap=soc.memmap.getMemoryMap(this.Workflow.sys);
            if~isempty(memMap)&&~memMap.isAutoMap
                status=message('soc:workflow:ReviewMemoryMap_Status_Custom').getString;
            end
        end

        function timerCb(this,~,~)
            stopTimer=false;
            if isvalid(this)&&isvalid(this.NextButton)

                if isempty(soc.memmap.findMemMapperDialog(this.Workflow.sys))
                    stopTimer=true;
                    this.NextButton.Enable='on';
                end
            else
                stopTimer=true;
            end

            if stopTimer
                t=timerfind('Name','MemMapAppOpenTimer');
                stop(t);
                delete(t);
            end
        end

        function openMemoryMapAppCB(this,~,~)

            if~bdIsLoaded(this.Workflow.sys)
                load_system(this.Workflow.sys);
            end
            this.NextButton.Enable='off';
            cs=getActiveConfigSet(this.Workflow.sys);
            soc.memmap.launchmap(cs.getComponent('Coder Target'));
            timerName='MemMapAppOpenTimer';
            t=timerfind('Name',timerName);
            if isempty(t)
                t=timer('Name',timerName,...
                'Period',2,...
                'StartDelay',2,...
                'TasksToExecute',inf,...
                'ExecutionMode','fixedSpacing',...
                'TimerFcn',@this.timerCb);
                start(t);
            end
            this.Description.Text=message('soc:workflow:ReviewMemoryMap_Description',this.getMemoryMapStatusCB).getString();
        end
    end
end
