classdef Writer<matlab.System



%#codegen
    properties
        DataFileFormat;
    end

    properties(Nontunable)
        Filename='data.bin';
        DataFid;
        TimeFid;
        SampleTime;
        RecordDuration;
        SinkObj;
    end

    properties(Access=private)
        Fid=-1;
        PInitialise;
        DataType;
        DataLen;
        SignalFid;
        ReceivedSamplesCount=0;
        ReservedInfoLen=0;
        fixedHeaderSize=168;
    end

    methods
        function obj=Writer(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
            obj.PInitialise=true;
        end

        function set.Filename(obj,val)
            validateattributes(val,{'char'},{'nonempty'},'','Filename');
            obj.Filename=val;
        end
    end

    methods(Access=protected)
        function setupImpl(obj,varargin)

            obj.Fid=fopen(obj.Filename,'w');
            if obj.Fid<0
                error(message('ioplayback:utils:LogWriter',obj.Filename));
            end

        end

        function stepImpl(obj,data,varargin)


            InitialiseHeader(obj,data,varargin)
            obj.ReceivedSamplesCount=obj.ReceivedSamplesCount+1;
            if(obj.DataFileFormat=="Raw-TimeStamp"||obj.DataFileFormat=="TimeStamp")
                TimeStamp=varargin{1};
                fwrite(obj.Fid,TimeStamp,'double');
                fwrite(obj.Fid,data(1:obj.DataLen),class(data));
            end
            if(obj.DataFileFormat=="Raw")

                fwrite(obj.Fid,data,class(data));
            end
        end

        function InitialiseHeader(obj,data,varargin)
            if obj.PInitialise
                HeaderSize=obj.fixedHeaderSize+obj.ReservedInfoLen;

                fwrite(obj.Fid,HeaderSize,'*int32');
                headerType=2;

                fwrite(obj.Fid,headerType,'*int32');
                magicNumber=hex2dec('a1b2c3d4');

                fwrite(obj.Fid,magicNumber,'*int32');
                versionNumber=0.2;

                fwrite(obj.Fid,versionNumber,'double');
                len=length(obj.DataFileFormat);
                remainingLength=20-len;
                for i=1:remainingLength
                    obj.DataFileFormat=[obj.DataFileFormat,' '];
                end

                fwrite(obj.Fid,obj.DataFileFormat,'uchar');
                obj.DataFileFormat=deblank(obj.DataFileFormat);
                boardName='SinkSystem';
                len=length(boardName);
                remainingLength=48-len;
                for i=1:remainingLength
                    boardName=[boardName,' '];%#ok<AGROW>
                end

                fwrite(obj.Fid,boardName,'uchar');
                if isequal(class(obj.SinkObj),'soc.internal.GenericReceiver')
                    peripheralName=obj.SinkObj.MessageType;
                else


                    peripheralName=class(obj.SinkObj);
                end
                len=length(peripheralName);
                remainingLength=32-len;
                for i=1:remainingLength
                    peripheralName=[peripheralName,' '];%#ok<AGROW>
                end

                fwrite(obj.Fid,peripheralName,'uchar');

                fwrite(obj.Fid,obj.RecordDuration,'double');

                fwrite(obj.Fid,obj.SampleTime,'double');
                if isequal(class(obj.SinkObj),'soc.internal.GenericReceiver')
                    frameSize=obj.SinkObj.ValidLength*obj.sizeof(class(data));
                else


                    frameSize=length(data)*obj.sizeof(class(data));
                end
                fwrite(obj.Fid,frameSize,'int');
                if isequal(class(obj.SinkObj),'soc.internal.GenericReceiver')
                    obj.DataLen=obj.SinkObj.ValidLength;
                else


                    obj.DataLen=numel(data);
                end

                fwrite(obj.Fid,obj.DataLen,'int32');

                recordingStartTime=0;
                fwrite(obj.Fid,recordingStartTime,'double');
                payloadSizeFieldLen=2;

                fwrite(obj.Fid,payloadSizeFieldLen,'int');


                totalReceivedSamples=0;
                fwrite(obj.Fid,totalReceivedSamples,'int');
                len=length(class(data));
                remaingLength=8-len;
                obj.DataType=class(data);
                for i=1:remaingLength
                    obj.DataType=[obj.DataType,' '];
                end

                fwrite(obj.Fid,obj.DataType,'uchar');
                obj.DataType=deblank(obj.DataType);


                fwrite(obj.Fid,obj.ReservedInfoLen,'int32');
                writeReservedInfo(obj);
                obj.PInitialise=false;
            end
        end

        function writeReservedInfo(obj)
            switch class(obj.SinkObj)
            case 'soc.libiio.axistream.write'
                nameValue=sprintf("devName=%s",obj.SinkObj.devName);
                len=strlength(nameValue);
                fwrite(obj.Fid,devNameLen,'uint32');
                fwrite(obj.Fid,len,'uchar');
                obj.ReservedInfoLen=len;
                nameValue=sprintf("NumBuffers=%d",obj.SinkObj.NumBuffers);
                len=strlength(nameValue);
                fwrite(obj.Fid,len,'uint32');
                fwrite(obj.Fid,nameValue,'uchar');
                obj.ReservedInfoLen=obj.ReservedInfoLen+len;
                nameValue=sprintf("Timeout=%s",obj.SinkObj.Timeout);
                len=strlength(nameValue);
                fwrite(obj.Fid,len,'uint32');
                fwrite(obj.Fid,nameValue,'uchar');
                obj.ReservedInfoLen=obj.ReservedInfoLen+len;
                obj.ReservedInfoLen=3*obj.sizeof('int32')+obj.ReservedInfoLen;
            case 'soc.linux.AXIRegisterWrite'
                nameValue=sprintf("RegisterOffset=%d",obj.SinkObj.RegisterOffset);
                len=strlength(nameValue);
                fwrite(obj.Fid,len,'uint32');
                fwrite(obj.Fid,nameValue,'uchar');
                obj.ReservedInfoLen=obj.ReservedInfoLen+len;
                nameValue=sprintf("DeviceName=%s",obj.SinkObj.DeviceName);
                len=strlength(nameValue);
                fwrite(obj.Fid,len,'uint32');
                fwrite(obj.Fid,nameValue,'uchar');
                obj.ReservedInfoLen=obj.ReservedInfoLen+len;
                obj.ReservedInfoLen=2*obj.sizeof('int32')+obj.ReservedInfoLen;
            case 'soc.linux.UDPWrite'
                nameValue=sprintf("RemoteAddress=%s",obj.SinkObj.RemoteAddress);
                len=strlength(nameValue);
                fwrite(obj.Fid,len,'uint32');
                fwrite(obj.Fid,nameValue,'uchar');
                obj.ReservedInfoLen=obj.ReservedInfoLen+len;
                nameValue=sprintf("RemotePort=%d",obj.SinkObj.RemotePort);
                len=strlength(nameValue);
                fwrite(obj.Fid,len,'uint32');
                fwrite(obj.Fid,nameValue,'uchar');
                obj.ReservedInfoLen=obj.ReservedInfoLen+len;
                nameValue=sprintf("LocalPort=%d",obj.SinkObj.LocalPort);
                len=strlength(nameValue);
                fwrite(obj.Fid,len,'uint32');
                fwrite(obj.Fid,nameValue,'uchar');
                obj.ReservedInfoLen=obj.ReservedInfoLen+len;
                nameValue=sprintf("ByteOrder=%s",obj.SinkObj.ByteOrder);
                len=strlength(nameValue);
                fwrite(obj.Fid,len,'uint32');
                fwrite(obj.Fid,nameValue,'uchar');
                obj.ReservedInfoLen=obj.ReservedInfoLen+len;
                obj.ReservedInfoLen=4*obj.sizeof('int32')+obj.ReservedInfoLen;
            end
        end

        function ret=sizeof(~,dataType)
            switch(lower(dataType))
            case 'double'
                ret=8;
            case{'single','uint32','int32'}
                ret=4;
            case{'int16','uint16','char'}
                ret=2;
            case{'int8','uint8','logical','boolean'}
                ret=1;
            otherwise
                error('matlab:io:DataTypeNotSupported',...
                'Data type, %s, is not supported.',lower(dataType));
            end
        end

        function releaseImpl(obj)

            if obj.Fid>0

                frewind(obj.Fid);
                HeaderSize=obj.fixedHeaderSize+obj.ReservedInfoLen;

                fwrite(obj.Fid,HeaderSize,'*int32');


                fseek(obj.Fid,(obj.fixedHeaderSize-16),'bof');
                fwrite(obj.Fid,obj.ReceivedSamplesCount,'uint32');
                fseek(obj.Fid,12,'cof');
                fwrite(obj.Fid,obj.ReservedInfoLen,'*int32');
                fclose(obj.Fid);
            end
        end
    end

    methods(Access=protected)
        function icon=getIconImpl(obj)

            icon=sprintf('F=%s',char(obj.Filename));
        end
    end

    methods(Static,Access=protected)
        function simMode=getSimulateUsingImpl(~)
            simMode='Interpreted execution';
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end
end
