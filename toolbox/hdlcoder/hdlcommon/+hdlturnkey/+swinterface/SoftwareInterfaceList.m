


classdef SoftwareInterfaceList<hdlturnkey.interface.InterfaceListBase


    properties(Access=protected)

        hTurnkey=[];
    end

    properties(SetAccess=protected)

    end

    methods

        function obj=SoftwareInterfaceList(hTurnkey)

            obj=obj@hdlturnkey.interface.InterfaceListBase();

            obj.hTurnkey=hTurnkey;
        end

        function initInterfaceList(obj)


            obj.clearInterfaceList;
        end

        function finalizeInterfaceList(obj)

        end


        function updateInterfaceList(obj)


            obj.initInterfaceList;


            interfaceIDList=obj.hTurnkey.getSupportedInterfaceIDList;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hFPGAInterface=obj.hTurnkey.getInterface(interfaceID);

                if(hFPGAInterface.isInterfaceInUse(obj.hTurnkey))
                    hSoftwareInterface=hFPGAInterface.getSoftwareInterface(obj.hTurnkey);

                    hSoftwareInterface.populateAssignedPorts(obj.hTurnkey);

                    obj.addInterface(hSoftwareInterface);
                end
            end

            obj.finalizeInterfaceList;
        end

        function registerDeviceTreeNames(obj,ipDeviceName)

            hNameService=hdlturnkey.backend.UniqueNameService;


            interfaceIDList=obj.getInterfaceIDList;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=obj.getInterface(interfaceID);
                hInterface.registerDeviceTreeNames(hNameService,ipDeviceName);
            end
        end


        function updateHostInterfaceList(obj)


            obj.initInterfaceList;


            interfaceIDList=obj.hTurnkey.getSupportedInterfaceIDList;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hFPGAInterface=obj.hTurnkey.getInterface(interfaceID);

                if(hFPGAInterface.isInterfaceInUse(obj.hTurnkey))
                    hHostInterface=hFPGAInterface.getHostInterface(obj.hTurnkey);
                    hHostInterface.populateAssignedPorts(obj.hTurnkey);
                    obj.addInterface(hHostInterface);
                end
            end

            obj.finalizeInterfaceList;
        end

        function isAll=isAllInterfaceEmpty(obj)

            isAll=true;
            interfaceIDList=obj.getInterfaceIDList;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hSoftwareInterface=obj.hTurnkey.getInterface(interfaceID);
                if~hSoftwareInterface.isEmptyInterface
                    isAll=false;
                    break;
                end
            end
        end

    end

end