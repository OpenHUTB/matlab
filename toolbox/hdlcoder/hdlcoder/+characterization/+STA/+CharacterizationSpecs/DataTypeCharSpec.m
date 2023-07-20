function spec=DataTypeCharSpec(compName)





    spec=struct();









    switch compName
    case 'datatypeconvert_comp'

        spec.dataType='fixdt';

        param=characterization.ParamDesc();
        param.name='RndMeth';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'Ceiling','Convergent','Floor','Nearest','Round','Simplest','Zero'};
        param.toolDepedentParam=false;
        params=param;

        param=characterization.ParamDesc();
        param.name='SaturateOnIntegerOverflow';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'on','off'};
        param.toolDepedentParam=false;
        params(end+1)=param;




        port=characterization.PortDesc();
        port.port={1};
        port.range={4,64,4};
        port.widthTemplate='fixdt(1, %d, 0)';
        ports=port;

        spec.params=params;
        spec.ports=ports;
        spec.widthSpec={1};

    case 'nfp_conv_fi2fl_comp'

        spec.dataType='nfpdt';


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Zero','Custom'};
        param1.doNotOutput=true;
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='NFPCustomLatency';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={0,1,2,4,5,6};
        param2.doNotOutput=true;
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={1,6,1};
        inport1.widthTemplate='fixdt(0, 2^%d, 0)';

        outport1=characterization.PortDesc();
        outport1.port={-1};
        outport1.range={32,32,1};
        outport1.widthTemplate='single';

        spec.params=[param1,param2];
        spec.ports=[inport1,outport1];
        spec.widthSpec={1,-1};

    case 'nfp_conv_fl2fi_comp'

        spec.dataType='nfpdt';


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Zero'};
        param1.values={'Max','Zero','Custom'};
        param1.doNotOutput=true;
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='NFPCustomLatency';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={0,1,2,4,5,6};
        param2.doNotOutput=true;
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,32,1};
        inport1.widthTemplate='single';

        outport1=characterization.PortDesc();
        outport1.port={-1};
        outport1.range={1,6,1};
        outport1.widthTemplate='fixdt(0, 2^%d, 0)';

        spec.params=[param1,param2];
        spec.ports=[inport1,outport1];
        spec.widthSpec={1,-1};


    case 'nfp_conv_fl2fl_comp'

        spec.dataType='nfpdt';


        param1=characterization.ParamDesc();
        param1.name='LatencyStrategy';
        param1.type=characterization.ParamDesc.HDL_PARAM;
        param1.values={'Max','Zero'};
        param1.values={'Max','Zero','Custom'};
        param1.doNotOutput=true;
        param1.toolDepedentParam=true;
        param1.regenerateModel=true;

        param2=characterization.ParamDesc();
        param2.name='NFPCustomLatency';
        param2.type=characterization.ParamDesc.HDL_PARAM;
        param2.values={0,1,2,4,5,6};
        param2.doNotOutput=true;
        param2.toolDepedentParam=true;
        param2.regenerateModel=true;

        inport1=characterization.PortDesc();
        inport1.port={1};
        inport1.range={32,64};
        inport1.widthTemplate='';

        outport1=characterization.PortDesc();
        outport1.port={-1};
        outport1.range={32,64};
        outport1.widthTemplate='';

        spec.params=[param1,param2];
        spec.ports=[inport1,outport1];
        spec.widthSpec={1,-1};
    end

end
