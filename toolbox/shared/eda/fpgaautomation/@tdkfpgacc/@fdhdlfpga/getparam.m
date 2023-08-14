function[params,tb_params]=getparam(this,hParent,hCLI)




    tb_params=[];

    params={'EnableFPGAWorkflow',hCLI.EnableFPGAWorkflow};

    if strcmpi(hCLI.EnableFPGAWorkflow,'on')
        params=[params,{'FPGAWorkflowParameters',this.FPGAProperties}];
    end

