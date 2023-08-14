function v=validateBlock(this,hC)




    ports=this.getAllSLInputPorts(hC);

    ports=[ports,this.getAllSLOutputPorts(hC)];
    wl=hC.PirInputSignals(1).Type.BaseType.WordLength;
    v=this.baseValidatePortDatatypes(ports);


    slbh=hC.SimulinkHandle;
    lidx=hdlslResolve('lidx',slbh);
    if(lidx>=wl)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:indexexceeds',lidx,hC.name,wl-1));
    end

end

