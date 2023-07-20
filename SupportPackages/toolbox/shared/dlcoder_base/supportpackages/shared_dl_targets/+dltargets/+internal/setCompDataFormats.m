function setCompDataFormats(comp,inputFormats,outputFormats)















    inPorts=comp.PirInputPorts;
    for i=1:comp.getNumIn
        inPorts(i).setDataFormat(inputFormats{i});
    end



    outPorts=comp.PirOutputPorts;

    for i=1:comp.getNumOut
        outPorts(i).setDataFormat(outputFormats{i});
    end
end