function spec=SumCharSpec(compName)





    spec=struct();









    switch compName
    case 'add_comp'

        spec.dataType='fixdt';

        port=characterization.PortDesc();
        port.port={1,2};
        port.range={4,64,4};
        port.widthTemplate='fixdt(1, %d, 0)';
        ports=port;

        spec.params={};
        spec.ports=ports;
        spec.widthSpec={1,2};

    case 'nfp_add_comp'

        spec.dataType='nfpdt';


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
        param2.values={0,1,2,3,4,6,9,11};
        param2.doNotOutput=true;
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        params=[param1,param2];

        ports=characterization.PortDesc();
        ports.port={1,2};
        ports.range={32,64};
        ports.widthTemplate='';

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1,2};

    end

end
