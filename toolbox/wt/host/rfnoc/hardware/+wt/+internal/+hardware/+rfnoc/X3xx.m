classdef X3xx<wt.internal.hardware.rfnoc.Device




    properties(Hidden,SetAccess=immutable)
        Type="x300"
        ConnectionProperties=["SFP0IPAddress","SFP1IPAddress"]
    end

    properties(Hidden)
DaughterBoard
SFP0IPAddress
SFP1IPAddress
SerialNum
    end

    properties(Hidden)
        ClockSource="internal"
        TimeSource="internal"
        CustomDeviceArgs=[]
    end

    methods(Static,Hidden)
        function resetBoard(IPaddress)


            udpPort=49152;

            ackFlag=uint32(1);
            poke32Flag=uint32(4);

            resetReg=uint32(0x100058);
            resetData=uint32(1);

            sequenceNumber=1;

            resetPacket=typecast(swapbytes([bitor(poke32Flag,ackFlag),sequenceNumber,resetReg,resetData]),'uint8');

            UDPS=dsp.UDPSender("RemoteIPAddress",IPaddress,"RemoteIPPort",udpPort);

            UDPS(resetPacket);

        end
    end
    methods(Hidden)

        function rates=calculateAvailableSampleRates(obj)


            listOfFactors=unique([(1:3),(4:2:128),(5:2:128),(128:2:256),(256:4:512),(512:8:1020)]);
            rates=calculateAvailableSampleRatesHelper(obj,listOfFactors);
        end
        function address=getIPAddress(obj)

            if~isempty(obj.SFP0IPAddress)
                address=obj.SFP0IPAddress;
            elseif~isempty(obj.SFP1IPAddress)
                address=obj.SFP1IPAddress;
            else
                address=[];
            end
        end
        function success=setupHardware(obj,handoff)
            uhd_bin_path=wt.internal.uhd.clibgen.setup();
            command=fullfile(uhd_bin_path,'uhd_image_loader');

            if~isfile(handoff.bitstream)
                error(message("wt:rfnoc:hardware:BitstreamNotFound",handoff.bitstream));
            end

            command=strcat(command,' --args type=',obj.Type);
            address=getIPAddress(obj);
            if~isempty(address)

                checkNetworkConnection(obj,address);
                command=strcat(command,',addr=',address);
            end
            command=strcat(command,' --fpga-path="',handoff.bitstream,'"');
            disp(message("wt:rfnoc:hardware:BitstreamLongLoadStart",5).getString);
            [status,result]=system(command);
            if status~=0
                error(message("wt:rfnoc:hardware:BitstreamDownloadError",result));
            else
                success=true;

                wt.internal.hardware.rfnoc.X3xx.resetBoard(address);

                pause(10);

                checkNetworkConnection(obj,address);
                disp(message("wt:rfnoc:hardware:BitstreamLoadEnd").getString);
            end
        end
        function args=getDeviceArgs(obj)

            if isempty(obj.CustomDeviceArgs)
                args=strcat("type=",obj.Type);
                args=strcat(args,",product=",obj.Product);

                args=strcat(args,",clock_source=",obj.ClockSource);
                args=strcat(args,",time_source=",obj.TimeSource);

                if~isempty(obj.SFP1IPAddress)
                    args=strcat(args,",addr=",obj.SFP1IPAddress);
                elseif~isempty(obj.SFP0IPAddress)
                    args=strcat(args,",addr=",obj.SFP0IPAddress);
                end
                if~isempty(obj.SerialNum)
                    args=strcat(args,",serial=",obj.SerialNum);
                end
                args=strcat(args,",master_clock_rate=",num2str(obj.MasterClockRate));
            else
                args=obj.CustomDeviceArgs;
            end
        end
    end
end
