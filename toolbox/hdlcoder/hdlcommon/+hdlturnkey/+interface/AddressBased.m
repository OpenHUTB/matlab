

classdef(Abstract)AddressBased<hdlturnkey.interface.InterfaceBase


    properties(Hidden=true)


        hBaseAddr=[];
        hIPCoreAddr=[];
        hAddrManager=[];
    end

    properties(Access=protected)


        SoftResetHoldInBurstSignalNameList=[];
        SoftResetHoldResetPendingSignalList=[];

    end

    methods

        function obj=AddressBased(interfaceID)


            obj=obj@hdlturnkey.interface.InterfaceBase(interfaceID);




            obj.isFixedInWrapper=true;


            obj.initInterfaceAssignement;


            obj.HelpDocID='help.step.targetinterface.interfaceoptions';
        end

        function isa=isAddrBasedInterface(obj)%#ok<MANU>
            isa=true;
        end

        function addrUpperBound=getAddrUpperBound(obj)

            addrUpperBound=obj.hIPCoreAddr.AddressUpperBound*4+3;
        end

    end


    methods

        function initInterfaceAssignement(obj)



            obj.hBaseAddr=hdlturnkey.data.AddressList;
            obj.hIPCoreAddr=hdlturnkey.data.AddressList;
            obj.hAddrManager=hdlturnkey.data.AddressManager(obj.hIPCoreAddr);

        end

        function cleanInterfaceAssignment(obj,~)


            obj.hBaseAddr.cleanAssignment;
            obj.hIPCoreAddr.cleanAssignment;
        end

    end


    methods
        function hAddr=getBaseAddrWithName(obj,assignedPortName)
            hAddr=obj.hBaseAddr.getAddressWithName(assignedPortName);
        end

        function hAddr=getIPCoreAddrWithName(obj,assignedPortName)
            hAddr=obj.hIPCoreAddr.getAddressWithName(assignedPortName);
        end
    end


    methods

        function result=showInInterfaceChoice(obj,hTurnkey)




            result=hTurnkey.isDefaultBusInterfaceEmpty||...
            hTurnkey.isDefaultBusInterface(obj);
        end

        function assignBitRange(obj,portName,bitRangeStr,hTableMap)


            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            addrInternal=obj.parseBitRangeStr(hIOPort,bitRangeStr);



            bitRangeData=addrInternal;
            hTableMap.setBitRangeData(portName,bitRangeData);
        end

        function assignInterfaceOption(obj,portName,interfaceOpt,hTableMap)%#ok<*INUSD,*INUSL>

            obj.validateInterfaceOption(portName,interfaceOpt);

            hTableMap.setInterfaceOption(portName,interfaceOpt);
        end

        function addrInternal=parseBitRangeStr(obj,hIOPort,bitRangeStr)

            try
                [addrInternal,addrValue]=...
                hdlturnkey.data.Address.convertAddrStrToInternal(bitRangeStr);
            catch ME
                error(message('hdlcommon:workflow:InvalidAddressOffset',bitRangeStr));
            end


            addrLastTwoBit=bitsliceget(fi(addrValue,0,16,0),2,1);
            if addrLastTwoBit.data~=0
                error(message('hdlcommon:workflow:InvalidBitRangeMult4',bitRangeStr));
            end


            if addrInternal<obj.hIPCoreAddr.AddressLowerBound||...
                addrInternal>obj.hIPCoreAddr.AddressUpperBound
                error(message('hdlcommon:workflow:AddrOutOfRange',...
                hdlturnkey.data.Address.convertAddrInternalToStr(obj.hIPCoreAddr.AddressLowerBound),...
                hdlturnkey.data.Address.convertAddrInternalToStr(obj.hIPCoreAddr.AddressUpperBound)));
            end
        end

        function optionIDList=getInterfaceOptionList(obj,portName,hTableMap)

            optionIDList={};

            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);

            if(hIOPort.PortType==hdlturnkey.IOType.IN)
                if strcmp(hdlfeature('ExposeWriteSyncSignal'),'on')
                    optionIDList={'RegisterInitialValue','EnableReadback','WriteSync'};
                else
                    optionIDList={'RegisterInitialValue','EnableReadback'};
                end
            end
        end

        function optionValue=getInterfaceOptionValue(obj,portName,optionID)

            switch optionID
            case 'RegisterInitialValue'
                hAddr=obj.hIPCoreAddr.getAddressWithName(portName);
                optionValue=hAddr.InitValue;
            case 'EnableReadback'
                optionValue={'inherit','on','off'};
            case 'WriteSync'
                optionValue=0;
            otherwise
                optionValue=[];
            end
        end

        function optionStr=getInterfaceOptionStr(obj,optionID)


            switch optionID
            case 'RegisterInitialValue'
                optionStr='Register initial value';
            case 'EnableReadback'
                optionStr='Enable write register readback';
            case 'WriteSync'
                optionStr='Write sync';
            otherwise
                optionStr=optionID;
            end
        end

        function validatePortForInterface(obj,hIOPort,~)



            portWidth=hIOPort.WordLength;
            if portWidth>32
                error(message('hdlcommon:workflow:BaseBitWidthNotFit',obj.InterfaceID,hIOPort.PortName));
            end

        end

        function finishAssignInterface(obj,hTurnkey)



            if hTurnkey.isDefaultBusInterfaceEmpty||...
                ~hTurnkey.isDefaultBusInterface(obj)
                hTurnkey.setDefaultBusInterface(obj);
            end
        end

    end


    methods

        function bitrangeStr=getTableCellBitRangeStr(~,portName,hTableMap)

            addrInternal=hTableMap.getBitRangeData(portName);

            bitrangeStr=hdlturnkey.data.Address.convertAddrInternalToStr(addrInternal);
        end

    end


    methods

        function allocateUserSpecBitRange(obj,portName,hTableMap)



            bitRangeData=hTableMap.getBitRangeData(portName);
            addrStart=bitRangeData;


            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            portWordLength=hIOPort.WordLength;
            portVectorSize=hIOPort.Dimension;


            if hIOPort.isBus



                addrStart=addrStart(1);
                obj.hAddrManager.registerAddressForIOPort(hIOPort,portName,...
                hIOPort.Type,hIOPort.PortType,hTableMap,addrStart);
            else
                obj.hAddrManager.setUserAddressAssigned(addrStart,...
                portVectorSize,portWordLength,portName,hIOPort.PortType,hIOPort,hTableMap);
            end
        end

        function allocateUserSpecInterfaceOption(obj,portName,hTableMap)


            [initValue,initValueName]=obj.parseInterfaceOption(portName,hTableMap,'RegisterInitialValue','0');



            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);

            if hIOPort.isBus






                if~isstruct(initValue)&&initValue~=0
                    error(message('hdlcommon:workflow:InvalidInterfaceValueForBus','RegisterInitialValue'));
                end


                hAddrList=obj.hAddrManager.getAddressWithName(portName);
                hAddrCell=obj.hAddrManager.getAllAssignedAddressObj(hAddrList);

                if~isstruct(initValue)





                    for idx=1:length(hAddrCell)

                        initValue=obj.castToRegDatatype(initValue,hAddrCell{idx});
                        hAddrCell{idx}.InitValue=initValue;
                    end
                else






                    initValueMap=hdlturnkey.data.getAllFieldNamesAndValues(initValue);
                    initValueMapKeys=initValueMap.keys;




                    for idx=1:length(initValueMapKeys)
                        isAssignNewInitValue=false;
                        currMapKey=initValueMapKeys{idx};

                        flattenedInitValueFieldName=[portName,currMapKey];
                        for idy=1:length(hAddrCell)


                            hAddr=hAddrCell{idy};
                            currInitValue=initValueMap(currMapKey);
                            if strcmp(hAddr.DispFlattenedPortName,flattenedInitValueFieldName)



                                downstream.tool.checkValueWithinRange(currInitValue,...
                                hAddr.DataType,...
                                flattenedInitValueFieldName);


                                currInitValue=obj.castToRegDatatype(currInitValue,hAddr);
                                hAddrCell{idy}.InitValue=currInitValue;
                                hAddrCell{idy}.FlattenedInitValueName=[initValueName,currMapKey];
                                isAssignNewInitValue=true;
                            end
                        end
                        if~isAssignNewInitValue
                            error(message('hdlcommon:workflow:InvalidInterfaceValueForBusMember',...
                            'RegisterInitialValue',currMapKey(2:end),initValueName,portName));
                        end
                    end
                end

            else




                if(isequal(initValue,0)&&hIOPort.isVector)
                    initValue=zeros(1,hIOPort.Dimension);
                end

                downstream.tool.checkValueWithinRange(initValue,hIOPort,'RegisterInitialValue');

                initValue=obj.castToPortDatatype(initValue,hIOPort);


                hAddr=obj.hIPCoreAddr.getAddressWithName(portName);
                hAddr.InitValue=initValue;
            end

        end


        function allocateDefaultBitRange(obj,portName,hTableMap)





            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);


            addrStart=obj.hAddrManager.registerAddressForIOPort(hIOPort,portName,...
            hIOPort.Type,hIOPort.PortType,hTableMap);


            bitRangeData=addrStart;
            hTableMap.setBitRangeData(portName,bitRangeData);
        end
    end


    methods(Abstract)



        elaborate(obj,hN,hElab)
    end

    methods

        function connectInterfacePort(obj,hN,hElab,hIPSignals)



            scheduleDUTAddrElab(obj,hElab);


            topInSignals=hIPSignals.hInportSignals;
            topOutSignals=hIPSignals.hOutportSignals;
            hAddrLists=[obj.hBaseAddr,obj.hIPCoreAddr];
            networkName=sprintf('%s_addr_decoder',hElab.TopNetName);
            pirtarget.getAddrDecoderNetwork(...
            hN,topInSignals,topOutSignals,hElab,hAddrLists,networkName);


        end

        function scheduleDUTAddrElab(obj,hElab)



            hAddrCell=obj.hAddrManager.getAllAssignedAddressObj;
            for ii=1:length(hAddrCell)

                hAddr=hAddrCell{ii};
                if~hAddr.Assigned
                    continue;
                end

                if hAddr.isDUTAddress







                    portName=hAddr.AssignedPortName;
                    flattenedPortName=hAddr.FlattenedPortName;


                    hDUTPortSignals=hElab.getCodegenPirSignalForPort(portName);



                    if~strcmp(hAddr.AssignedPortName,hAddr.FlattenedPortName)




                        hDUTPortSignalsMap=containers.Map();
                        for idx=1:length(hDUTPortSignals)
                            hDUTPortSignalsMap(hDUTPortSignals{idx}.Name)=hDUTPortSignals{idx};
                        end


                        codegenPortName=hElab.getCodegenPortNameFromAddrFlattenedPortName(hAddr.FlattenedPortName);
                        hDUTPortSignals={};
                        for idx=1:hAddr.PortVectorSize
                            matchedName=sprintf('%s_sig',codegenPortName{idx});
                            hDUTPortSignals{end+1}=hDUTPortSignalsMap(matchedName);%#ok<AGROW>
                        end
                    end


                    portNameStr=regexprep(flattenedPortName,'\W+','_');
                    hAddr.DescName=sprintf('%s_Data',portNameStr);
                    if hAddr.AssignedPortType==hdlturnkey.IOType.IN

                        hAddr.assignScheduledElab(hDUTPortSignals,hdlturnkey.data.DecoderType.WRITE)
                        hAddr.Description=sprintf('data register for Inport %s',flattenedPortName);
                    else

                        hAddr.assignScheduledElab(hDUTPortSignals,hdlturnkey.data.DecoderType.READ)
                        hAddr.Description=sprintf('data register for Outport %s',flattenedPortName);

                    end

                    if hAddr.RequestStrobePort
                        hStrobeSignal=hElab.getCodegenPirSignal(hAddr.AsssignedStrobePortName);
                        hAddr.assignStrobeSignal(hStrobeSignal);
                    end

                end
            end
        end

        function elaborateSoftResetLogic(obj,hN,hElab,waddr_sel,wr_enb,wdata,reset,reset_internal)


            ufix1Type=pir_ufixpt_t(1,0);

            hAddr=obj.hBaseAddr.getAddressWithType(hdlturnkey.data.AddrType.RESET);
            addrNum=hAddr.AddressStart;


            strobe_addr=hN.addSignal(ufix1Type,'strobe_addr');
            pirelab.getCompareToValueComp(hN,waddr_sel,strobe_addr,'==',addrNum);


            strobe_sel=hN.addSignal(ufix1Type,'strobe_sel');
            pirelab.getBitwiseOpComp(hN,[strobe_addr,wr_enb],strobe_sel,'AND');


            strobe_in=hN.addSignal(ufix1Type,'strobe_in');
            pirelab.getBitSliceComp(hN,wdata,strobe_in,0,0);


            const_zero=hN.addSignal(ufix1Type,'const_zero');
            pirelab.getConstComp(hN,const_zero,0);
            strobe_sw=hN.addSignal(ufix1Type,'strobe_sw');
            pirelab.getSwitchComp(hN,[strobe_in,const_zero],...
            strobe_sw,strobe_sel,'decode_switch','~=');


            soft_reset=hN.addSignal(ufix1Type,'soft_reset');
            pirelab.getUnitDelayComp(hN,strobe_sw,soft_reset);



            if obj.SoftResetHoldInBurstSignalNameList.isempty

                soft_reset_temp=soft_reset;
            else



                soft_reset_pending=hN.addSignal(ufix1Type,'soft_reset_pending');
                hElab.setInternalSignal('soft_reset_pending',soft_reset_pending);



                resetPendingLength=obj.SoftResetHoldResetPendingSignalList.length;
                resetPendingSignalList=obj.SoftResetHoldResetPendingSignalList.values;
                for ii=1:resetPendingLength
                    resetPendingSignal=resetPendingSignalList{ii};
                    hElab.connectSignalFrom('soft_reset_pending',resetPendingSignal);
                end



                in_burst_out=[];
                inBurstLength=obj.SoftResetHoldInBurstSignalNameList.length;
                inBurstNameList=obj.SoftResetHoldInBurstSignalNameList.keys;
                for ii=1:inBurstLength
                    inBurstSignalName=inBurstNameList{ii};
                    if ii==1
                        in_burst_out=hN.addSignal(ufix1Type,inBurstSignalName);
                        hElab.connectSignalFrom(inBurstSignalName,in_burst_out);

                    else
                        in_burst_temp=hN.addSignal(ufix1Type,inBurstSignalName);
                        hElab.connectSignalFrom(inBurstSignalName,in_burst_temp);


                        in_burst_out_existing=in_burst_out;
                        in_burst_out=hN.addSignal(ufix1Type,'in_burst_out');
                        pirelab.getBitwiseOpComp(hN,...
                        [in_burst_out_existing,in_burst_temp],in_burst_out,'OR');
                    end
                end


                soft_reset_temp=hN.addSignal(ufix1Type,'soft_reset_after_hold');
                obj.elaborateResetHoldLogic(hN,hElab,[soft_reset,in_burst_out],[soft_reset_temp,soft_reset_pending]);
            end


            pirelab.getBitwiseOpComp(hN,[reset,soft_reset_temp],reset_internal,'OR');

        end

        function elaborateResetHoldLogic(obj,hN,hElab,hInSignals,hOutSignals)%#ok<INUSL>



            ufix1Type=pir_ufixpt_t(1,0);


            hResetHoldNet=pirelab.createNewNetwork(...
            'PirInstance',hElab.BoardPirInstance,...
            'Network',hN,...
            'Name',sprintf('%s_reset_hold',hElab.TopNetName)...
            );


            hIPPortSignal=pirelab.addIOPortToNetwork(...
            'Network',hResetHoldNet,...
            'InportNames',{'reset_in','in_burst'},...
            'InportWidths',{1,1},...
            'OutportNames',{'reset_out','reset_pending'},...
            'OutportWidths',{1,1});

            hIPInportSignals=hIPPortSignal.hInportSignals;
            hIPOutportSignals=hIPPortSignal.hOutportSignals;


            port_reset_in=hIPInportSignals(1);
            port_in_burst=hIPInportSignals(2);
            port_reset_out=hIPOutportSignals(1);
            port_reset_pending=hIPOutportSignals(2);


            [~,clkenb,~]=hResetHoldNet.getClockBundle(port_reset_in,1,1,0);
            const_1=hResetHoldNet.addSignal(ufix1Type,'const_1');
            pirelab.getConstComp(hResetHoldNet,const_1,1);
            pirelab.getWireComp(hResetHoldNet,const_1,clkenb);


            hResetHoldNet.addComponent2(...
            'kind','cgireml',...
            'Name',sprintf('reset_hold_module'),...
            'InputSignals',[port_reset_in,port_in_burst],...
            'OutputSignals',[port_reset_out,port_reset_pending],...
            'EMLFileName','hdleml_reset_hold'...
            );


            pirelab.instantiateNetwork(hN,hResetHoldNet,hInSignals,...
            hOutSignals,sprintf('%s_reset_hold_inst',hElab.TopNetName));

        end

        function initSoftResetHoldElab(obj)

            obj.SoftResetHoldInBurstSignalNameList=containers.Map();
            obj.SoftResetHoldResetPendingSignalList=containers.Map();
        end

        function addSoftResetHoldInBurstSignal(obj,inBurstSignalName)


            if~obj.SoftResetHoldInBurstSignalNameList.isKey(inBurstSignalName)
                obj.SoftResetHoldInBurstSignalNameList(inBurstSignalName)=true;
            end
        end

        function addSoftResetHoldResetPendingSignal(obj,inBurstSignalName,hSignal)


            if~obj.SoftResetHoldResetPendingSignalList.isKey(inBurstSignalName)
                obj.SoftResetHoldResetPendingSignalList(inBurstSignalName)=hSignal;
            end
        end

    end


    methods

    end

end



