function getResource(this,hC)





    iports=getPortStruct(this,hC.PirInputSignals,hdlsignalname(hC.PirInputPorts));

    if this.hasClkEn
        inputOffset=2;
    else
        inputOffset=1;
    end

    if this.dataIsComplex
        complexOffset=1;
    else
        complexOffset=0;
    end

    di=iports(inputOffset+1:inputOffset+complexOffset+1);
    wa=iports(inputOffset+complexOffset+2);

    diWidth=di(1).Width*(1+complexOffset);
    waWidth=wa.Width;

    resourceLog(waWidth,diWidth,'mem');