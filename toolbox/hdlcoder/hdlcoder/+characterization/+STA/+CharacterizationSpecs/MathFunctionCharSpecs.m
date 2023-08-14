function spec=MathFunctionCharSpecs(compName)




    spec=struct();

    switch compName
    case 'nfp_exp_comp'

        spec.dataType='nfpdt';


        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'exp'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Min','Zero'};
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        params=[param,param1];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,32,1};
        inport1.widthTemplate='single';

        ports=inport1;

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1};

    case 'nfp_log_comp'

        spec.dataType='nfpdt';


        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'log'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Min','Zero'};
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='HandleDenormals';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={'on','off'};
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        params=[param,param1,param2];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,32,1};
        inport1.widthTemplate='single';

        ports=inport1;

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1};

    case 'nfp_pow10_comp'

        spec.dataType='nfpdt';


        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'10^u'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Min','Zero'};
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='HandleDenormals';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={'on','off'};
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        params=[param,param1,param2];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,32,1};
        inport1.widthTemplate='single';

        ports=inport1;

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1};

    case 'nfp_log10_comp'

        spec.dataType='nfpdt';


        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'log10'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Min','Zero'};
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='HandleDenormals';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={'on','off'};
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        params=[param,param1,param2];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,32,1};
        inport1.widthTemplate='single';

        ports=inport1;

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1};

    case 'nfp_recip_comp'

        spec.dataType='nfpdt';


        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'reciprocal'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Custom'};
        param1.doNotOutput=true;
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='NFPCustomLatency';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={0,1,2,4,5,7,9,10,15,16,17,19,21,26,29,30,31,34,40,45,50,59,60};
        param2.doNotOutput=true;
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        param3=characterization.ParamDesc();
        param3.name='HandleDenormals';
        param3.type=characterization.ParamDesc.HDL_PARAM;
        param3.values={'on','off'};
        param3.toolDepedentParam=true;
        param3.regenerateModel=true;

        param4=characterization.ParamDesc();
        param4.name='DivisionAlgorithm';
        param4.type=characterization.ParamDesc.HDL_PARAM;
        param4.values={'Radix-4'};
        param4.toolDepedentParam=true;
        param4.regenerateModel=true;

        params=[param,param1,param2,param3,param4];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,64};
        inport1.widthTemplate='';

        ports=inport1;

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1};

    case 'nfp_mod_comp'

        spec.dataType='nfpdt';


        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'mod'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Min','Zero'};
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='HandleDenormals';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={'on','off'};
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        param3=characterization.ParamDesc();
        param3.name='CheckResetToZero';
        param3.type=characterization.ParamDesc.HDL_PARAM;
        param3.values={'on','off'};
        param3.toolDepedentParam=true;
        param3.regenerateModel=true;

        param4=characterization.ParamDesc();
        param4.name='MaxIterations';
        param4.type=characterization.ParamDesc.HDL_PARAM;
        param4.values={'32','64','128'};
        param4.toolDepedentParam=true;
        param4.regenerateModel=true;

        params=[param,param1,param2,param3,param4];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,32,1};
        inport1.widthTemplate='single';

        inport2=characterization.PortDesc();
        inport2.port={2};
        inport2.range={32,32,1};
        inport2.widthTemplate='single';

        ports=[inport1,inport2];

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1,2};

    case 'nfp_rem_comp'

        spec.dataType='nfpdt';


        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'rem'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Min','Zero'};
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='HandleDenormals';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={'on','off'};
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        param3=characterization.ParamDesc();
        param3.name='CheckResetToZero';
        param3.type=characterization.ParamDesc.HDL_PARAM;
        param3.values={'on','off'};
        param3.toolDepedentParam=true;
        param3.regenerateModel=true;

        param4=characterization.ParamDesc();
        param4.name='MaxIterations';
        param4.type=characterization.ParamDesc.HDL_PARAM;
        param4.values={'32','64','128'};
        param4.toolDepedentParam=true;
        param4.regenerateModel=true;

        params=[param,param1,param2,param3,param4];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,32,1};
        inport1.widthTemplate='single';

        inport2=characterization.PortDesc();
        inport2.port={2};
        inport2.range={32,32,1};
        inport2.widthTemplate='single';

        ports=[inport1,inport2];

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1,2};

    case 'nfp_pow_comp'

        spec.dataType='nfpdt';


        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'pow'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Min','Zero'};
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='HandleDenormals';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={'on','off'};
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        params=[param,param1,param2];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,32,1};
        inport1.widthTemplate='single';

        inport2=characterization.PortDesc();
        inport2.port={2};
        inport2.range={32,32,1};
        inport2.widthTemplate='single';

        ports=[inport1,inport2];

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1,2};

    case 'nfp_hypot_comp'

        spec.dataType='nfpdt';


        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'hypot'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Min','Zero'};
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        params=[param,param1];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,32,1};
        inport1.widthTemplate='single';

        inport2=characterization.PortDesc();
        inport2.port={2};
        inport2.range={32,32,1};
        inport2.widthTemplate='single';

        ports=[inport1,inport2];

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1,2};
    end

end
