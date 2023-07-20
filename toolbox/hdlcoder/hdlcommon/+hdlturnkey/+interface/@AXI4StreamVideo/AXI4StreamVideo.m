


classdef AXI4StreamVideo<hdlturnkey.interface.AXI4StreamBase


    properties(Constant)
        DefaultInterfaceID='AXI4-Stream Video';
    end

    properties




        ImageWidth=0;
        ImageHeight=0;
        HorizontalPorch=0;
        VerticalPorch=0;
    end

    properties(Access=protected)


        hPixelDataType=[];
        hPixelBusType=[];
        hUfix1Type=[];

    end

    properties(Hidden=true,Constant)

        RDAPIExampleStr=...
        [sprintf('\nhRD.addAXI4StreamVideoInterface( ...\n'),...
        sprintf('    ''InterfaceID'',              ''AXI4-Stream Video'', ...\n'),...
        sprintf('    ''MasterChannelEnable'',      true, ...\n'),...
        sprintf('    ''SlaveChannelEnable'',       true, ...\n'),...
        sprintf('    ''MasterChannelConnection'', ''axi_dma_0/S_AXIS_S2MM'', ...\n'),...
        sprintf('    ''SlaveChannelConnection'',  ''axi_dma_0/M_AXIS_MM2S'', ...\n'),...
        sprintf('    ''MasterChannelDataWidth'',   32, ...\n'),...
        sprintf('    ''SlaveChannelDataWidth'',    32, ...\n'),...
        sprintf('    ''ImageWidth'',               1920, ...\n'),...
        sprintf('    ''ImageHeight'',              1080, ...\n'),...
        sprintf('    ''HorizontalPorch'',          280, ...\n'),...
        sprintf('    ''VerticalPorch'',            45);\n')];
    end

    methods

        function obj=AXI4StreamVideo(varargin)



            propList={...
            {'InterfaceID',hdlturnkey.interface.AXI4StreamVideo.DefaultInterfaceID},...
            {'MasterChannelEnable',true},...
            {'SlaveChannelEnable',true},...
...
            {'MasterChannelConnection',''},...
            {'SlaveChannelConnection',''},...
            {'MasterChannelDataWidth',0},...
            {'SlaveChannelDataWidth',0},...
            {'SoftwareInterface',[]},...
...
            {'ImageWidth',1920},...
            {'ImageHeight',1080},...
            {'HorizontalPorch',280},...
            {'VerticalPorch',45},...
...
...
            {'MasterChannelNumber',0},...
            {'SlaveChannelNumber',0},...
...
            {'InterfacePortLabel',''},...
            {'IsRequired',true},...
            {'IsGenericIP',false},...
            };


            p=downstream.tool.parseInputProperties(propList,varargin{:});
            inputArgs=p.Results;


            interfaceID=inputArgs.InterfaceID;
            obj=obj@hdlturnkey.interface.AXI4StreamBase(interfaceID);


            obj.InputPropertyList=propList;
            obj.assignPropertyValueShared(p);


            obj.TDATAMaxWidth=64;


            obj.validateInterfaceParameter;


            obj.SupportedTool={'Xilinx Vivado'};


            obj.setupInterfaceAssignment;



            obj.isDefaultBusInterfaceRequired=true;
        end

        function isa=isAXI4StreamVideoInterface(~)
            isa=true;
        end

    end


    methods

        function setupInterfaceAssignment(obj)



            obj.hChannelList=hdlturnkey.data.ChannelListAXI4StreamVideo(...
            obj.InterfaceID,...
            obj.InterfacePortLabel,...
            obj.MasterChannelNumber,...
            obj.SlaveChannelNumber);


            obj.populateSubPorts;
        end

        function registerAddressAuto(obj,hElab)





            channelIDlist=obj.hChannelList.getAssignedChannels;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);

                if hChannel.ChannelDirType==hdlturnkey.IOType.IN
                    hBus=obj.getDefaultBusInterface(hElab);
                    hBaseAddr=hBus.hBaseAddr;


                    registerID=sprintf('%s_image_width',lower(hChannel.ChannelPortLabel));
                    hAddr=hBaseAddr.registerAddressAuto(registerID,hdlturnkey.data.AddrType.ELAB);
                    hAddr.InitValue=obj.ImageWidth;
                    hAddr.DescName=sprintf('%s_ImageWidth',hChannel.ChannelPortLabel);
                    hMsg=message('hdlcommon:interface:VideoImageWidthDesc',hChannel.ChannelID,hAddr.InitValue);
                    hAddr.Description=hMsg.getString;


                    registerID=sprintf('%s_image_height',lower(hChannel.ChannelPortLabel));
                    hAddr=hBaseAddr.registerAddressAuto(registerID,hdlturnkey.data.AddrType.ELAB);
                    hAddr.InitValue=obj.ImageHeight;
                    hAddr.DescName=sprintf('%s_ImageHeight',hChannel.ChannelPortLabel);
                    hMsg=message('hdlcommon:interface:VideoImageHeightDesc',hChannel.ChannelID,hAddr.InitValue);
                    hAddr.Description=hMsg.getString;


                    registerID=sprintf('%s_hporch',lower(hChannel.ChannelPortLabel));
                    hAddr=hBaseAddr.registerAddressAuto(registerID,hdlturnkey.data.AddrType.ELAB);
                    hAddr.InitValue=obj.HorizontalPorch;
                    hAddr.DescName=sprintf('%s_HPorch',hChannel.ChannelPortLabel);
                    hMsg=message('hdlcommon:interface:VideoHPorchDesc',hChannel.ChannelID,hAddr.InitValue);
                    hAddr.Description=hMsg.getString;


                    registerID=sprintf('%s_vporch',lower(hChannel.ChannelPortLabel));
                    hAddr=hBaseAddr.registerAddressAuto(registerID,hdlturnkey.data.AddrType.ELAB);
                    hAddr.InitValue=obj.VerticalPorch;
                    hAddr.DescName=sprintf('%s_VPorch',hChannel.ChannelPortLabel);
                    hMsg=message('hdlcommon:interface:VideoVPorchDesc',hChannel.ChannelID,hAddr.InitValue);
                    hAddr.Description=hMsg.getString;
                end

            end
        end

    end

    methods(Access=protected)


        populateSubPorts(obj)

    end


    methods

        function validatePortForInterface(~,hIOPort,~,interfaceStr)







            if hIOPort.isTunable
                error(message('hdlcommon:interface:AXIVideoTunableParam',interfaceStr,hIOPort.PortName));
            elseif hIOPort.isTestPoint

                error(message('hdlcommon:interface:AXIVideoTestPoint',interfaceStr,hIOPort.PortName));
            end

            if hIOPort.isVector
                error(message('hdlcommon:workflow:VectorPortUnsupported',interfaceStr,hIOPort.PortName));
            end

            if hIOPort.isMatrix
                error(message('hdlcommon:workflow:MatrixPortUnsupported',interfaceStr,hIOPort.PortName));
            end

            if hIOPort.isSingle
                error(message('hdlcommon:workflow:SinglePortUnsupported',interfaceStr,hIOPort.PortName));
            end

        end

    end


    methods(Access=protected)


        populateExternalPorts(obj,hN,hChannel,hElab)


        populateUserPorts(obj,hN,hChannel)


        elaborateStreamModule(obj,hN,hElab,hChannel,multiRateCountEnable,multiRateCountValue)


        elaborateStreamSlave(obj,hElab,hChannel,...
        hStreamNet,hStreamNetInportSignals,hStreamNetOutportSignals,multiRateCountEnable,multiRateCountValue)


        elaborateStreamMaster(obj,hElab,hChannel,...
        hStreamNet,hStreamNetInportSignals,hStreamNetOutportSignals,multiRateCountEnable,multiRateCountValue)

    end


    methods(Access=protected)


        validateInterfaceParameter(obj)

    end

end







