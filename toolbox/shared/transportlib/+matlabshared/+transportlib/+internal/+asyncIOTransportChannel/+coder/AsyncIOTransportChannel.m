classdef AsyncIOTransportChannel<handle&...
    matlabshared.transportlib.internal.ByteOrder






%#codegen

    properties(Access=private,Transient=true)


        AsyncIOChannel;
    end

    properties(Access=private)

        UnreadDataBuffer;
    end

    properties(Constant,Hidden)


        ValidPrecisions={'uint8','int8','uint16','int16','uint32',...
        'int32','uint64','int64','single','double','char','string'};
    end

    properties(Dependent)


NumBytesAvailable


Connected



        NumUnreadData;
    end

    properties(GetAccess=public,SetAccess=private)

        NumBytesWritten=0;
    end

    properties(Access=public)


ByteOrder



NativeDataType



DataFieldName




        AllowPartialReads(1,1)logical{mustBeNonempty}=false;




        WriteAsync(1,1)logical=true
    end

    properties(Access=private,Dependent)



StructData
    end

    methods

        function obj=AsyncIOTransportChannel(channel)

            coder.allowpcode('plain');
            narginchk(1,1);
            if~isa(channel,'matlabshared.asyncio.internal.Channel')
                coder.internal.error('transportlib:transport:invalidChannelType');
            end

            obj.AsyncIOChannel=channel;

            obj.ByteOrder='little-endian';
            obj.DataFieldName='Data';
            obj.NativeDataType='uint8';

            obj.UnreadDataBuffer=matlabshared.asyncio.buffer.internal.BufferChannel([Inf,0]);
            obj.UnreadDataBuffer.open();
        end

        function flushUnreadData(obj)

            obj.UnreadDataBuffer.flush();
        end

    end

    methods(Hidden)
        function delete(obj)
            obj.UnreadDataBuffer.close();
        end
    end

    methods


        function out=get.Connected(obj)
            out=obj.AsyncIOChannel.isOpen();
        end

        function value=get.NumBytesAvailable(obj)

            value=obj.UnreadDataBuffer.NumElementsAvailable;

            value=value+obj.AsyncIOChannel.InputStream.DataAvailable;
        end

        function value=get.NumUnreadData(obj)

            value=obj.UnreadDataBuffer.NumElementsAvailable;
        end

        function set.ByteOrder(obj,val)

            validatestring(val,{'little-endian','big-endian'},'AsyncIOTransportChannelSetByteOrder');





            if strncmpi(val,'little-endian',length(val))
                value='little-endian';
            else
                value='big-endian';
            end
            obj.ByteOrder=blanks(coder.ignoreConst(0));
            obj.ByteOrder=value;
        end

        function out=get.ByteOrder(obj)

            out=obj.ByteOrder;
        end

        function set.NativeDataType(obj,val)

            validateattributes(val,{'string','char'},{},mfilename,'val',2);
            obj.NativeDataType=blanks(coder.ignoreConst(0));
            obj.NativeDataType=val;
        end

        function set.DataFieldName(obj,val)

            validateattributes(val,{'string','char'},{},mfilename,'val',2);
            obj.DataFieldName=blanks(coder.ignoreConst(0));
            obj.DataFieldName=val;
        end

        function out=get.NativeDataType(obj)

            out=obj.NativeDataType;
        end

        function out=get.StructData(obj)
            out=strcmpi(obj.NativeDataType,'struct')&&~isempty(obj.DataFieldName);
        end
    end

    methods


        function write(varargin)





























            narginchk(2,3);
            obj=varargin{1};

            writeAsync(varargin{:});


            obj.AsyncIOChannel.OutputStream.drain();

        end

        function writeAsync(varargin)

































            narginchk(2,3);
            obj=varargin{1};


            data=varargin{2};
            obj.validateData(data);

            if nargin==3
                if isa(varargin{3},'string')
                    precision=char(varargin{3});
                else
                    precision=varargin{3};
                end
            else

                precision=class(data);
            end


            validateattributes(precision,{'string','char'},{'nonempty'},mfilename,'precision',3);
            precision=validatestring(precision,obj.ValidPrecisions,mfilename,'precision',3);



            if~any(strcmpi(precision,{'string','char'}))
                data=cast(data,precision);
                if obj.NeedByteSwap(obj.ByteOrder)
                    data=swapbytes(data);
                end
                data=typecast(data,'uint8');
            else


                data=uint8(char(data));
            end

            if obj.WriteAsync

                obj.writeAsyncRaw(data);
            else





                obj.writeSyncRaw(data);
            end
        end

        function writeSyncRaw(obj,data)





            options.Data=data;
            obj.AsyncIOChannel.execute(['Write',char(0)],options);
            numBytesWritten=obj.AsyncIOChannel.getCustomProp('LatestNumBytesWrittenToDevice');
            obj.NumBytesWritten=obj.NumBytesWritten+double(numBytesWritten);
        end


        function numBytes=writeAsyncRaw(obj,data)

















            [numBytes,errorStr]=obj.AsyncIOChannel.OutputStream.write(data);
            if~isempty(errorStr)
                coder.internal.error('transportlib:transport:writeFailed',errorStr);
            end
            obj.NumBytesWritten=obj.NumBytesWritten+numBytes;
        end

        function data=read(varargin)














































            narginchk(1,3);

            obj=varargin{1};

            switch nargin
            case 1
                precision='uint8';
                numsToRead=obj.NumBytesAvailable;
            case 2

                if ischar(varargin{2})||isstring(varargin{2})
                    precision=varargin{2};
                    numsToRead=obj.getNumValuesToRead(obj.NumBytesAvailable,precision);
                else
                    numsToRead=varargin{2};
                    precision='uint8';
                end
            case 3

                numsToRead=varargin{2};
                precision=varargin{3};
            end


            validateattributes(numsToRead,{'numeric'},{'scalar','nonnegative','finite'},mfilename,'size',2);


            if numsToRead==0
                if strcmpi(precision,'char')
                    data=blanks(0);
                elseif strcmpi(precision,'string')
                    data=string(blanks(0));
                else
                    data=zeros(0,0,precision);
                end
                return;
            end


            validateattributes(precision,{'string','char'},{'nonempty'},mfilename,'precision',3);
            precision=validatestring(precision,obj.ValidPrecisions,mfilename,'precision',3);

            if~obj.StructData

                numBytesToRead=obj.getNumBytesToRead(numsToRead,precision);
            else

                numBytesToRead=numsToRead;
            end


            rawData=obj.readRaw(numBytesToRead);
            if isempty(rawData)

                if strcmpi(precision,'char')
                    data=blanks(0);
                elseif strcmpi(precision,'string')
                    data=string(blanks(0));
                else
                    data=zeros(0,0,precision);
                end
            else

                actualType=class(rawData);
                if~strcmpi(actualType,obj.NativeDataType)
                    coder.internal.error('transportlib:transport:incorrectDataType',obj.NativeDataType,actualType);
                end













                data=obj.convertData(rawData,precision);
            end
        end

        function data=convertData(obj,tempData,precision)




            if iscell(tempData)
                if any(strcmpi(precision,{'string','char'}))
                    data=cell(1,length(tempData));
                    if strcmpi(precision,'char')
                        for pos=1:length(tempData)
                            data{pos}=cast(tempData{pos},precision);
                        end
                    else
                        for pos=1:length(tempData)
                            data{pos}=string(cast(tempData{pos},'char'));
                        end
                    end
                else
                    data=cell(1,length(tempData));
                    for pos=1:length(tempData)
                        tempDataArray=typecast(tempData{pos}(1,:),precision);
                        if obj.NeedByteSwap(obj.ByteOrder)
                            data{pos}=swapbytes(tempDataArray);
                        else
                            data{pos}=tempDataArray;
                        end
                    end
                end
            else
                if any(strcmpi(precision,{'string','char'}))
                    tempDataArray=cast(tempData(1,:),'char');
                    if strcmpi(precision,'char')
                        data=tempDataArray;
                    else
                        data=string(tempDataArray);
                    end
                else
                    tempDataArray=typecast(tempData(1,:),precision);
                    if obj.NeedByteSwap(obj.ByteOrder)
                        data=swapbytes(tempDataArray);
                    else
                        data=tempDataArray;
                    end
                end
            end
        end

        function data=readRaw(obj,numBytes)



















            data=zeros(0,0,'uint8');


            if numBytes<1
                return;
            end

            if obj.NumUnreadData>=numBytes
                data=obj.getUnreadData(numBytes);





            else








                numBytesToRead=numBytes-obj.NumUnreadData;
                hasEnoughData=false;
                startTic=tic;
                while toc(startTic)<obj.AsyncIOChannel.InputStream.Timeout
                    if obj.AsyncIOChannel.InputStream.DataAvailable>=numBytesToRead
                        hasEnoughData=true;
                        break;
                    end
                    pause(0.01);
                end

                if hasEnoughData










                    [rawData,~,status]=obj.AsyncIOChannel.InputStream.read...
                    (obj.AsyncIOChannel.InputStream.DataAvailable,zeros(1,1,'uint8'));
                    if strcmpi(status,'invalid')
                        coder.internal.error('transportlib:transport:transportInvalid');
                    end
                    obj.UnreadDataBuffer.write(rawData);
                    data=obj.getUnreadData(numBytes);
                else




                    if obj.AllowPartialReads

                        if obj.AsyncIOChannel.InputStream.DataAvailable>0










                            [rawData,~,status]=obj.AsyncIOChannel.InputStream.read...
                            (obj.AsyncIOChannel.InputStream.DataAvailable,zeros(1,1,'uint8'));
                            if strcmpi(status,'invalid')
                                coder.internal.error('transportlib:transport:transportInvalid');
                            end
                            obj.UnreadDataBuffer.write(rawData);
                        end
                        if obj.NumUnreadData>0
                            data=obj.getUnreadData(min(numBytes,obj.NumUnreadData));
                        end
                    else


                        coder.internal.error('transportlib:transport:timeout');
                    end
                end
            end
        end

        function data=readUntil(obj,token,wait)























            validateattributes(token,{'string','char','uint8'},{'nonempty'},mfilename,'token');
            token=char(token);


            if isequal(nargin,2)
                wait=true;
            end

            coder.varsize('dataFound');
            dataFound=zeros(1,0,'uint8');

            tokenFound=false;


            if obj.AsyncIOChannel.InputStream.DataAvailable>0
                [rawData,~,~]=obj.AsyncIOChannel.InputStream.read(obj.AsyncIOChannel.InputStream.DataAvailable,zeros(1,1,'uint8'));
                obj.UnreadDataBuffer.write(rawData);
            end


            if obj.NumUnreadData~=0




                searchData=obj.getAllUnreadData;


                searchDataChar=char(searchData);



                arridx=strfind(searchDataChar,token);

                if~isempty(arridx)
                    endidx=arridx(1)+length(token)-1;
                    dataFound=searchData(1:endidx);
                    if endidx<length(searchData)

                        obj.UnreadDataBuffer.write(searchData(endidx+1:end));
                    end
                    tokenFound=true;
                else

                    obj.UnreadDataBuffer.write(searchData);
                end
            end



            if tokenFound==false
                startTic=tic;
                while~tokenFound
                    if wait==true

                        status=obj.waitForDataAvailable();
                        if strcmpi(status,'invalid')
                            coder.internal.error('transportlib:transport:transportInvalid');
                        end
                        if strcmpi(status,'timeout')
                            coder.internal.error('transportlib:transport:timeout');
                        end
                    end




                    [dataFound,tokenFound]=obj.readStreamUntil(token);
                    if~wait
                        break;
                    end





                    if toc(startTic)>obj.AsyncIOChannel.InputStream.Timeout
                        coder.internal.error('transportlib:transport:timeout');
                    end
                end
            end
            data=dataFound;
        end

        function[tokenFound,indices]=peekUntil(obj,token)

















            tokenFound=false;
            indices=0;

            validateattributes(token,{'string','char','uint8'},{'nonempty'},mfilename,'token');
            token=char(token);


            if obj.AsyncIOChannel.InputStream.DataAvailable>0
                [rawData,~,~]=obj.AsyncIOChannel.InputStream.read(obj.AsyncIOChannel.InputStream.DataAvailable,zeros(1,1,'uint8'));
                obj.UnreadDataBuffer.write(rawData);
            end


            if obj.NumUnreadData~=0
                searchData=obj.getAllUnreadData;



                searchDataChar=char(searchData);
                arridx=strfind(searchDataChar,token);
                indices=arridx;

                if~isempty(arridx)

                    tokenFound=true;
                end


                obj.UnreadDataBuffer.write(searchData);
            end
        end
    end

    methods(Access=private)

        function data=validateData(~,data)


            validateattributes(data,{'numeric','string','char'},{'nonempty'},mfilename,'data',2);

            r=size(data);
            if r>1
                coder.internal.error('transportlib:transport:invalidDataDim',2,'data');
            end
        end

        function[data,tokenFound]=readStreamUntil(obj,token)





            tokenFound=false;

            if obj.AsyncIOChannel.InputStream.DataAvailable==0
                data=zeros(1,0,'uint8');
            else





                [dataRead,~,~]=obj.AsyncIOChannel.InputStream.read(obj.AsyncIOChannel.InputStream.DataAvailable,zeros(1,1,'uint8'));

                obj.UnreadDataBuffer.write(dataRead);

                searchData=obj.getAllUnreadData;
                searchDataChar=char(searchData);




                index=strfind(searchDataChar,token);


                if~isempty(index)
                    tokenFound=true;




                    endidx=index(1)+length(token)-1;



                    data=searchData(1:endidx);
                    if endidx<length(searchData)

                        obj.UnreadDataBuffer.write(searchData(endidx+1:end));
                    end
                else

                    obj.UnreadDataBuffer.write(searchData);
                    data=zeros(1,0,'uint8');
                end
            end
        end

        function status=waitForDataAvailable(obj)


            if~obj.AsyncIOChannel.InputStream.DataAvailable

                status=obj.AsyncIOChannel.InputStream.wait(@(obj)obj.DataAvailable>0);
            else
                status='Unknown';
            end
        end

        function data=getUnreadData(obj,numToRead)


            if numToRead>obj.NumUnreadData


                data=obj.getAllUnreadData();
            else
                data=obj.UnreadDataBuffer.read(numToRead);
            end
        end

        function data=getAllUnreadData(obj)


            if obj.NumUnreadData~=0


                data=obj.UnreadDataBuffer.read();

            else
                data=zeros(0,0,'uint8');
            end
        end

        function numBytesToRead=getNumBytesToRead(obj,size,precision)




            precisionSize=obj.sizeof(precision);



            numBytesToRead=size*precisionSize;
        end

        function numValuesToRead=getNumValuesToRead(obj,bytes,precision)




            precisionSize=obj.sizeof(precision);



            numValuesToRead=bytes/precisionSize;
        end

        function numbytes=sizeof(~,precision)

            switch(precision)
            case{'int8','uint8','char','string'}
                numbytes=1;
            case{'int16','uint16'}
                numbytes=2;
            case{'int32','uint32','single'}
                numbytes=4;
            case{'int64','uint64','double'}
                numbytes=8;
            otherwise
                numbytes=-1;
                coder.internal.error('transportlib:transport:unknownPrecision');
            end
        end
    end
end