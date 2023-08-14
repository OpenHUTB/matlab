function[inputFormats,outputFormats]=getInputAndOutputFormatsFromPirComp(pirComp)






    numelInputFormats=numel(pirComp.PirInputPorts);
    inputFormats=cell(1,numelInputFormats);
    for i=1:numelInputFormats
        inputFormats{i}=pirComp.PirInputPorts(i).getDataFormat;
    end

    numelOutputFormats=numel(pirComp.PirOutputPorts);
    outputFormats=cell(1,numelOutputFormats);
    for i=1:numelOutputFormats
        outputFormats{i}=pirComp.PirOutputPorts(i).getDataFormat;
    end
end