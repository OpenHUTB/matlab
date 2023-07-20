function h=getStepHandle(this)



    switch(this.UserData.Workflow)
    case 'Simulink'
        assert(this.NextStepID>=1&&this.NextStepID<=9,...
        'HDLLink:CosimWizard:InvalidWorkflow','Invalid workflow number');
    case 'MATLAB'
        assert((this.NextStepID>=1&&this.NextStepID<=4)||(this.NextStepID>=10&&this.NextStepID<=11),...
        'HDLLink:CosimWizard:InvalidWorkflow','Invalid workflow number');
    case 'MATLAB System Object'
        assert((this.NextStepID>=1&&this.NextStepID<=8)||(this.NextStepID==12),...
        'HDLLink:CosimWizard:InvalidWorkflow','Invalid workflow number');
    otherwise
        error(message('HDLLink:CosimWizard:InvalidWorkflow'));
    end

    h=this.StepHandles{this.NextStepID};


