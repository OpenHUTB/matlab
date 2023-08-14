function latencyInfo=baseGetLatencyInfo(this,hC)











    slbh=hC.SimulinkHandle;

    blockInfo=getBlockInfo(this,slbh);
    coeffs=blockInfo.Coefficients;

    numbCoeffs=length(coeffs);

    MultiplierInputPipeline=hdlgetparameter('multiplier_input_pipeline');
    MultiplierOutputPipeline=hdlgetparameter('multiplier_output_pipeline');
    AdderPipelineDepth=hdlgetparameter('adder_tree_pipeline');


    latencyInfo.inputDelay=0;

    latencyInfo.outputDelay=MultiplierOutputPipeline+...
    MultiplierInputPipeline+AdderPipelineDepth*(ceil(log2(numbCoeffs)));

    latencyInfo.samplingChange=1;



