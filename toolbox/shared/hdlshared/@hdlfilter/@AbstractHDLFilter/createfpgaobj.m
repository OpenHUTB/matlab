function fpgaobj=createfpgaobj(this)







    if~hdlcoderui.isedasimlinksinstalled

        error(message('HDLShared:hdlfilter:noedalinkinstalled'));
    end


    fpgaprops=hdlgetparameter('fpga_workflow_parameters');

    if~isempty(fpgaprops)


        if~isa(fpgaprops,'fpgaworkflowprops.FDHDLCoder')
            error(message('HDLShared:hdlfilter:fpgaparametertype'));
        end
    else

        fpgaprops=fpgaworkflowprops.FDHDLCoder;
    end


    if strcmpi(fpgaprops.FPGAWorkflow,'USRP2 filter customization')&&...
        ~isa(this,'hdlfilter.usrp2')
        error(message('HDLShared:hdlfilter:usrpfilterobj'));
    end


    fpgaobj=eda.internal.workflow.FDHDLCWorkflowMgr(fpgaprops);
    fpgaobj.validate;
