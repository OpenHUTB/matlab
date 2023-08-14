function elabCascadeBlock(this,hN,hC,hSignalsIn,hSignalsOut,...
    ipf,bmp,opName)






    slbh=hC.SimulinkHandle;

    casName=sprintf('---- Cascade %s implementation ----',opName);


    numInports=length(hC.PirInputPorts);


    if numInports>1
        error(message('hdlcoder:validate:NoMultiInputPort',opName,this.localGetBlockName(slbh)));
    end

    if needCascadeArch(hC,hSignalsIn,hSignalsOut)

        hNewC=this.elabCascadeArchitecture(hN,hC,hSignalsIn,hSignalsOut,ipf,bmp,opName,casName);


        hNewC.copyComment(hC);

    else

        valWire=pirelab.getWireComp(hN,hSignalsIn,hSignalsOut);


        valWire.copyComment(hC);

    end

end



function out=needCascadeArch(hC,hSignalsIn,hSignalsOut)


    dimLen=max(hSignalsIn(1).Type.getDimensions);


    numOutports=length(hC.PirOutputPorts);
    dimOut=max(hSignalsOut(1).Type.getDimensions);



    out=~(dimLen==1||(dimOut>1&&dimOut==dimLen&&numOutports==1));

end
