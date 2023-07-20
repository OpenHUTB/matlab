function getHDLParameters(h)




    hcData.codegenDir=hdlGetCodegendir(true);
    hcData.target_language=hdlgetparameter('target_language');

    hcData.clockinputs=hdlgetparameter('clockinputs');
    hcData.clockname=hdlgetparameter('clockname');
    hcData.resetname=hdlgetparameter('resetname');
    hcData.clockenablename=hdlgetparameter('clockenablename');
    hcData.reset_asserted_level=hdlgetparameter('reset_asserted_level');
    hcData.async_reset=hdlgetparameter('async_reset');

    hcData.generatehdltestbench=hdlgetparameter('generatehdltestbench');
    hcData.force_clock_high_time=hdlgetparameter('force_clock_high_time');
    hcData.force_clock_low_time=hdlgetparameter('force_clock_low_time');

    hcData.tool_file_comment=hdlgetparameter('tool_file_comment');

    hcData.filter_input_type_std_logic=hdlgetparameter('filter_input_type_std_logic');
    hcData.filter_output_type_std_logic=hdlgetparameter('filter_output_type_std_logic');
    hcData.filter_complex_inputs=hdlgetparameter('filter_complex_inputs');

    h.mWorkflowInfo.hdlcData=hcData;

