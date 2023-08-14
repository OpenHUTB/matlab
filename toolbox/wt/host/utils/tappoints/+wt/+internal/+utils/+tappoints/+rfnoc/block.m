classdef block<wt.internal.utils.tappoints.block






    properties(Access=private)
Streamer
RxByteBuffLen
    end

    properties
Timeout
    end

    methods
        function obj=block(streamer,tappointconfig)

            obj=obj@wt.internal.utils.tappoints.block(tappointconfig);

            obj.Streamer=streamer;
            obj.Timeout=3;


            streamWidthBytes=obj.StreamWidth/8;
            headerLength=128/obj.StreamWidth;
            sequencerLength=64/obj.StreamWidth;
            LargestPayloadSize=max(obj.PayloadSizes);
            obj.RxByteBuffLen=(LargestPayloadSize+headerLength+sequencerLength)*streamWidthBytes;
            obj.Streamer.configure("burst",obj.RxByteBuffLen);
        end

        function read(obj)
            obj.initialiseRx();
            for i=1:obj.PacketsPerCapture
                OnePacketMode=true;
                [bytebuff,numBytesRx]=obj.Streamer.receive(obj.RxByteBuffLen,obj.Timeout,OnePacketMode);
                if~numBytesRx
                    error(message('wt:tappoints:NoDataReceived'));
                end

                streamPacked=obj.packBytes(bytebuff,obj.StreamWidth);
                obj.parse(streamPacked);
            end
        end

    end

    methods(Static,Hidden=true)

        function output_array=packBytes(input_arr,width)



            array_length=length(input_arr);

            if width==32
                output_array=uint32(ones(0,0));
            else
                output_array=uint64(ones(0,0));
            end

            for i=1:8:array_length
                slice=[input_arr(i+5),input_arr(i+4),input_arr(i+7),input_arr(i+6),...
                input_arr(i+1),input_arr(i),input_arr(i+3),input_arr(i+2)];
                if width==32
                    output_array(length(output_array)+1)=typecast(slice(1:4),'uint32');
                    output_array(length(output_array)+1)=typecast(slice(5:8),'uint32');
                else
                    output_array(length(output_array)+1)=typecast(slice,'uint64');
                end
            end

        end

    end
    methods(Static)
        function address=getRegAddress(regConfig,regName,readWrite)
            idx=0;
            for i=1:length(regConfig)
                currentRegName=fieldnames(regConfig{i});
                if strcmp(currentRegName{1},regName)
                    idx=i;
                    break
                end
            end

            if idx==0
                error(message('wt:tappoints:InvalidRegisterName'));
            end

            if strcmp(readWrite,'read')
                cmd=['regConfig{',num2str(idx),'}.',char(regName),'.readback.address'];
                address=eval(cmd);
            else
                cmd=['regConfig{',num2str(idx),'}.',char(regName),'.setreg.address'];
                address=eval(cmd);
            end


            address=str2double(address)*8;
        end
    end

end
