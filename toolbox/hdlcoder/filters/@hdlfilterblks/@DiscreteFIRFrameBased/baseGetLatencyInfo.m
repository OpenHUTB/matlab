function latencyInfo=baseGetLatencyInfo(this,hC)











    slbh=hC.SimulinkHandle;
    if strcmp('Input port',get_param(slbh,'CoefSource'))
        numbCoeffs=double(hC.PirInputSignals(2).Type.getDimensions);
    else
        numbCoeffs=length(this.hdlslResolve('Coefficients',slbh));
    end

    MultiplierInputPipeline=hdlgetparameter('multiplier_input_pipeline');
    MultiplierOutputPipeline=hdlgetparameter('multiplier_output_pipeline');
    AdderPipelineDepth=hdlgetparameter('adder_tree_pipeline');


    latencyInfo.inputDelay=0;

    latencyInfo.outputDelay=MultiplierOutputPipeline+...
    MultiplierInputPipeline+AdderPipelineDepth*(ceil(log2(numbCoeffs)));

    latencyInfo.samplingChange=1;



