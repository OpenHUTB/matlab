



classdef CosimType<CosimWizardPkg.StepBase
    methods
        function obj=CosimType(Wizard)
            obj=obj@CosimWizardPkg.StepBase(Wizard);
        end
        function WidgetGroup=getDialogSchema(this)

            Simulator.Name='HDL Simulator:';
            Simulator.Type='combobox';
            Simulator.Tag='edaSimulator';
            Simulator.RowSpan=[1,1];
            Simulator.ColSpan=[1,3];
            CosimWizardSimulator={'ModelSim','Xcelium','Vivado Simulator'};
            Simulator.Entries=CosimWizardSimulator;
            Simulator.ObjectMethod='onSimulatorChange';
            Simulator.MethodArgs={'%dialog','%value','%tag'};
            Simulator.ArgDataTypes={'handle','mxArray','string'};
            Simulator.DialogRefresh=true;
            Simulator.Value=this.Wizard.UserData.Simulator;




            Workflow.Name='HDL cosimulation with:';
            Workflow.Tag='edaWorkflow';
            Workflow.Type='combobox';
            Workflow.RowSpan=[2,2];
            Workflow.ColSpan=[1,3];
            Workflow.Entries=this.Wizard.UserData.WorkflowOptions;
            Workflow.ObjectProperty='Workflow';
            Workflow.DialogRefresh=true;
            Workflow.Mode=true;
            Workflow.Source=this.Wizard.UserData;

            PathOptions.Name='';
            PathOptions.Type='radiobutton';
            PathOptions.Tag='edaPathOptions';
            PathOptions.RowSpan=[1,1];
            PathOptions.ColSpan=[1,7];
            PathOptions.ObjectProperty='PathOpt';
            PathOptions.DialogRefresh=true;
            PathOptions.Mode=1;
            PathOptions.Source=this.Wizard.UserData;
            PathOptions.Entries={...
            'Use HDL simulator executables on the system path',...
            'Use the HDL simulator executables at the following location'};

            HdlPath.Name='HDL simulator installation path:';
            HdlPath.Tag='edaHdlPath';
            HdlPath.Type='edit';
            HdlPath.RowSpan=[2,2];
            HdlPath.ColSpan=[1,7];
            HdlPath.ObjectProperty='HdlPath';
            HdlPath.Mode=true;
            HdlPath.Source=this.Wizard.UserData;
            HdlPath.Enabled=~this.Wizard.UserData.UseSysPath;

            BrowsePath.Name='Browse';
            BrowsePath.Tag='edaBrowse';
            BrowsePath.Type='pushbutton';
            BrowsePath.ObjectMethod='onBrowseHdlPath';
            BrowsePath.MethodArgs={'%dialog'};
            BrowsePath.ArgDataTypes={'handle'};
            BrowsePath.RowSpan=[2,2];
            BrowsePath.ColSpan=[8,8];
            BrowsePath.Enabled=~this.Wizard.UserData.UseSysPath;


            PathPanel.Type='panel';
            PathPanel.Tag='edaPathPanel';
            PathPanel.Name='Use the following HDL simulator installation path';
            PathPanel.LayoutGrid=[2,8];
            PathPanel.Items={PathOptions,HdlPath,BrowsePath};
            PathPanel.RowSpan=[4,4];
            PathPanel.ColSpan=[1,7];

            Spacer=createSpacer([6,8],[1,7]);


            WidgetGroup.LayoutGrid=[8,7];
            if~isempty(this.Wizard.workflowOverride)
                WidgetGroup.Items={Simulator,PathPanel,Spacer};
            else
                WidgetGroup.Items={Simulator,Workflow,PathPanel,Spacer};
            end



            this.Wizard.UserData.CurrentStep=1;
        end
        function Description=getDescription(this)

            if~isempty(this.Wizard.workflowOverride)
                startingSentence='Select the HDL simulator to run cosimulation with. ';
            else
                startingSentence='Select the type of cosimulation you want to do. ';
            end

            Description=...
            [startingSentence,...
'If the HDL simulator executable you want to use '...
            ,'is not on the system path in your environment, '...
            ,'you must specify its location.'];
        end
        function EnterStep(~,~)
            return;
        end
        function onBack(~,~)
            return;
        end

        function onNext(this,~)

            if(strcmpi(this.Wizard.UserData.Workflow,'Simulink'))

                assert(exist('new_system','builtin')~=0,message('HDLLink:CosimWizard:SimulinkNotInstalled'));

                assert(license('test','SIMULINK')~=0,message('HDLLink:CosimWizard:NoSimulinkLicense'));
            end



            if(strcmp(this.Wizard.UserData.Simulator,this.Wizard.Simulator)==0)
                error('(internal)this should not happen since we have a callback on the widget change now')
            end




            switch(this.Wizard.Simulator)
            case 'ModelSim'
                if isunix

                    setenv('MTI_VCO_MODE','64');
                end
                cmd='vsim -version';
            case 'Xcelium'
                cmd='xmsim -ver';
            case 'Vivado Simulator'
                cmd='xelab --version';
            otherwise
                error(message('HDLLink:CosimWizard:UnknownSimulator'));
            end

            if(~this.Wizard.UserData.UseSysPath)
                assert(exist(this.Wizard.UserData.HdlPath,'dir')==7,...
                message('HDLLink:CosimWizard:InvalidPath',this.Wizard.UserData.HdlPath));
                cmd=[this.Wizard.UserData.HdlPath,filesep,cmd];
            end


            [s,~]=system(cmd);

            if(s)
                if(this.Wizard.UserData.UseSysPath)
                    this.Wizard.UserData.PathOpt=1;
                    error(message('HDLLink:CosimWizard:NotSystemOnPath'));
                else
                    error(message('HDLLink:CosimWizard:NotOnSpecifiedPath'));
                end

            end
            this.Wizard.NextStepID=2;
        end

    end
end

function widget=createSpacer(rowSpan,colSpan)
    widget.Type='panel';
    widget.Tag='edaSpacer';
    widget.RowSpan=rowSpan;
    widget.ColSpan=colSpan;
end



