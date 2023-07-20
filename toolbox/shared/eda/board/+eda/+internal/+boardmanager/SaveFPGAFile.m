function SaveFPGAFile(BoardObj)


    [fid,msg]=fopen(BoardObj.BoardFile,'w');
    if fid>=0
        fclose(fid);
    else
        error(message('EDALink:boardmanager:WriteFileFailed',BoardObj.BoardFile,msg));
    end

    docNode=matlab.io.xml.dom.Document('FPGABoard');
    docRootNode=docNode.getDocumentElement;
    docRootNode.setAttribute('Version','1.0');
    boardNameNode=l_createTextElement(docNode,'BoardName',BoardObj.BoardName);
    docRootNode.appendChild(boardNameNode);

    fpgaNode=docNode.createElement('FPGA');
    fpgaNode.setAttribute('Vendor',BoardObj.FPGA.Vendor);
    fpgaNode.setAttribute('Family',BoardObj.FPGA.Family);
    fpgaNode.setAttribute('Device',BoardObj.FPGA.Device);
    fpgaNode.setAttribute('Package',BoardObj.FPGA.Package);
    fpgaNode.setAttribute('Speed',BoardObj.FPGA.Speed);
    fpgaNode.setAttribute('JTAGChainPosition',num2str(BoardObj.FPGA.JTAGChainPosition));



    clockNode=docNode.createElement('Interface');

    Clock=BoardObj.FPGA.getClock;

    typeElement=l_createTextElement(docNode,'Type',Clock.Name);
    clockNode.appendChild(typeElement);

    interfNames=BoardObj.FPGA.getInterfaceList;
    for m=1:numel(interfNames)
        type=interfNames{m};
        interface=BoardObj.FPGA.getInterface(type);
        interfNode=l_createInterfaceNode(docNode,interface);
        fpgaNode.appendChild(interfNode);
    end

    docRootNode.appendChild(fpgaNode);

    writer=matlab.io.xml.dom.DOMWriter();


    writer.Configuration.FormatPrettyPrint=true;
    writeToFile(writer,docNode,BoardObj.BoardFile)


end

function element=l_createTextElement(docNode,name,text)
    element=docNode.createElement(name);
    element.appendChild(docNode.createTextNode(text));
end

function interfNode=l_createInterfaceNode(docNode,interface)
    interfNode=docNode.createElement('Interface');
    typeElem=l_createTextElement(docNode,'Type',interface.Name);
    interfNode.appendChild(typeElem);

    paramNames=interface.getParamNames;
    for m=1:numel(paramNames)
        name=paramNames{m};
        value=interface.getParam(name);
        paramElem=l_createParamElem(docNode,name,value);
        interfNode.appendChild(paramElem);
    end

    signalNames=interface.getSignalNames;
    for m=1:numel(signalNames)
        name=signalNames{m};
        signal=interface.getSignal(name);
        busNode=l_createBusNode(docNode,signal);
        interfNode.appendChild(busNode);
    end

end

function paramElem=l_createParamElem(docNode,param,value)
    if isnumeric(value)
        value=num2str(value);
    end
    paramElem=l_createTextElement(docNode,'Parameter',value);
    paramElem.setAttribute('ID',param);
end

function busNode=l_createBusNode(docNode,signal)
    busNode=docNode.createElement('Signal');
    nameEle=l_createTextElement(docNode,'SignalName',signal.SignalName);
    descEle=l_createTextElement(docNode,'Description',signal.Description);
    dirEle=l_createTextElement(docNode,'Direction',signal.Direction);
    bitwEle=l_createTextElement(docNode,'BitWidth',num2str(signal.BitWidth));
    locEle=l_createTextElement(docNode,'FPGAPin',signal.FPGAPin);
    ioEle=l_createTextElement(docNode,'IOStandard',signal.IOStandard);
    busNode.appendChild(nameEle);
    busNode.appendChild(descEle);
    busNode.appendChild(dirEle);
    busNode.appendChild(bitwEle);
    busNode.appendChild(locEle);
    busNode.appendChild(ioEle);
end

