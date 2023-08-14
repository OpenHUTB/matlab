function onSimulatorChange(this,dlg,val,tag)





    newVal=dlg.getComboBoxText(tag);

    if~strcmp(newVal,this.Simulator)
        switch(newVal)
        case 'ModelSim'
            newUserData=CosimWizardPkg.CosimWizardDataMQ;
        case 'Xcelium'
            newUserData=CosimWizardPkg.CosimWizardDataIN;
        case 'Vivado Simulator'
            newUserData=CosimWizardPkg.CosimWizardDataVS;
        otherwise
            error(message('HDLLink:CosimWizard:UnsupportedSimulator'));
        end
        if~any(strcmp(newUserData.WorkflowOptions,this.UserData.Workflow))
            newWorkflow=newUserData.WorkflowOptions{1};
            warning('the newly selected simulator does not support the currently selected workflow.  changing to %s',newWorkflow);




            dlg.setWidgetValue('edaWorkflow',newWorkflow);
        else
            newWorkflow=this.UserData.Workflow;
        end

        newUserData.Workflow=newWorkflow;
        newUserData.HdlFiles=this.UserData.HdlFiles;
        newUserData.PathOpt=this.UserData.PathOpt;
        newUserData.HdlPath=this.UserData.HdlPath;
        this.UserData=newUserData;
    end

    this.Simulator=newVal;
end
