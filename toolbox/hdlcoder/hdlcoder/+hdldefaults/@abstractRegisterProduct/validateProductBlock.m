function v=validateProductBlock(this,hC)




















    v=hdlvalidatestruct;

    bfp=hC.SimulinkHandle;

    if strcmpi(hdlget_param(hC.getBlockPath,'Architecture'),'Cascade')


        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:DeprecateCascade',get_param(bfp,'Name')));
    end

    if~strcmpi(get_param(bfp,'Multiplication'),'element-wise(.*)')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:unsupportedmatrix'));
    end

    in1=hC.SLInputPorts(1).Signal;








    in1vect=hdlsignalvector(in1);

    if(hdlsignaliscomplex(in1)&&max(in1vect)>2)
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:unsupportedcmpproductofelements'));
    end





