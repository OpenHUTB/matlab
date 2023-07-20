function out=changeAccessMode(model,port,accessmode)





    slmapping=autosar.api.getSimulinkMapping(model);
    blockType=get_param(port,'BlockType');

    index=strfind(port,'/');
    blockName=port(index(end)+1:end);

    if strcmp(blockType,'Outport')
        [arport,de,~]=slmapping.getOutport(blockName);
        slmapping.mapOutport(blockName,arport,de,accessmode);
    else
        [arport,de,~]=slmapping.getInport(blockName);
        slmapping.mapInport(blockName,arport,de,accessmode);
    end

    out='Access Mode Changed';
