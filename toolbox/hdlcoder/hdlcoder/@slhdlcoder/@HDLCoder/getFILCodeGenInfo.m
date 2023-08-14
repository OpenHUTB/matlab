function codeGenInfo=getFILCodeGenInfo(this)





    codeGenInfo.codegendir=this.hdlGetCodegendir;
    codeGenInfo.target_language=this.getParameter('target_language');
    codeGenInfo.vhdl_file_ext=this.getParameter('vhdl_file_ext');
    codeGenInfo.verilog_file_ext=this.getParameter('verilog_file_ext');
    codeGenInfo.reset_asserted_level=this.getParameter('reset_asserted_level');
    codeGenInfo.input_type_std_logic=this.getParameter('filter_input_type_std_logic');
    codeGenInfo.output_type_std_logic=this.getParameter('filter_output_type_std_logic');
    codeGenInfo.oversampling=this.getParameter('oversampling');


    if this.getParameter('isvhdl')&&~strcmp(this.getParameter('top_level_vhdl_library_name'),'work')
        codeGenInfo.top_level_library_name=this.getParameter('top_level_vhdl_library_name');
    else
        codeGenInfo.top_level_library_name=[];
    end



    subModelFiles={};
    for ii=1:numel(this.SubModelData)
        subModelFiles=[subModelFiles,...
        fullfile(this.SubModelData(ii).ModelName,this.SubModelData(ii).FileNames)];%#ok<AGROW>
    end
    codeGenInfo.EntityFileNames=[subModelFiles,this.getEntityFileNames(this.PirInstance)];
    codeGenInfo.EntityTop=this.getEntityTop;
    codeGenInfo.SubModelData=this.SubModelData;

    p=pir(this.AllModels(end).modelName);
    hn=p.getTopNetwork;

    codeGenInfo.numClk=hn.NumberOfPirInputPorts('clock');
    codeGenInfo.numEnb=hn.NumberOfPirInputPorts('clock_enable');

    codeGenInfo.ports.clk=hn.getInputPorts('clock');
    codeGenInfo.ports.enb=hn.getInputPorts('clock_enable');
    codeGenInfo.ports.rst=hn.getInputPorts('reset');
    codeGenInfo.ports.din=hn.getInputPorts('data');
    codeGenInfo.ports.dout=hn.getOutputPorts('data');

    codeGenInfo.DutBaseRate=p.getOrigDutBaseRate;
    codeGenInfo.ScalingFactor=p.getDutBaseRateScalingFactor;

    tcInfo=this.getTimingControllerInfo(0);
    codeGenInfo.dutHasTC=~isempty(tcInfo.nstates);

    gp=pir;
    codeGenInfo.isTargetLibraryUsed=gp.getTargetCodeGenSuccess;

end
