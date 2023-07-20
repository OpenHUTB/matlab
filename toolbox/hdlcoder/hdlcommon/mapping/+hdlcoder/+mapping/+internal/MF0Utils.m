classdef MF0Utils




    methods(Static)
        function ipcore=createDefaultIPCore(mf0Model,ipCoreName)
            transaction=mf0Model.beginRevertibleTransaction;


            ipcore=hdl.ip.component.IPCore(mf0Model);


            ipcore.Name=ipCoreName;









            memMap=ipcore.createIntoMemoryMaps;
            systemBlock=memMap.createIntoAddressBlocks;
            systemBlock.Usage='SYSTEM';
            systemBlock.Range=0x100;
            userBlock=memMap.createIntoAddressBlocks;
            userBlock.Usage='USER';
            userBlock.Range=double(0x10000)-double(systemBlock.Range);
            ipcore.DefaultMemoryMap=memMap;


            hdlcoder.mapping.internal.MF0Utils.enableAXI4RegisterInterface(ipcore);


            hdlcoder.mapping.internal.MF0Utils.addAXI4StreamInterface(ipcore);


            hdlcoder.mapping.internal.MF0Utils.addAXI4ManagerInterface(ipcore);

            transaction.commit();
        end

        function enableAXI4RegisterInterface(ipcore)
            if~isempty(ipcore.DefaultMemoryMappedInterface)
                return;
            end

            mf0Model=mf.zero.getModel(ipcore);
            transaction=mf0Model.beginRevertibleTransaction;

            type=hdlcoder.mapping.internal.MF0Utils.getAXI4InterfaceDefinition(mf0Model);
            defaultName="AXI4 Register";
            name=matlab.lang.makeUniqueStrings(defaultName,ipcore.getBusInterfaceNames);

            busInterface=hdl.ip.component.BusInterface.createBusInterface(mf0Model,name,"TARGET",type);
            busInterface.Mode.MemoryMapRef=ipcore.DefaultMemoryMap;

            ipcore.insertBusInterfaceAt(busInterface,1);

            transaction.commit();
        end

        function disableAXI4RegisterInterface(ipcore)
            mf0Model=mf.zero.getModel(ipcore);
            transaction=mf0Model.beginRevertibleTransaction;

            ipcore.DefaultMemoryMappedInterface.destroy;

            transaction.commit();
        end

        function addAXI4StreamInterface(ipcore,name)
            mf0Model=mf.zero.getModel(ipcore);
            transaction=mf0Model.beginRevertibleTransaction;


            type=hdlcoder.mapping.internal.MF0Utils.getAXI4StreamInterfaceDefinition(mf0Model);
            if nargin<2
                defaultName=type.Name;
                tgtName=matlab.lang.makeUniqueStrings(defaultName+" Receiver",ipcore.getBusInterfaceNames);
                initName=matlab.lang.makeUniqueStrings(defaultName+" Transmitter",ipcore.getBusInterfaceNames);
            else
                tgtName=name+" Receiver";
                initName=name+" Transmitter";
            end

            tgtInterface=ipcore.addNewBusInterface(tgtName,"TARGET",type);
            initInterface=ipcore.addNewBusInterface(initName,"INITIATOR",type);
            tgtInterface.Mode.DownstreamInterfaces.add(initInterface.Mode);

            transaction.commit();
        end

        function addAXI4ManagerInterface(ipcore,name)
            mf0Model=mf.zero.getModel(ipcore);
            transaction=mf0Model.beginRevertibleTransaction;

            type=hdlcoder.mapping.internal.MF0Utils.getAXI4InterfaceDefinition(mf0Model);
            if nargin<2
                defaultName=type.Name+" Manager";
                name=matlab.lang.makeUniqueStrings(defaultName,ipcore.getBusInterfaceNames);
            end

            ipcore.addNewBusInterface(name,"INITIATOR",type);

            transaction.commit();
        end

        function hB=createBoardPluginFromIPCoreDataModel(ipcore)

            hB=hdlcoder.Board('IsGenericIPPlatform',true);


            hB.BoardName=sprintf('Generic Platform for IP Core %s',ipcore.Name);


            hB.hClockModule=hdlturnkey.ClockModuleIP('IsGenericIP',true);


            hB.addInterface(hdlturnkey.interface.InterfaceExternal());


            for busInterface=ipcore.BusInterfaces.toArray
                hInterface=[];
                switch busInterface.InterfaceType.InterfaceDefinitionRef.Name
                case 'AXI4-Lite'
                    if busInterface.ModeType=="TARGET"
                        assert(~isempty(busInterface.MemoryMap),'Expected interface to have a memory map.');
                        hInterface=hdlturnkey.interface.AXI4Lite(IsGenericIP=true,InterfaceID=busInterface.Name);
                    end
                case 'AXI4'
                    if busInterface.ModeType=="INITIATOR"
                        hInterface=hdlturnkey.interface.AXI4Master(IsGenericIP=true,InterfaceID=busInterface.Name);
                    elseif busInterface.ModeType=="TARGET"
                        assert(~isempty(busInterface.MemoryMap),'Expected interface to have a memory map.');
                        hInterface=hdlturnkey.interface.AXI4(IsGenericIP=true,InterfaceID=busInterface.Name);
                    end
                case 'AXI4-Stream'
                    if busInterface.ModeType=="INITIATOR"
                        hInterface=hdlturnkey.interface.AXI4Stream(IsGenericIP=true,SlaveChannelEnable=false,InterfaceID=busInterface.Name);
                    elseif busInterface.ModeType=="TARGET"
                        hInterface=hdlturnkey.interface.AXI4Stream(IsGenericIP=true,MasterChannelEnable=false,InterfaceID=busInterface.Name);
                    end
                case 'AXI4-Stream Video'
                    if busInterface.ModeType=="INITIATOR"
                        hInterface=hdlturnkey.interface.AXI4StreamVideo(IsGenericIP=true,SlaveChannelEnable=false,InterfaceID=busInterface.Name);
                    elseif busInterface.ModeType=="TARGET"
                        hInterface=hdlturnkey.interface.AXI4StreamVideo(IsGenericIP=true,MasterChannelEnable=false,InterfaceID=busInterface.Name);
                    end
                end

                if isempty(hInterface)
                    error('Unexpected interface "%s" on IP core port "%s".',busInterface.InterfaceType.InterfaceDefinitionRef.Name,busInterface.Name);
                end
                hB.addInterface(hInterface);
            end
        end

    end

    methods(Static,Access=private)
        function axistream=getAXI4StreamInterfaceDefinition(mf0Model)

            dataElem=hdl.ip.interfacedef.InterfaceElement(mf0Model);
            dataElem.Name="Data";
            onInit=dataElem.createIntoOnInitiator;
            onInit.Presence="REQUIRED";
            onInit.Direction="OUT";
            onTgt=dataElem.createIntoOnTarget;
            onTgt.Presence="REQUIRED";
            onTgt.Direction="IN";


            validElem=hdl.ip.interfacedef.InterfaceElement(mf0Model);
            validElem.Name="Valid";
            onInit=validElem.createIntoOnInitiator;
            onInit.Presence="REQUIRED";
            onInit.Direction="OUT";
            onInit.Width=uint64(1);
            onTgt=validElem.createIntoOnTarget;
            onTgt.Presence="REQUIRED";
            onTgt.Direction="IN";
            onTgt.Width=uint64(1);


            readyElem=hdl.ip.interfacedef.InterfaceElement(mf0Model);
            readyElem.Name="Ready";
            onInit=readyElem.createIntoOnInitiator;
            onInit.Presence="OPTIONAL";
            onInit.Direction="IN";
            onInit.Width=uint64(1);
            onTgt=readyElem.createIntoOnTarget;
            onTgt.Presence="OPTIONAL";
            onTgt.Direction="OUT";
            onTgt.Width=uint64(1);


            tlastElem=hdl.ip.interfacedef.InterfaceElement(mf0Model);
            tlastElem.Name="TLAST";
            onInit=tlastElem.createIntoOnInitiator;
            onInit.Presence="OPTIONAL";
            onInit.Direction="OUT";
            onInit.Width=uint64(1);
            onTgt=tlastElem.createIntoOnTarget;
            onTgt.Presence="OPTIONAL";
            onTgt.Direction="IN";
            onTgt.Width=uint64(1);


            axistream=hdl.ip.interfacedef.InterfaceDefinition(mf0Model);
            axistream.Name="AXI4-Stream";
            axistream.addInterfaceElement(dataElem);
            axistream.addInterfaceElement(validElem);
            axistream.addInterfaceElement(readyElem);

        end

        function axi4=getAXI4InterfaceDefinition(mf0Model)
            axi4=hdl.ip.interfacedef.InterfaceDefinition(mf0Model);
            axi4.IsAddressable=true;
            axi4.Name='AXI4';
        end
    end
end



