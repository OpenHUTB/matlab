function vstructs=validateMaskParams(~,hC)


    vstructs=hdlvalidatestruct;

    bfp=hC.SimulinkHandle;

    inputsigns=get_param(bfp,'Inputs');
    inputsigns=strrep(inputsigns,'|','');

    if~isempty(strfind(inputsigns,'-'))
        vstructs(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:SumCascadeSubtract'));
    end


    if length(hC.SLInputPorts)>1
        vstructs(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:SumCascadeInputs'));
    end


    hInSignals=hC.PirInputSignals;
    inputRate=hInSignals(1).SimulinkRate;
    if isequal(inputRate,Inf)
        vstructs(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:InfInputRate'));
    end
