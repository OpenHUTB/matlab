function generateHDL(h,hdlcParams)







    if~(builtin('license','checkout','Simulink_HDL_Coder'))||...
        (~hdlcoderui.isslhdlcinstalled)

        error(message('EDALink:WorkflowManager:generateHDL:noslhdlclicense'));
    end

    params={};
    if~isempty(hdlcParams)
        [hc,params]=hdlcoderargs(hdlcParams{:});
    else


        model=h.mWorkflowInfo.tdkParam.model;
        attachhdlcconfig(model);
        hc=get_param(model,'HDLCoder');
        if isempty(hc)
            error(message('EDALink:WorkflowManager:generateHDL:nohdlcoderui'));
        end
    end

    [oldDriver,oldMode,oldAutosaveState]=hc.inithdlmake;

    try
        if h.mWorkflowInfo.userParam.alwaysGenHDL
            hc.makehdl(params);


        elseif~isCodeGenSuccessful(hc)
            modelonly_prop='codegenerationoutput';
            modelonly_setting='DisplayGeneratedModelOnly';
            if strcmpi(hc.getParameter(modelonly_prop),modelonly_setting)


                error(message('EDALink:WorkflowManager:generateHDL:nohdlcodegen',modelonly_prop,modelonly_setting));
            end


            warning(message('EDALink:WorkflowManager:generateHDL:reruncodegen'));
            hc.makehdl(params);
        end

        if~isCodeGenSuccessful(hc)

            error(message('EDALink:WorkflowManager:generateHDL:unsuccessfulcodegen'));
        end


        hcData.HDLCoder=hc;

        hcData.hdlPropSet=hc.getCPObj;

        hcData.modelName=hc.ModelConnection.ModelName;
        hcData.dutPath=hc.getStartNodeName;
        hcData.dutName=hc.getEntityTop;
        hcData.MCPinfo=hc.MCPinfo;

        hcData.codegenDir=hc.hdlGetCodegendir(true);
        hcData.target_language=hc.getParameter('target_language');
        hcData.clockname=hc.getParameter('clockname');
        hcData.resetname=hc.getParameter('resetname');
        hcData.clockenablename=hc.getParameter('clockenablename');
        hcData.minimizeclockenables=hc.getParameter('minimizeclockenables');
        hcData.multicyclepathinfo=hc.getParameter('multicyclepathinfo');
        hcData.reset_asserted_level=hc.getParameter('reset_asserted_level');
        hcData.async_reset=hc.getParameter('async_reset');
        hcData.generatehdltestbench=hc.getParameter('generatehdltestbench');
        hcData.force_clock_high_time=hc.getParameter('force_clock_high_time');
        hcData.force_clock_low_time=hc.getParameter('force_clock_low_time');
        hcData.tool_file_comment=hc.getParameter('tool_file_comment');
        hcData.filter_input_type_std_logic=hc.getParameter('filter_input_type_std_logic');
        hcData.filter_output_type_std_logic=hc.getParameter('filter_output_type_std_logic');




        scriptGen=hdlshared.AbstractEDAScripts(...
        hc.PirInstance.getEntityNames,...
        hc.PirInstance.getEntityPaths,...
        hc.TestBenchFilesList);

        hcData.hdlFiles=scriptGen.entityFileNames;

        hn=hc.getCurrentNetwork;
        hcData.dut.clock=hn.getInputPorts('clock');
        hcData.dut.clkenable=hn.getInputPorts('clock_enable');
        hcData.dut.reset=hn.getInputPorts('reset');
        hcData.dut.inputs=hn.getInputPorts('data');
        hcData.dut.ceout=hn.getOutputPorts('clock_enable');
        hcData.dut.outputs=hn.getOutputPorts('data');

        hcData.clockinputs=hn.NumberOfPirInputPorts('clock');





    catch me
        fclose('all');

        hc.baseCleanup(oldDriver,oldMode,oldAutosaveState);

        rethrow(me);
    end


    success=true;
    hc.cleanup(oldDriver,oldMode,oldAutosaveState,success);

    h.mWorkflowInfo.hdlcData=hcData;






