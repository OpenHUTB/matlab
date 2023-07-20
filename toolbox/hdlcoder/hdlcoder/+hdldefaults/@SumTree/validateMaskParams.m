function vstructs=validateMaskParams(~,hC)




    vstructs=hdlvalidatestruct;

    bfp=hC.SimulinkHandle;

    inputsigns=get_param(bfp,'Inputs');
    inputsigns=strrep(inputsigns,'|','');



    out=hC.SLOutputSignals(1);
    numInputPorts=hC.NumberOfPirInputPorts;
    minusSOETargetMode=targetmapping.mode(out)&&strcmp(inputsigns,'-')&&(numInputPorts==1);

    if(~minusSOETargetMode)&&contains(inputsigns,'-')
        vstructs(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnsupportedMask'));
    end


    if length(hC.SLInputPorts)>1
        vstructs(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:TooManyInputsMask'));
    end



    accumType=get_param(bfp,'accumDataTypeStr');
    if~strcmpi(accumType,'Inherit: Inherit via internal rule')
        vstructs(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:AccumDataTypeMask'));
    end
