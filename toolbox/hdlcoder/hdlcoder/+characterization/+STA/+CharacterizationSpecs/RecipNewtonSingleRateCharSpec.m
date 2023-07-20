function spec=RecipNewtonSingleRateCharSpec(compName)





    spec=struct();









    spec.dataType='nfpdt';


    param=characterization.ParamDesc();
    param.name='LatencyStrategy';
    param.type=characterization.ParamDesc.HDL_PARAM;
    param.values={'Max','Min','Zero'};
    param.toolDepedentParam=true;
    param.regenerateModel=true;

    param1=characterization.ParamDesc();
    param1.name='HandleDenormals';
    param1.type=characterization.ParamDesc.HDL_PARAM;
    param1.values={'on','off'};
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

end