function spec=GainCharSpec(compName)





    spec=struct();








    switch compName

    case 'nfp_gain_pow2_comp'

        spec.dataType='nfpdt';

        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Min','Zero','Custom'};
        param1.doNotOutput=true;
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='NFPCustomLatency';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={0,1,2};
        param2.doNotOutput=true;
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        param3=characterization.ParamDesc();
        param3.name='HandleDenormals';
        param3.type=characterization.ParamDesc.HDL_PARAM;
        param3.values={'on','off'};
        param3.toolDepedentParam=true;
        param3.regenerateModel=true;

        params=[param1,param2,param3];

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,64};
        inport1.widthTemplate='';

        spec.ports=inport1;
        spec.params=params;
        spec.widthSpec={1};
    end
