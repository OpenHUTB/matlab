function out=needTreeArch(this,hC,hSignalsIn,hSignalsOut)%#ok<INUSL>




    dimLen=max(hSignalsIn(1).Type.getDimensions);


    numOutports=length(hC.PirOutputPorts);
    dimOut=max(hSignalsOut(1).Type.getDimensions);



    out=~(dimLen==1||(dimOut>1&&dimOut==dimLen&&numOutports==1));

end
