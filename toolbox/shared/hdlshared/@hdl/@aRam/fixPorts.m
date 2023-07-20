function inportOffset=fixPorts(this,hC,hasClkEn)%#ok







    hC.removeInputPort(2);
    inportOffset=2;

    if~hasClkEn
        hC.removeInputPort(1);
        inportOffset=1;
    end
