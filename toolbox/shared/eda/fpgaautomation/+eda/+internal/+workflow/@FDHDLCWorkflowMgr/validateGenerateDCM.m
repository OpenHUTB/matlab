function validateGenerateDCM(h)








    userParam=h.mWorkflowInfo.userParam;
    hdlcData=h.mWorkflowInfo.hdlcData;


    if~userParam.genClockModule
        return;
    end



    if~isclockmodulesupported
        error(message('EDALink:FDHDLCWorkflowMgr:validateGenerateDCM:unsupportedOS'));
    end


    if hdlcData.clockinputs~=1
        error(message('EDALink:FDHDLCWorkflowMgr:validateGenerateDCM:MultipleClocks'));
    end





    if strcmpi(hdlcData.target_language,'VHDL')&&...
        ~(hdlcData.filter_input_type_std_logic&&hdlcData.filter_output_type_std_logic)
        error(message('EDALink:FDHDLCWorkflowMgr:validateGenerateDCM:StdLogicPort'));
    end


    validateGenerateDCM@eda.internal.workflow.WorkflowManager(h);


