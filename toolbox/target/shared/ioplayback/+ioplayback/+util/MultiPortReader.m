classdef MultiPortReader<matlab.System






    properties(Nontunable)
SignalInfo
        Filename;
        DataFilename='';
        TimeStampFilename='';
        HdrSize;
        DataLen;
        PayloadSizeFieldLen;
        HWSignalInfo;
        SamplesCollected;
        SourceType;
    end

    properties(Access=private,Transient)

        DataTypeSpec='*double'
        DataTypeSize=8
        FTimeid=-1
        FDataid=-1
TimeTick


    end
    properties(Access=private)
        pInitialize=false;
    end
    properties(Access=public)
Ts
    end

    methods

        function obj=MultiPortReader(varargin)

            setProperties(obj,nargin,varargin{:});
        end

        function y=readAllTimestamp(obj)
            hdrSize=fread(obj.FTimeid,1,'*uint');
            fseek(obj.FTimeid,hdrSize,0);
            ftell(obj.FTimeid);
            while~feof(obj.FTimeid)
                ts=fread(obj.FTimeid,1,'*double');
                if isempty(ts)
                    break;
                end
                obj.Ts(end+1)=ts;
            end
            y=numel(obj.Ts);
            frewind(obj.FTimeid);
        end

        function ts=readTimestamp(obj)
            ts=[];
            p=obj.TimeTick+1;
            if p<=numel(obj.Ts)
                ts=obj.Ts(p);
                obj.TimeTick=p;
            end
        end
    end


    methods(Access=protected)

        function setupImpl(obj)
            obj.TimeStampFilename=obj.Filename{1};
            obj.DataFilename=obj.Filename{2};
            obj.TimeTick=0;
            obj.FTimeid=fopen(obj.TimeStampFilename,'r');
            obj.FDataid=fopen(obj.DataFilename,'r');
            obj.pInitialize=true;
            if obj.FDataid<0
                error(message('ioplayback:general:CanNotOPenFileForRead'));
            end
            if(obj.FTimeid<0)
                error(message('ioplayback:general:CanNotOPenFileForRead'));
            end

            obj.SamplesCollected=readAllTimestamp(obj);
            fseek(obj.FTimeid,0,0);


            fseek(obj.FDataid,(obj.HdrSize)+4,'bof');
        end

        function[y,validLength]=stepImpl(obj,portNumber)
            if(obj.DataLen==-1)
                if obj.PayloadSizeFieldLen==2
                    payloadlen=fread(obj.FDataid,1,'int16');
                    lengthOfData=payloadlen/bytesRecorded(obj,portNumber);
                elseif obj.PayloadSizeFieldLen==4
                    payloadlen=fread(obj.FDataid,1,'int32');
                    lengthOfData=payloadlen/bytesRecorded(obj,portNumber);
                end
                if isempty(payloadlen)
                    lengthOfData=0;
                end
                hwDimensions=lengthOfData;
            else
                hwDimensions=prod(obj.HWSignalInfo(portNumber).Dimensions);
            end
            blockDimensions=prod(obj.SignalInfo(portNumber).Dimensions);
            if blockDimensions==-1
                blockDimensions=hwDimensions;
            end
            blockDataType=obj.SignalInfo(portNumber).DataType;
            hwDataType=obj.HWSignalInfo(portNumber).DataType;


            if(numel(obj.SignalInfo)==1)


                if(obj.DataLen~=-1||isequal(blockDimensions,hwDimensions))
                    [data,numValuesRead]=fread(obj.FDataid,blockDimensions,['*',blockDataType]);
                    if(numValuesRead==blockDimensions)&&(~feof(obj.FDataid))
                        y=data;
                        validLength=blockDimensions;
                    else
                        y=zeros(blockDimensions,1,blockDataType);
                        validLength=0;
                    end
                else

                    if(blockDimensions>hwDimensions)
                        [data,numValuesRead]=fread(obj.FDataid,hwDimensions,['*',hwDataType]);
                        if(numValuesRead==hwDimensions)&&(~feof(obj.FDataid))
                            y=padZerosVariableLength(obj,portNumber,data,blockDimensions,hwDimensions);
                            validLength=hwDimensions;
                        else
                            y=zeros(blockDimensions,1,blockDataType);
                            validLength=0;
                        end
                    else



                        [data,numValuesRead]=fread(obj.FDataid,hwDimensions,['*',hwDataType]);
                        if(numValuesRead==hwDimensions)&&(~feof(obj.FDataid))
                            y=data(1:blockDimensions,:);
                            validLength=blockDimensions;
                        else
                            y=zeros(blockDimensions,1,blockDataType);
                            validLength=0;
                        end
                    end
                end
            else


                if((blockDimensions==hwDimensions))
                    [data,numValuesRead]=fread(obj.FDataid,blockDimensions,['*',blockDataType]);
                    if(numValuesRead==blockDimensions)&&(~feof(obj.FDataid))
                        y=data;
                        validLength=blockDimensions;
                    else
                        y=zeros(blockDimensions,1,blockDataType);
                        validLength=0;
                    end
                else



                    if(blockDimensions>hwDimensions)
                        [data,numValuesRead]=fread(obj.FDataid,hwDimensions,['*',hwDataType]);
                        if(numValuesRead==hwDimensions)&&(~feof(obj.FDataid))
                            y=padZeros(portNumber,data,obj);
                            validLength=hwDimensions;
                        else
                            y=zeros(blockDimensions,1,blockDataType);
                            validLength=0;
                        end
                    else



                        [data,numValuesRead]=fread(obj.FDataid,hwDimensions,['*',hwDataType]);
                        if(numValuesRead==hwDimensions)&&(~feof(obj.FDataid))
                            y=data(1:blockDimensions,:);
                            validLength=blockDimensions;
                        else
                            y=zeros(blockDimensions,1,blockDataType);
                            validLength=0;
                        end
                    end
                end
            end
        end

        function resetImpl(obj)

            frewind(obj.FTimeid);
            frewind(obj.FDataid);
            obj.TimeTick=0;
        end
        function releaseImpl(obj)
            if obj.pInitialize
                if obj.FTimeid>0
                    fclose(obj.FTimeid);
                end
                obj.FTimeid=-1;
                if obj.FDataid>0
                    fclose(obj.FDataid);
                end
                obj.FDataid=-1;
                obj.pInitialize=false;
            end

        end

    end

    methods(Hidden)
        function delete(obj)
            if obj.pInitialize
                if obj.FTimeid>0
                    fclose(obj.FTimeid);
                end
                obj.FTimeid=-1;
                if obj.FDataid>0
                    fclose(obj.FDataid);
                end
                obj.FDataid=-1;
                obj.pInitialize=false;
            end
        end
    end

    methods(Access=private)
        function paddedData=padZeros(portNumber,recordedData,obj)
            appendLength=prod(obj.SignalInfo(portNumber).Dimensions)-prod(obj.HWSignalInfo(portNumber).Dimensions);
            appendBuffer=zeros(appendLength,1,obj.SignalInfo(portNumber).DataType);
            paddedData=[recordedData;appendBuffer];
        end
        function paddedData=padZerosVariableLength(obj,portNumber,recordedData,blockDimensions,hwDimensions)
            appendLength=blockDimensions-hwDimensions;
            appendBuffer=zeros(appendLength,1,obj.SignalInfo(portNumber).DataType);
            paddedData=[recordedData;appendBuffer];
        end
        function size=bytesRecorded(obj,portNumber)
            switch obj.SignalInfo(portNumber).DataType
            case{'uint8','int8','char'}
                size=1;
            case{'int16','uint16'}
                size=2;
            case{'int32','uint32','single'}
                size=4;
            case{'int64','uint64','double'}
                size=8;
            otherwise
                error(message('soc:utils:AXIRegisterDataTypeNotSupported',lower(obj.DataType)));
            end
        end
    end
end
