function m3iDataElement=findM3iDataElementFromPortParameterMapping(model,mappingObj)





    assert(strcmp(mappingObj.MappedTo.ArDataRole,'PortParameter'),...
    'This method is only valid for port parameters');


    m3iDataElement=[];

    portName=mappingObj.MappedTo.getPerInstancePropertyValue('Port');
    if isempty(portName)

        return;
    end
    dataElementName=mappingObj.MappedTo.getPerInstancePropertyValue('DataElement');
    if isempty(dataElementName)

        return;
    end
    m3iComp=autosar.api.Utils.m3iMappedComponent(model);
    m3iPort=autosar.mm.Model.findElementInSequenceByName(...
    m3iComp.ParameterReceiverPorts,portName);
    if isempty(m3iPort)||~m3iPort.isvalid()

        return;
    end
    m3iItf=m3iPort.Interface;

    if~m3iItf.isvalid()


        return;
    end

    m3iDataElement=autosar.mm.Model.findElementInSequenceByName(...
    m3iItf.DataElements,dataElementName);


