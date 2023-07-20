function spec=getCharacterizationSpec(~)





    spec=struct();




    param=characterization.ParamDesc();
    param.name='Operator';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'==','~=','<','<=','>=','>'};
    param.toolDepedentParam=false;
    params=param;




    port=characterization.PortDesc();
    port.port={1,2};
    port.range={4,64,4};
    port.widthTemplate='fixdt(1, %d, 0)';
    ports=port;

    spec.params=params;
    spec.ports=ports;
    spec.widthSpec={1,2};

end
