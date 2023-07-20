


classdef(Abstract)AXI4StreamBase<hdlturnkey.interface.ChannelBased&...
    hdlturnkey.interface.IPWorkflowBase


    properties(GetAccess=public,SetAccess=protected)





        MasterChannelEnable=true;
        SlaveChannelEnable=true;



        MasterChannelConnection='';
        SlaveChannelConnection='';
        MasterChannelDataWidth=0;
        SlaveChannelDataWidth=0;

        MasterChannelMaxDataWidth=4096;
        SlaveChannelMaxDataWidth=4096;

    end

    properties(Hidden=true,SetAccess=protected)





        MasterChannelNumber=0;
        SlaveChannelNumber=0;


        InterfacePortLabel='';

    end

    properties(Access=protected)


        RamCorePrefix='';

    end

    properties(Hidden=true)



        TDATAMaxWidth=128;
        TSTRBMaxWidth=16;
        TKEEPMaxWidth=16;
        TIDMaxWidth=8;
        TDESTMaxWidth=4;
        TUSERMaxWidth=128;


        DefaultPacketSize=1024;


        SamplePackingDimension='None';
        PackingMode='Bit Aligned';
        isMaxDataWidthDefined=false;


        FIFOSize=4;
        FIFOName='fifo';
        ReadyToValidLatency=1;

    end

    methods

        function obj=AXI4StreamBase(interfaceID)

            obj=obj@hdlturnkey.interface.ChannelBased(interfaceID);


            obj.InterfaceType=hdlturnkey.IOType.INOUT;


            obj.HelpDocID='help.step.AXI4Stream.targetinterfaceoptions';
        end

        function assignPropertyValueShared(obj,p)


            inputArgs=p.Results;

            propsWithUserDefinedValues=setdiff(p.Parameters,p.UsingDefaults);

            isChannelNumberDefined=~isempty(intersect(propsWithUserDefinedValues,{'MasterChannelNumber','SlaveChannelNumber'}));

            isChannelEnableDefined=~isempty(intersect(propsWithUserDefinedValues,{'MasterChannelEnable','SlaveChannelEnable'}));
























            if isChannelNumberDefined&&isChannelEnableDefined
                error(message('hdlcommon:interface:ChannelNumberEnableDefined'));
            elseif isChannelNumberDefined
                inputArgs.MasterChannelEnable=boolean(inputArgs.MasterChannelNumber);
                inputArgs.SlaveChannelEnable=boolean(inputArgs.SlaveChannelNumber);
            else
                inputArgs.MasterChannelNumber=double(inputArgs.MasterChannelEnable);
                inputArgs.SlaveChannelNumber=double(inputArgs.SlaveChannelEnable);
            end


            obj.isMaxDataWidthDefined=~isempty(intersect(propsWithUserDefinedValues,{'MasterChannelMaxDataWidth','SlaveChannelMaxDataWidth'}));

            isDataWidthDefined=~isempty(intersect(propsWithUserDefinedValues,{'MasterChannelDataWidth','SlaveChannelDataWidth'}));


            if obj.isMaxDataWidthDefined&&isDataWidthDefined
                error(message('hdlcommon:interface:DataWidthandMaxDataWidthCoexist'));
            end

            for ii=1:numel(obj.InputPropertyList)
                prop=obj.InputPropertyList{ii};
                propName=prop{1};
                if strcmpi(propName,'InterfaceID')
                    continue;
                end
                obj.(propName)=inputArgs.(propName);
            end



            if obj.IsGenericIP
                obj.IsRequired=false;
            end


            if isempty(obj.InterfacePortLabel)
                obj.InterfacePortLabel=regexprep(obj.InterfaceID,'[\W]*','_');
            end
        end

        function isa=isAXI4StreamBasedInterface(~)
            isa=true;
        end

        function isAssigned=isReadyPortAssigned(obj,channelID)
            hChannel=obj.hChannelList.getChannel(channelID);
            isAssigned=hChannel.isReadyPortAssigned;
        end

        function isAssigned=isTLASTPortAssignedMaster(obj)
            isAssigned=false;
            hChannelList=obj.getAssignedChannelIDList();
            for ii=1:length(hChannelList)

                hChannel=obj.hChannelList.getChannel(hChannelList{ii});
                if(hChannel.ChannelDirType==hdlturnkey.IOType.OUT)
                    isAssigned=hChannel.isTLASTPortAssigned;
                end
            end
        end
    end


    methods

    end


    methods

        function assignInterface(obj,portName,interfaceStr,hTableMap)

            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);


            hChannel=obj.hChannelList.getStreamChannel(interfaceStr);


            obj.validatePortForInterfaceShared(hIOPort,hTableMap,interfaceStr);
            obj.validatePortForInterface(hIOPort,hTableMap,interfaceStr);



            previousObj=hTableMap.getInterface(portName);
            if isequal(obj,previousObj)
                previousChannel=obj.hChannelList.getChannelFromPortName(portName);
                if isequal(hChannel,previousChannel)
                    return;
                end
            end

            hTableMap.setInterface(portName,obj);

            hTableMap.initialBitRangeData(portName);


            obj.hChannelList.assignChannel(portName,hChannel);
        end

        function assignBitRange(obj,portName,bitRangeStr,hTableMap)


            obj.hChannelList.validateSubPort(portName,bitRangeStr,hTableMap);

            obj.hChannelList.assignSubPort(portName,bitRangeStr,hTableMap);
            hTableMap.setBitRangeData(portName,bitRangeStr);
        end
    end


    methods

    end


    methods

    end


    methods

        function initializeInterfaceElaborationBegin(obj)



            initializeInterfaceElaborationBegin@hdlturnkey.interface.ChannelBased(obj);


            channelIDlist=obj.hChannelList.getAssignedChannels;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);


                hChannel.NeedAutoReadyWiring=false;

            end
        end

        function elaborate(obj,hN,hElab)







            if~hElab.hTurnkey.hStream.isAutoReadyDisabled
                obj.scheduleAutoWiring;
            end


            obj.RamCorePrefix=sprintf('%s_',hElab.TopNetName);



            channelIDlist=obj.hChannelList.getAssignedChannels;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);
                hChannelDir=hChannel.ChannelDirType;




                [multiRateCountEnable,multiRateCountValue]=hChannel.getMultiRateInfo(hElab.hDUTLayer,channelID,hChannelDir);
                obj.elaborateStreamModule(hN,hElab,hChannel,multiRateCountEnable,multiRateCountValue);
            end

        end

    end

    methods


        [isNeeded,dut_enb_signal]=scheduleDUTEnableWiring(obj,hN,hElab)

    end

    methods(Access=protected)


        [internal_ready,fifo_push]=elaborateMasterDataFIFO(obj,hN,hElab,hChannel,...
        user_data,user_valid,port_tready,port_tdata,port_tvalid,multiRateCountEnable,multiRateCountValue)


        [fifo_rd_ack,stream_in_user_ready,stream_in_user_data,stream_in_user_valid]=...
        elaborateSlaveDataFIFO(obj,hN,hElab,...
        port_tdata,port_tvalid,port_tready,multiRateCountEnable,multiRateCountValue)


        elaborateMasterReadyLogic(obj,hN,hChannel,internal_ready,hStreamNetOutportSignals)


        internal_ready=elaborateSlaveReadyLogic(obj,hN,hChannel,hStreamNetInportSignals)


        populateAutoPorts(obj,hN,hElab,hChannel)


        scheduleAutoWiring(obj)


        elaborateStreamModule(obj,hN,hElab,hChannel,multiRateCountEnable,multiRateCountValue)
    end


    methods

    end



    methods


        function generateIPInterfaceVivadoTcl(obj,fid,hElab)


            hDI=hElab.hTurnkey.hD;

            channelIDlist=obj.hChannelList.getAssignedChannels;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);
                obj.generateIPCoreVivadoTclOnChannel(fid,hChannel,hDI);
            end

        end

        function generateIPCoreVivadoTclOnChannel(~,fid,hChannel,hDI)

            channelPortLabel=hChannel.ChannelPortLabel;

            fprintf(fid,'# %s\n',hChannel.ChannelID);


            interfaceName=channelPortLabel;
            hdlturnkey.tool.generateVivadoTclInterfaceDefinition(hDI,fid,interfaceName,...
            'xilinx.com:interface:axis_rtl:1.0','xilinx.com:interface:axis:1.0');


            channelDirType=hChannel.ChannelDirType;
            hdlturnkey.tool.generateVivadoTclInterfaceMode(hDI,fid,interfaceName,channelDirType)


            portIDs=fields(hChannel.ExtInportList);
            for ii=1:numel(portIDs)
                portID=portIDs{ii};
                portName=hChannel.ExtInportNames{hChannel.ExtInportList.(portID).Index};
                hdlturnkey.tool.generateVivadoTclPortMap(hDI,fid,interfaceName,portID,portName);
            end

            portIDs=fields(hChannel.ExtOutportList);
            for ii=1:numel(portIDs)
                portID=portIDs{ii};
                portName=hChannel.ExtOutportNames{hChannel.ExtOutportList.(portID).Index};
                hdlturnkey.tool.generateVivadoTclPortMap(hDI,fid,interfaceName,portID,portName);
            end

            fprintf(fid,'\n');
        end

        function interfaceStr=generateIPClockVivadoTcl(obj,interfaceStr)



            channelIDlist=obj.hChannelList.getAssignedChannels;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);
                interfaceName=hChannel.ChannelPortLabel;
                if isempty(interfaceStr)
                    interfaceStr=interfaceName;
                else
                    interfaceStr=sprintf('%s:%s',interfaceStr,interfaceName);
                end
            end
        end

        function generateRDInsertIPQsysTcl(obj,fid,hTool)



            hDI=hTool.hETool.hIP.hD;

            channelIDlist=obj.hChannelList.getAssignedChannels;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);
                channelPortLabel=hChannel.ChannelPortLabel;
                channelPortStr=sprintf('${HDLCODERIPINST}.%s',channelPortLabel);
                if hChannel.ChannelDirType==hdlturnkey.IOType.IN
                    downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Quartus.getTclQsysAddConnection',fid,obj.SlaveChannelConnection,channelPortStr);
                else
                    downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Quartus.getTclQsysAddConnection',fid,channelPortStr,obj.MasterChannelConnection);
                end

            end

        end

        function generatePCoreQsysTCL(obj,fid,~)


            channelIDlist=obj.hChannelList.getAssignedChannels;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);
                obj.generateIPCoreQsysTclOnChannel(fid,hChannel);
            end

        end

        function generateIPCoreQsysTclOnChannel(obj,fid,hChannel)

            channelPortLabel=hChannel.ChannelPortLabel;

            fprintf(fid,'# %s\n',hChannel.ChannelID);


            interfaceName=channelPortLabel;


            channelDirType=hChannel.ChannelDirType;


            portList=[];
            portIDs=fields(hChannel.ExtInportList);
            for ii=1:numel(portIDs)
                portID=portIDs{ii};
                portName=hChannel.ExtInportNames{hChannel.ExtInportList.(portID).Index};
                portWidth=hChannel.ExtInportList.(portID).Width;
                portList{end+1}=obj.buildQsysPort(portName,portID,'Input',portWidth);%#ok<AGROW>
            end

            portIDs=fields(hChannel.ExtOutportList);
            for ii=1:numel(portIDs)
                portID=portIDs{ii};
                portName=hChannel.ExtOutportNames{hChannel.ExtOutportList.(portID).Index};
                portWidth=hChannel.ExtOutportList.(portID).Width;
                portList{end+1}=obj.buildQsysPort(portName,portID,'Output',portWidth);%#ok<AGROW>
            end


            proplist={...
            {'associatedClock','ip_clk'},...
            {'associatedReset','ip_rst'},...
            {'ENABLED','true'},...
            {'EXPORT_OF','""'},...
            {'PORT_NAME_MAP','""'},...
            {'CMSIS_SVD_VARIABLES','""'},...
            {'SVD_ADDRESS_GROUP','""'},...
            };
            hdlturnkey.tool.generateQsysTclInterfaceDefinition(fid,interfaceName,channelDirType,'axi4stream',proplist,portList);

            fprintf(fid,'\n');
        end

        function qsysPort=buildQsysPort(~,portName,portID,dir,portWidth)
            qsysPort={...
            portName,...
            lower(portID),...
            dir,...
            num2str(portWidth)};
        end


        function interruptNumber=getDMAInterruptNumber(obj,portName)
            hChannel=obj.hChannelList.getChannelFromPortName(portName);
            if hChannel.ChannelDirType==hdlturnkey.IOType.IN
                interruptNumber=obj.SlaveChannelDMAIRQNumber;
            else
                interruptNumber=obj.MasterChannelDMAIRQNumber;
            end
        end

        function generateRDInsertIPVivadoTcl(obj,fid,~)


            channelIDlist=obj.hChannelList.getAssignedChannels;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);
                channelPortLabel=hChannel.ChannelPortLabel;
                if hChannel.ChannelDirType==hdlturnkey.IOType.IN
                    channelConnection=obj.SlaveChannelConnection;
                else
                    channelConnection=obj.MasterChannelConnection;
                end
                fprintf(fid,'connect_bd_intf_net [get_bd_intf_pins $HDLCODERIPINST/%s] [get_bd_intf_pins %s]\n',...
                channelPortLabel,channelConnection);
            end





        end

    end



    methods(Access=protected)

        validateInterfaceParameter(obj,RDAPIExampleStr)

        function result=isNonDefaultChannelConnection(obj)
            result=~isempty(obj.MasterChannelConnection)||~isempty(obj.SlaveChannelConnection);
        end

        function result=isNonDefaultChannelDataWidth(obj)
            result=obj.MasterChannelDataWidth>0||obj.SlaveChannelDataWidth>0;
        end

    end

end



