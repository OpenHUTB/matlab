function v=validateBlock(this,hC)




    ports=this.getAllSLInputPorts(hC);


    ports=[ports,this.getAllSLOutputPorts(hC)];


    v=this.baseValidatePortDatatypes(ports);
    in1signal=hC.PirInputSignals(1);

    in1BaseType=getPirSignalBaseType(in1signal.Type);

    if(in1BaseType.isComplexType&&isDoubleType(in1BaseType.getLeafType))
        isPortTypeComplexDouble=true;
    else
        isPortTypeComplexDouble=false;
    end
    if(isPortTypeComplexDouble)
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:ComplexTypeUnsupportedSignum'));
        return;
    end
end

