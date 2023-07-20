


classdef BoardElaboration<handle


    properties

        hDUTLayer=[];
        hBitPackLayer=[];
        hProtocolLayer=[];


        BoardPirInstance=[];


        hIntSigMgr=[];


        hNameService=[];


        TopNetName='';


        PCIAddrSignals={};
        PCIWrEnbSignals={};
    end

    properties


        hTurnkey=[];

    end

    methods

        function obj=BoardElaboration(hTurnkey)


            obj.hTurnkey=hTurnkey;

            obj.hDUTLayer=hdlturnkey.elab.DUTLayer(obj);

            obj.hProtocolLayer=hdlturnkey.elab.ProtocolLayer(obj);

            obj.hIntSigMgr=hdlturnkey.elab.InternalSignalManager;

        end

        function hN=elaborateBoard(obj)


            obj.hTurnkey.resolveDefaultBusInterface;


            initSignalAndAddress(obj);


            if obj.hTurnkey.hD.isIPCoreGen

                if obj.hTurnkey.hD.hIP.hasCustomIPTopHDLFile

                    obj.TopNetName=sprintf('%s_int',obj.hTurnkey.hD.hIP.getIPCoreName);
                else

                    obj.TopNetName=obj.hTurnkey.hD.hIP.getIPCoreName;
                end

                if~obj.hNameService.isDistinguishName(lower(obj.TopNetName))


                    error(message('hdlcommon:workflow:IPNameConflict',obj.TopNetName));
                end
            else
                topNetNamePostfix=obj.hTurnkey.hBoard.TopLevelNamePostfix;
                obj.TopNetName=sprintf('%s_%s',getDUTCompName(obj),topNetNamePostfix);
            end


            hN=createTopLevelNetwork(obj);


            elaborateClockModuleNetwork(obj,hN);


            elaborateDUTLayer(obj,hN);





            elaborateProtocolLayer(obj,hN);


            elaborateInterface(obj,hN);

        end

        function registerDefaultBusAddress(obj)













            obj.hTurnkey.resolveDefaultBusInterface;


            hBus=getDefaultBusInterface(obj);






            hBus.hBaseAddr.setLockStatus(false);


            hBus.hBaseAddr.cleanAssignment;








            interfaceIDList=obj.hTurnkey.getSupportedInterfaceIDList;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};

                if skipInterface(obj,interfaceID)
                    continue;
                end
                hInterface=obj.hTurnkey.getInterface(interfaceID);
                hInterface.registerAddress(obj);
            end







            obj.hProtocolLayer.registerAddressAuto;




            interfaceIDList=obj.hTurnkey.getSupportedInterfaceIDList;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};

                if skipInterface(obj,interfaceID)
                    continue;
                end
                hInterface=obj.hTurnkey.getInterface(interfaceID);
                hInterface.registerAddressAuto(obj);
            end



            hAddr=hBus.hBaseAddr.registerAddressAuto('ip_timestamp',hdlturnkey.data.AddrType.TIMESTAMP,hdlturnkey.IOType.OUT);
            hAddr.DescName='IPCore_Timestamp';
            hAddr.Description=sprintf('contains unique IP timestamp (yymmddHHMM)');





            hBus.hBaseAddr.setLockStatus(true);


        end

    end

    methods(Access=protected,Hidden=true)

        function initSignalAndAddress(obj)



            obj.hIntSigMgr.initialSignalMap;

            obj.PCIAddrSignals={};
            obj.PCIWrEnbSignals={};


            interfaceIDList=obj.hTurnkey.getSupportedInterfaceIDList;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};

                if skipInterface(obj,interfaceID)
                    continue;
                end
                hInterface=obj.hTurnkey.getInterface(interfaceID);
                hInterface.initializeInterfaceElaborationBegin;
            end


            hBus=getDefaultBusInterface(obj);
            if~hBus.isEmptyAXI4SlaveInterface

                hBus.initSoftResetHoldElab;
            end

        end

        function elaborateInterface(obj,hN)

            interfaceIDList=obj.hTurnkey.getSupportedInterfaceIDList;


            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=obj.hTurnkey.getInterface(interfaceID);


                if skipInterface(obj,interfaceID)
                    continue;
                end


                if hInterface.isAddrBasedInterface
                    if obj.hTurnkey.isDefaultBusInterface(hInterface)
                        continue;
                    else

                        error(message('hdlcommon:workflow:OneAddrBasedOnly'));
                    end
                end





                hInterface.elaborate(hN,obj);

            end



            hDI=obj.hTurnkey.hD;
            if hDI.isIPCoreGen
                elaborateVersionRegister(obj,hN);
            end



            hBus=getDefaultBusInterface(obj);


            hBus.elaborate(hN,obj);
        end

        function hN=createTopLevelNetwork(obj)

            hN=pirelab.createNewNetwork(...
            'PirInstance',obj.BoardPirInstance,...
            'Network','',...
            'Name',obj.TopNetName);


            obj.BoardPirInstance.setTopNetwork(hN);

        end

        function elaborateClockModuleNetwork(obj,hN)

            hDI=obj.hTurnkey.hD;
            hClockModule=hDI.getClockModule;

            hBus=getDefaultBusInterface(obj);
            hClockModule.InternalReset=~hBus.isEmptyAXI4SlaveInterface;

            hClockModule.elaborateClockModule(hN,obj)
        end

        function elaborateDUTLayer(obj,hN)

            obj.hDUTLayer.elaborateDUTLayer(hN);
        end

        function elaborateBitPackingLayer(obj,hN)

            obj.hBitPackLayer.elaborateBitPackingLayer(hN);
        end

        function elaborateProtocolLayer(obj,hN)

            obj.hProtocolLayer.elaborateProtocolLayer(hN);
        end

        function elaborateVersionRegister(obj,hN)

            hBus=obj.getDefaultBusInterface;


            if~hBus.isEmptyAXI4SlaveInterface

                ufix32Type=pir_ufixpt_t(32,0);
                ip_timestamp=hN.addSignal(ufix32Type,'ip_timestamp');


                hIP=obj.hTurnkey.hD.hIP;
                hIP.setTimestamp;
                pirelab.getConstComp(hN,ip_timestamp,uint32(hIP.getTimestampNum));


                hAddr=hBus.getBaseAddrWithName('ip_timestamp');
                hAddr.assignScheduledElab(ip_timestamp,hdlturnkey.data.DecoderType.READ)


                hAddr.Description=sprintf('%s: %d',hAddr.Description,uint32(hIP.getTimestampNum));
            end
        end

    end


    methods

        function getDUTCodeGenPIRInfo(obj)

            obj.hDUTLayer.getDUTCodeGenPIRInfo;
        end

        function name=getDUTCompName(obj)
            name=obj.hDUTLayer.DUTCompName;
        end

        function codegenPortNames=getCodegenPortNameList(obj,modelPortName)





            codegenPortNames=obj.hDUTLayer.getCodegenPortNameList(modelPortName);
        end

        function codegenPortSignal=getCodegenPirSignal(obj,codegenPortName)


            codegenPortSignal=obj.hDUTLayer.getCodegenPirSignal(codegenPortName);
        end

        function codegenPortSignals=getCodegenPirSignalForPort(obj,modelPortName)


            codegenPortSignals=obj.hDUTLayer.getCodegenPirSignalForPort(modelPortName);
        end

        function codegenPortName=getCodegenPortNameFromAddrFlattenedPortName(obj,addrFlattenedPortName)


            codegenPortName=obj.hDUTLayer.getCodegenPortNameFromAddrFlattenedPortName(addrFlattenedPortName);
        end


        function hInterface=getDefaultBusInterface(obj)
            hInterface=obj.hTurnkey.getDefaultBusInterface;
        end


        function isa=isInternalSignalDefined(obj,id)
            isa=obj.hIntSigMgr.isInternalSignalDefined(id);
        end
        function setInternalSignal(obj,id,hIntSig)
            obj.hIntSigMgr.setInternalSignal(id,hIntSig);
        end
        function hIntSig=getInternalSignal(obj,id)
            hIntSig=obj.hIntSigMgr.getInternalSignal(id);
        end
        function connectSignalFrom(obj,id,hFromSig)
            obj.hIntSigMgr.connectSignalFrom(id,hFromSig);
        end
        function connectSignalTo(obj,id,hGotoSig)
            obj.hIntSigMgr.connectSignalTo(id,hGotoSig);
        end


        function skip=skipInterface(obj,interfaceID)







            hInterface=obj.hTurnkey.getInterface(interfaceID);

            skip=~hInterface.isInterfaceInUse(obj.hTurnkey)&&...
            ~hInterface.isConstrainAttached;
        end


        function initNameUniquification(obj)



            obj.hNameService=coder.internal.lib.DistinctNameService();


            hCodeGen=obj.hTurnkey.hD.hCodeGen;
            dutFileList=hCodeGen.DUTCodeGenSrcFileList;
            for ii=1:length(dutFileList)
                dutFileName=dutFileList{ii};
                [~,nameStr,~]=fileparts(dutFileName);
                obj.hNameService.distinguishName(lower(nameStr));
            end
        end
        function verifyNameUniquification(obj)





            turnkeyFileList=obj.hTurnkey.TurnkeyFileList;
            hCodeGen=obj.hTurnkey.hD.hCodeGen;
            for ii=1:length(turnkeyFileList)
                turnkeyFileName=turnkeyFileList{ii};
                [~,nameStr,extStr]=fileparts(turnkeyFileName);
                if strcmpi(extStr,hCodeGen.getVHDLExt)||strcmpi(extStr,hCodeGen.getVerilogExt)
                    if~obj.hNameService.isDistinguishName(lower(nameStr))
                        error(message('hdlcommon:workflow:WrapperNameConflict',turnkeyFileName));
                    end
                end
            end
        end

    end


end


