

classdef DeviceTreeGeneration<handle


    properties(Access=protected)

        hTurnkey=[];


        DeviceTreeSourceFileName string
        DeviceTreeBlobFileName string
    end

    properties(Dependent,SetAccess=protected)
DeviceTreeFolder
DeviceTreeSourceFilePath
DeviceTreeBlobFilePath
    end

    properties(Constant,Access=protected)
        SourceFileExt=".dtsi";
        BlobFileExt=".dtbo";
    end

    methods
        function obj=DeviceTreeGeneration(hTurnkey)

            obj.hTurnkey=hTurnkey;



            ipCoreName=obj.hTurnkey.hD.hIP.getIPCoreName;
            obj.DeviceTreeSourceFileName=ipCoreName+obj.SourceFileExt;
        end

        function filePath=get.DeviceTreeFolder(obj)
            filePath=obj.hTurnkey.getDeviceTreeFolder;
        end

        function filePath=get.DeviceTreeSourceFilePath(obj)
            filePath=fullfile(obj.DeviceTreeFolder,obj.DeviceTreeSourceFileName);
        end

        function filePath=get.DeviceTreeBlobFilePath(obj)
            filePath=fullfile(obj.DeviceTreeFolder,obj.DeviceTreeBlobFileName);
        end
    end


    methods
        function[status,result,validateCell]=generateDeviceTree(obj,generateAsOverlay)
            if nargin<2
                generateAsOverlay=false;
            end


            status=true;
            result='';
            validateCell={};

            [status,result]=obj.initDeviceTreeGen(status,result);
            ipCoreName=obj.hTurnkey.hD.hIP.getIPCoreName;
            nodeLabel=obj.hTurnkey.hD.hIP.getIPCoreDeviceName;


            addressArgs={};
            hBusInterface=obj.hTurnkey.getDefaultBusInterface;
            if~isempty(hBusInterface)
                baseAddr=hex2dec(hBusInterface.BaseAddress);
                addrRange=hBusInterface.AddressRange;
                addressArgs={"UnitAddress",baseAddr,"AddressLength",addrRange};
            end


            hIPCoreNode=devicetreeNode("mwipcore",nodeLabel,addressArgs{:});
            hIPCoreNode.addComment(sprintf('Device tree node for Mathworks-generated IP core "%s"',ipCoreName));





            hIPDeviceTree=devicetree;


            if isempty(hBusInterface)||isempty(hBusInterface.DeviceTreeBusNode)


                hParentNode=hIPDeviceTree.addRootNode;
            else


                busNodeName=hBusInterface.DeviceTreeBusNode;
                hParentNode=hIPDeviceTree.addReferenceNode(busNodeName);
            end
            hParentNode.addNode(hIPCoreNode);






            interfaceIDList=obj.hTurnkey.getSoftwareInterfaceIDList;
            for ii=1:length(interfaceIDList)





















                hIPCoreRefNode=hIPCoreNode.getReferenceNode;


                interfaceID=interfaceIDList{ii};
                hSoftwareInterface=obj.hTurnkey.getSoftwareInterface(interfaceID);
                validateCellInterface=hSoftwareInterface.generateDeviceTreeNodes(hIPCoreRefNode);
                validateCell=[validateCell,validateCellInterface];%#ok<AGROW>






                isRefNodeEmpty=(isempty(hIPCoreRefNode.Properties)&&isempty(hIPCoreRefNode.ChildNodes)&&isempty(hIPCoreRefNode.Comments));
                if~isRefNodeEmpty
                    hIPDeviceTree.addReferenceNode(hIPCoreRefNode);
                end
            end





            if generateAsOverlay
                hIPDeviceTree.printOverlaySource(obj.DeviceTreeSourceFilePath);
            else
                hIPDeviceTree.printSource(obj.DeviceTreeSourceFilePath);
            end













            [status,result]=obj.finishDeviceTreeGen(status,result);
        end

        function devTree=getDeviceTree(obj)
            devTree=obj.DeviceTreeSourceFileName;
        end
    end

    methods(Access=protected)
        function[status,result]=initDeviceTreeGen(obj,status,result)


            link=sprintf('<a href="matlab:open(''%s'')">%s</a>',obj.DeviceTreeSourceFilePath,obj.DeviceTreeSourceFilePath);
            msg=message('hdlcommon:workflow:DeviceTreeGenMsgGenerateDeviceTree',link);
            [status,result]=obj.publishMessage(msg,status,result);
        end

        function[status,result]=finishDeviceTreeGen(obj,status,result)



            if status
                [status,result]=obj.runCallbackPostDeviceTreeGen(status,result);
            end


            msg=message('hdlcommon:workflow:DeviceTreeGenMsgFinishDeviceTree');
            [status,result]=obj.publishMessage(msg,status,result);
        end

        function[status,result]=runCallbackPostDeviceTreeGen(obj,status,result)
            hDI=obj.hTurnkey.hD;

            [status2,log2]=hdlturnkey.plugin.runCallbackPostDeviceTreeGen(hDI);
            status=status&&status2;

            if~status&&obj.hTurnkey.hD.cmdDisplay
                msg=message('hdlcommon:workflow:ReferenceDesignPostDeviceTreeGenCallback',log2);
                error(msg);
            else
                [status,result]=obj.publishMessage(log2,status,result);
            end
        end

        function[status,result]=publishMessage(obj,msg,status,result)

            if isa(msg,'message')
                msg=msg.getString;
            end

            if isempty(msg)
                return;
            end

            hDI=obj.hTurnkey.hD;
            if hDI.cmdDisplay
                hdldisp(msg);
            else
                result=sprintf('%s\n%s',result,msg);
            end
        end
    end
end
