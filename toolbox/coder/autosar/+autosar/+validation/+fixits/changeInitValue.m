function out=changeInitValue(block,valueStr)






    modelName=bdroot(block);

    slmapping=autosar.api.getSimulinkMapping(modelName);
    blockType=get_param(block,'BlockType');
    isInport=strcmp(blockType,'Inport');

    index=strfind(block,'/');
    blockName=block(index(end)+1:end);

    if isInport
        [ARPortName,ARDataElementName,~]=slmapping.getInport(blockName);
    else
        [ARPortName,ARDataElementName,~]=slmapping.getOutport(blockName);
    end

    m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);


    m3iPort=autosar.ui.comspec.ComSpecUtils.findM3IPortByName(m3iComp,ARPortName);
    assert(~isempty(m3iPort),'m3iPort not found');

    m3iInfo=autosar.ui.comspec.ComSpecUtils.findM3IPortInfoForDataElement(m3iPort,...
    ARDataElementName,isInport);
    assert(~isempty(m3iInfo),'m3iPort not found');


    autosar.ui.comspec.ComSpecPropertyHandler.setComSpecPropertyValue(...
    m3iInfo.comSpec,'InitValue',valueStr);

    out='InitValue Changed';
