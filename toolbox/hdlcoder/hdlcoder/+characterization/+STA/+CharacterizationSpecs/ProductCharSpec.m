function spec=ProductCharSpec(compName)





    spec=struct();









    switch compName
    case 'mul_comp'
        spec.dataType='fixdt';
        param=characterization.ParamDesc();
        param.name='DSPStyle';
        param.type=characterization.ParamDesc.HDL_PARAM;
        param.values={'none','on','off'};
        param.toolDepedentParam=true;
        params=param;

        port=characterization.PortDesc();
        port.port={1,2};
        port.range={2,64,2};
        port.widthTemplate='fixdt(1, %d, 0)';
        ports=port;

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1,2};

    case 'nfp_mul_comp'

        spec.dataType='nfpdt';


        param=characterization.ParamDesc();
        param.name='Inputs';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'**'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'ZERO','MIN','MAX','CUSTOM'};
        param1.doNotOutput=true;
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='NFPCustomLatency';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={0,1,2,3,4,6,9};
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
        param4.name='MantissaMultiplyStrategy';
        param4.type=characterization.ParamDesc.HDL_PARAM;
        param4.values={'FullMultiplier','PartMultiplierPartAddShift','NoMultiplierFullAddShift'};
        param4.toolDepedentParam=true;
        param4.regenerateModel=true;

        param5=characterization.ParamDesc();
        param5.name='PartAddShiftMultiplierSize';
        param5.type=characterization.ParamDesc.HDL_PARAM;
        param5.values={'18x24','18x18','17x17'};
        param5.toolDepedentParam=true;
        param5.regenerateModel=true;

        params=[param,param1,param2,param3,param4,param5];

        ports=characterization.PortDesc();
        ports.port={1,2};
        ports.range={32,64};
        ports.widthTemplate='';

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1,2};

    case 'nfp_div_comp'

        spec.dataType='nfpdt';


        param=characterization.ParamDesc();
        param.name='Inputs';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'*/'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'ZERO','MIN','MAX','CUSTOM'};
        param1.doNotOutput=true;
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='NFPCustomLatency';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={0,1,2,3,4,5,6,7,8,11,16,17,20,21,27,31,32,35,40,45,50,58,61};
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
        param4.values={'Radix-2','Radix-4'};
        param4.toolDepedentParam=true;
        param4.regenerateModel=true;

        params=[param,param1,param2,param3,param4];

        ports=characterization.PortDesc();
        ports.port={1,2};
        ports.range={32,64};
        ports.widthTemplate='';

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1,2};

    end

end
