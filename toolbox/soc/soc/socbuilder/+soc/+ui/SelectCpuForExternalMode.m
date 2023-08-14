classdef SelectCpuForExternalMode<soc.ui.TemplateBaseWithSteps




    properties
Description
TaskManagerBlocks
CpuSelectCheckbox
    end

    methods
        function this=SelectCpuForExternalMode(varargin)
            this@soc.ui.TemplateBaseWithSteps(varargin{:});


            this.Description=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);


            this.setCurrentStep(1);
            this.Title.Text=message('soc:workflow:SelectCpuExtMode_Title').getString;


            TaskMgrBlocks=soc.internal.connectivity.getTaskManagerBlock(this.Workflow.sys);

            if~iscell(TaskMgrBlocks)
                this.TaskManagerBlocks={TaskMgrBlocks};
            else
                this.TaskManagerBlocks=TaskMgrBlocks;
            end

            ref_mdls=cellfun(@(x)soc.internal.connectivity.getModelConnectedToTaskManager(x),this.TaskManagerBlocks,'UniformOutput',false);
            ref_mdls=cellfun(@(x)get_param(x,'ModelName'),ref_mdls,'UniformOutput',false);
            refMdlsWithoutAccelerator={};
            for j=1:numel(ref_mdls)
                cs=getActiveConfigSet(ref_mdls{j});
                pu=codertarget.targethardware.getProcessingUnitInfo(cs);
                if~isempty(pu.PUAttachedTo),continue;end
                refMdlsWithoutAccelerator{end+1}=ref_mdls{j};%#ok<AGROW>
            end
            cpus=cellfun(@(x)codertarget.targethardware.getProcessingUnitName(x),refMdlsWithoutAccelerator','UniformOutput',false);


            this.Description.shiftVertically(250);
            this.Description.addWidth(350);
            this.Description.addHeight(20);
            if isempty(cpus)
                this.Description.Text=message('soc:workflow:SelectBuildAction_NoSupportedCPU').getString;
                this.NextButton.Enable='off';
                return;
            else
                this.Description.Text=message('soc:workflow:SelectCpuExtMode_Description').getString;
            end

            this.CpuSelectCheckbox=matlab.hwmgr.internal.hwsetup.CheckBoxList.getInstance(this.ContentPanel);
            this.CpuSelectCheckbox.Title=message('soc:workflow:SelectCpuExtMode_CheckboxTitle').getString();
            this.CpuSelectCheckbox.Items=cpus';
            this.CpuSelectCheckbox.ColumnWidth=[20,this.CpuSelectCheckbox.Position(3)-22];
            this.CpuSelectCheckbox.Position(1)=this.Description.Position(1);
            this.CpuSelectCheckbox.Position(2)=this.Description.Position(2)-180;


            this.CpuSelectCheckbox.Position(4)=(numel(this.CpuSelectCheckbox.Items)+1)*25;
            this.CpuSelectCheckbox.Position(2)=this.Description.Position(2)-this.CpuSelectCheckbox.Position(4)-5;

            this.CpuSelectCheckbox.ValueIndex=1:numel(cpus);
            this.CpuSelectCheckbox.ValueChangedFcn=@this.cpuSelectChangedCB;


            for i=1:numel(cpus)
                extstr=this.Workflow.ExtModelInfo(cpus{i});
                extstr.EnableExtMode=true;
                this.Workflow.ExtModelInfo(cpus{i})=extstr;
            end

            this.HelpText.WhatToConsider='';
            this.HelpText.AboutSelection=message('soc:workflow:SelectCpuExtMode_AboutSelection').getString();
            this.HelpText.Additional='';
        end

        function screen=getNextScreenID(~)
            screen='soc.ui.ExternalModeConnectivity';
        end

        function screen=getPreviousScreenID(~)
            screen='soc.ui.SelectBuildAction';
        end
    end

    methods(Access=private)
        function cpuSelectChangedCB(this,~,~)
            selectedCpus=this.CpuSelectCheckbox.Values;
            if isempty(selectedCpus)
                this.NextButton.Enable='off';
            else
                for i=1:numel(selectedCpus)
                    extstr=this.Workflow.ExtModelInfo(selectedCpus{i});
                    extstr.EnableExtMode=true;
                    this.Workflow.ExtModelInfo(selectedCpus{i})=extstr;
                end


                unselectedCpus=this.CpuSelectCheckbox.Items(~contains(this.CpuSelectCheckbox.Items,selectedCpus));
                for i=1:numel(unselectedCpus)
                    extstr=this.Workflow.ExtModelInfo(unselectedCpus{i});
                    extstr.EnableExtMode=false;
                    this.Workflow.ExtModelInfo(unselectedCpus{i})=extstr;
                end
                this.NextButton.Enable='on';
            end
        end
    end
end


