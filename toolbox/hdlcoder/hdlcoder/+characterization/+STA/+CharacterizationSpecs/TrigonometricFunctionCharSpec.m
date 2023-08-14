function spec=TrigonometricFunctionCharSpec(compName)




    spec=struct();









    spec.dataType='nfpdt';

    switch compName
    case 'nfp_sin_comp'

        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'sin'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Zero'};
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='MultiplyStrategy';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={'FullMultiplier','PartMultiplierPartAddShift'};
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        param3=characterization.ParamDesc();
        param3.name='InputRangeReduction';
        param3.type=characterization.ParamDesc.HDL_PARAM;
        param3.values={'on','off'};
        param3.toolDepedentParam=true;
        param3.regenerateModel=true;

        params=[param,param1,param2,param3];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,32,1};
        inport1.widthTemplate='single';

        ports=inport1;

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1};

    case 'nfp_cos_comp'

        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'cos'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Zero'};
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='MultiplyStrategy';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={'FullMultiplier','PartMultiplierPartAddShift'};
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        param3=characterization.ParamDesc();
        param3.name='InputRangeReduction';
        param3.type=characterization.ParamDesc.HDL_PARAM;
        param3.values={'on','off'};
        param3.toolDepedentParam=true;
        param3.regenerateModel=true;

        params=[param,param1,param2,param3];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,32,1};
        inport1.widthTemplate='single';

        ports=inport1;

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1};

    case 'nfp_tan_comp'

        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'tan'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Zero'};
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='InputRangeReduction';
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

    case 'nfp_asin_comp'

        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'asin'};
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

    case 'nfp_acos_comp'

        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'acos'};
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

    case 'nfp_sinh_comp'

        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'sinh'};
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

    case 'nfp_cosh_comp'

        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'cosh'};
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

    case 'nfp_tanh_comp'

        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'tanh'};
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

    case 'nfp_atan_comp'

        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'atan'};
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

    case 'nfp_asinh_comp'

        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'asinh'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Zero'};
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

    case 'nfp_acosh_comp'

        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'acosh'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Zero'};
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

    case 'nfp_atanh_comp'

        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'atanh'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Zero'};
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

    case 'nfp_atan2_comp'

        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'atan2'};
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

    case 'nfp_sincos_comp'

        spec.dataType='nfpdt';
        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'sincos'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Zero'};
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='MultiplyStrategy';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={'FullMultiplier','PartMultiplierPartAddShift'};
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        param3=characterization.ParamDesc();
        param3.name='InputRangeReduction';
        param3.type=characterization.ParamDesc.HDL_PARAM;
        param3.values={'on','off'};
        param3.toolDepedentParam=true;
        param3.regenerateModel=true;

        params=[param,param1,param2,param3];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,32,1};
        inport1.widthTemplate='single';

        ports=inport1;

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1};
    end

end
