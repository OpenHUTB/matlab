function board=ReadFPGAFile(FileName)


    [fid,msg]=fopen(FileName,'r');
    if fid>=0
        fclose(fid);
    else
        error(message('EDALink:boardmanager:ReadFileFailed',FileName,msg));
    end

    domNode=parseFile(matlab.io.xml.dom.Parser,FileName);
    rootNode=domNode.getFirstChild;

    nodeName=char(rootNode.getNodeName);
    if~strcmp(nodeName,'FPGABoard')
        error(message('EDALink:boardmanager:XMLInvalidNode',...
        nodeName,'FPGABoard'));
    else
        version=char(rootNode.getAttribute('Version'));
        if str2double(version)>1.0
            warning(message('EDALink:boardmanager:FutureXMLVersion',FileName));
        end
    end


    boardNameNode=findFirstChildByTagName(rootNode,'BoardName');

    board=eda.internal.boardmanager.FPGABoard;
    board.BoardName=boardNameNode.getTextContent;



    fpgaNode=findFirstChildByTagName(rootNode,'FPGA');
    vendor=char(fpgaNode.getAttribute('Vendor'));
    family=char(fpgaNode.getAttribute('Family'));
    device=char(fpgaNode.getAttribute('Device'));
    package=char(fpgaNode.getAttribute('Package'));
    speed=char(fpgaNode.getAttribute('Speed'));
    tmp=char(fpgaNode.getAttribute('JTAGChainPosition'));
    if~isempty(tmp)
        board.FPGA.JTAGChainPosition=round(str2double(tmp));
    end





    board.FPGA.Vendor=vendor;
    board.FPGA.Family=family;
    board.FPGA.Device=device;
    board.FPGA.Package=package;
    board.FPGA.Speed=speed;

    parseInterfaceNodes(fpgaNode,board.FPGA);

    board.BoardFile=FileName;

    board.validate;

end



function parseInterfaceNodes(fpgaNode,fpgaObj)
    allInterfaces=fpgaNode.getElementsByTagName('Interface');


    for m=0:allInterfaces.getLength-1
        interfaceNode=allInterfaces.item(m);
        typeNode=findFirstChildByTagName(interfaceNode,'Type');
        name=typeNode.getTextContent;
        interfaceObj=...
        eda.internal.boardmanager.InterfaceManager.getInterfaceInstance(name);

        parseBusNodes(interfaceNode,interfaceObj);
        parseParamNodes(interfaceNode,interfaceObj);

        fpgaObj.setInterface(interfaceObj);
    end

end

function parseParamNodes(interfaceNode,interfaceObj)
    allParams=interfaceNode.getElementsByTagName('Parameter');
    for m=0:allParams.getLength-1
        paramNode=allParams.item(m);
        paramName=char(paramNode.getAttribute('ID'));
        paramValue=paramNode.getTextContent;
        tmp=interfaceObj.getParam(paramName);
        if isnumeric(tmp)
            paramValue=eval(paramValue);
        end
        interfaceObj.setParam(paramName,paramValue);
    end
end

function parseBusNodes(interfaceNode,interfaceObj)
    allSignals=interfaceNode.getElementsByTagName('Signal');
    for m=0:allSignals.getLength-1
        busNode=allSignals.item(m);
        name=getChildElementString(busNode,'SignalName');
        if isa(interfaceObj,'eda.internal.boardmanager.PredefinedInterface')
            Signal=interfaceObj.getSignal(name);
        else
            Signal=interfaceObj.addSignal(name);
        end

        Signal.FPGAPin=getChildElementString(busNode,'FPGAPin');
        Signal.IOStandard=getChildElementString(busNode,'IOStandard',false);

        if~isa(interfaceObj,'eda.internal.boardmanager.PredefinedInterface')


            Signal.Description=getChildElementString(busNode,'Description');
            Signal.Direction=getChildElementString(busNode,'Direction');
            Signal.BitWidth=eval(getChildElementString(busNode,'BitWidth'));
        end
    end
end

function str=getChildElementString(RootNode,NodeName,RequiredNode)
    if nargin==2
        RequiredNode=true;
    end
    childNode=RootNode.getElementsByTagName(NodeName);
    if childNode.getLength==0
        if RequiredNode
            error(message('EDALink:boardmanager:ElementNotExist',NodeName));
        else
            str='';
            return;
        end
    end
    str=childNode.item(0).getTextContent;
end

function childNode=findFirstChildByTagName(RootNode,NodeName)
    childNode=RootNode.getFirstChild;
    while~isempty(childNode)
        if childNode.getNodeType==1
            actNodeName=childNode.getNodeName;
            if strcmp(actNodeName,NodeName)
                return;
            end
        end
        childNode=childNode.getNextSibling;
    end
    error(message('EDALink:boardmanager:XMLNodeNotFound',NodeName));
end


