function spec=SqrtFunctionCharSpec(compName)





    spec=struct();








    switch compName
    case 'sqrtfunction_comp'

        spec.dataType='fixdt';

        param=characterization.ParamDesc();
        param.name='LatencyStrategy';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'max','zero'};
        param.regenerateModel=true;
        params=param;

        port=characterization.PortDesc();
        port.port={1};
        port.range={4,64,4};
        port.widthTemplate='fixdt(1, %d, 0)';
        ports=port;

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1};
    case 'nfp_sqrt_comp'

        spec.dataType='nfpdt';

        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'sqrt'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;

        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Min','Zero','Custom'};
        param1.doNotOutput=true;
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='CustomLatency';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={0,1,2,3,4,5,6,7,8,9,10,12,13,14,15,16,17,23,35,43,54,58};
        param2.doNotOutput=true;
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        param3=characterization.ParamDesc();
        param3.name='HandleDenormals';
        param3.type=characterization.ParamDesc.HDL_PARAM;
        param3.values={'on','off'};
        param3.toolDepedentParam=true;
        param3.regenerateModel=true;

        params=[param,param1,param2,param3];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,64,32};
        inport1.widthTemplate='single';

        ports=inport1;

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1};

    case 'nfp_rsqrt_comp'

        spec.dataType='nfpdt';

        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'rSqrt'};
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
        param2.name='CustomLatency';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={0,1,2,3,4,6,7,8,10,11,13,14,16,17,29,30};
        param2.doNotOutput=true;
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        param3=characterization.ParamDesc();
        param3.name='HandleDenormals';
        param3.type=characterization.ParamDesc.HDL_PARAM;
        param3.values={'on','off'};
        param3.toolDepedentParam=true;
        param3.regenerateModel=true;

        params=[param,param1,param2,param3];

        port=characterization.PortDesc();
        port.port={1};
        port.range={32,64,32};
        port.widthTemplate='single';
        ports=port;

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1};

    end
end
