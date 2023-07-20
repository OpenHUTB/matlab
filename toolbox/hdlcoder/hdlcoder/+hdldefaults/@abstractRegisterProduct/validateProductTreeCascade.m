function v=validateProductTreeCascade(this,hC)




















    v=hdlvalidatestruct;



    v=[v,this.validateProductBlock(hC)];

    bfp=hC.SimulinkHandle;

    inputsigns=get_param(bfp,'Inputs');
    inputsigns=strrep(inputsigns,'|','');

    if strcmpi(hdlget_param(hC.getBlockPath,'Architecture'),'Cascade')


        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:DeprecateCascade',get_param(bfp,'Name')));
    end


    if~isempty(strfind(inputsigns,'/'))
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:unsupporteddivide'));
    end


    in1=hC.SLInputPorts(1).Signal;
    in1vect=hdlsignalvector(in1);
    vectorsize=max(in1vect);


    if length(hC.SLInputPorts)>1||vectorsize<2
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:TooManyInputsProduct'));
    end


