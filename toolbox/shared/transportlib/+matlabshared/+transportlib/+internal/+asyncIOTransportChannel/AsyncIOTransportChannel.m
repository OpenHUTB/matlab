classdef AsyncIOTransportChannel<handle&...
    matlabshared.transportlib.internal.ByteOrder






%#codegen

    properties(Access=private,Transient=true)


AsyncIOChannel
    end

    properties(Constant,Hidden)


        ValidPrecisions={'uint8','int8','uint16','int16','uint32',...
        'int32','uint64','int64','single','double','char','string'};
    end

    properties(Dependent)


NumBytesAvailable


        Connected(1,1)boolean{mustBeNonempty}
    end

    properties(GetAccess=public,SetAccess=private)

        NumBytesWritten=0;
    end

    properties(Access=public)


        ByteOrder='little-endian'



        NativeDataType='uint8'



        DataFieldName=''




        AllowPartialReads(1,1)logical{mustBeNonempty}=false




        WriteAsync(1,1)logical=true
    end

    properties(Hidden)





















        LicenseCheckoutFcn=...
        instrument.internal.InterfaceFunctionGetter.DefaultFcn
    end

    properties(Access=private)


        UnreadData=[]



        StructData=false
    end


    methods(Static)
        function name=matlabCodegenRedirect(~)


            name='matlabshared.transportlib.internal.asyncIOTransportChannel.coder.AsyncIOTransportChannel';
        end
    end

    methods

        function obj=AsyncIOTransportChannel(channel,varargin)


            narginchk(1,2);
            if~isempty(varargin)
                obj.LicenseCheckoutFcn=...
                instrument.internal.InterfaceFunctionGetter.getLicenseFcn(varargin{1});
            end



            obj.LicenseCheckoutFcn();

            if~isa(channel,'matlabshared.asyncio.internal.Channel')
                throwAsCaller(MException(message('transportlib:transport:invalidChannelType')));
            end

            obj.AsyncIOChannel=channel;
        end

        function flushUnreadData(obj)

            obj.UnreadData=[];
        end

    end

    methods


        function out=get.Connected(obj)
            out=obj.AsyncIOChannel.isOpen();
        end

        function value=get.NumBytesAvailable(obj)

            value=length(obj.UnreadData);

            value=value+obj.AsyncIOChannel.InputStream.DataAvailable;
        end

        function set.ByteOrder(obj,val)

            val=validatestring(val,{'little-endian','big-endian'});
            obj.ByteOrder=val;
        end

        function out=get.ByteOrder(obj)

            out=obj.ByteOrder;
        end

        function set.NativeDataType(obj,val)

            validateattributes(val,{'string','char'},{},mfilename,'val',2);
            obj.NativeDataType=val;

            obj.StructData=strcmpi(obj.NativeDataType,'struct')&&~isempty(obj.DataFieldName);%#ok<MCSUP>
        end

        function set.DataFieldName(obj,val)

            validateattributes(val,{'string','char'},{},mfilename,'val',2);
            obj.DataFieldName=val;

            obj.StructData=strcmpi(obj.NativeDataType,'struct')&&~isempty(obj.DataFieldName);%#ok<MCSUP>
        end

        function out=get.NativeDataType(obj)

            out=obj.NativeDataType;
        end
    end

    methods


        function write(varargin)





























            try
                narginchk(2,3);
                obj=varargin{1};
                writeAsync(varargin{:});


                obj.AsyncIOChannel.OutputStream.drain();

            catch ex
                throwAsCaller(ex);
            end
        end

        function writeAsync(varargin)
































            try
                narginchk(2,3);
                obj=varargin{1};

                obj.LicenseCheckoutFcn();
                varargin=instrument.internal.stringConversionHelpers.str2char(varargin);


                data=varargin{2};
                obj.validateData(data);

                if isequal(nargin,3)
                    precision=varargin{3};
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
            catch validationEx



                ex=MException(message('transportlib:transport:validationError'));
                ex=addCause(ex,validationEx);
                throw(ex);
            end

            try
                if obj.WriteAsync

                    obj.writeAsyncRaw(data);
                else





                    obj.writeSyncRaw(data);
                end
            catch asyncioError
                throw(asyncioError);
            end
        end

        function writeSyncRaw(obj,data)





            try
                options.Data=data;
                obj.AsyncIOChannel.execute("Write",options);
            catch ex
                obj.NumBytesWritten=obj.NumBytesWritten+...
                double(obj.AsyncIOChannel.LatestNumBytesWrittenToDevice);
                throw(ex)
            end
            obj.NumBytesWritten=obj.NumBytesWritten+...
            double(obj.AsyncIOChannel.LatestNumBytesWrittenToDevice);
        end

        function numBytes=writeAsyncRaw(obj,data)


















            [numBytes,errorStr]=obj.AsyncIOChannel.OutputStream.write(data);
            if~isempty(errorStr)
                throw(MException('transportlib:transport:writeFailed',...
                message('transportlib:transport:writeFailed',errorStr).getString()));
            end
            obj.NumBytesWritten=obj.NumBytesWritten+numBytes;
        end

        function data=read(obj,varargin)














































            try
                narginchk(1,3);
                precision='uint8';
                bytesToRead=obj.NumBytesAvailable;
                switch nargin
                case 2

                    if ischar(varargin{1})||isstring(varargin{1})
                        precision=varargin{1};
                        bytesToRead=obj.getNumValuesToRead(bytesToRead,precision);
                    else
                        bytesToRead=varargin{1};
                    end
                case 3
                    bytesToRead=varargin{1};
                    precision=varargin{2};
                end


                validateattributes(bytesToRead,{'numeric'},{'scalar','nonnegative','finite'},...
                mfilename,'count',2);


                if bytesToRead==0
                    data=[];
                    return;
                end


                validateattributes(precision,{'string','char'},{'nonempty'},mfilename,'precision',3);
                precision=validatestring(precision,obj.ValidPrecisions,mfilename,'precision',3);

            catch validationEx


                obj.LicenseCheckoutFcn();




                ex=MException(message('transportlib:transport:validationError'));
                ex=addCause(ex,validationEx);
                throw(ex);
            end

            if~obj.StructData

                numBytesToRead=obj.getNumBytesToRead(bytesToRead,precision);
            else
                numBytesToRead=bytesToRead;
            end

            try

                data=obj.readRaw(numBytesToRead);
            catch asyncioError
                throw(asyncioError);
            end


            actualType=class(data);
            if~strcmpi(actualType,obj.NativeDataType)
                throw(MException(message('transportlib:transport:incorrectDataType',obj.NativeDataType,actualType)));
            end

            if strcmpi(obj.NativeDataType,'struct')


                if~isempty(obj.DataFieldName)

                    for i=1:length(data)
                        data(i).(obj.DataFieldName)=obj.convertData(data(i).(obj.DataFieldName),precision);
                    end
                end
            else
                data=obj.convertData(data,precision);
            end
        end

        function data=convertData(obj,tempData,precision)


            if any(strcmpi(precision,{'string','char'}))
                if iscell(tempData)
                    for pos=1:length(tempData)
                        tempData{pos}=char(tempData{pos});
                    end
                else
                    tempData=char(tempData);
                end

                if strcmpi(precision,'string')
                    if iscell(tempData)
                        for pos=1:length(tempData)
                            tempData{pos}=string(tempData{pos});
                        end
                    else
                        tempData=string(tempData);
                    end
                end
            else


                if iscell(tempData)
                    for pos=1:length(tempData)
                        tempData{pos}=typecast(tempData{pos},precision);
                    end
                else
                    tempData=typecast(tempData,precision);
                end
                if obj.NeedByteSwap(obj.ByteOrder)
                    if iscell(tempData)
                        for pos=1:length(tempData)
                            tempData{pos}=swapbytes(tempData{pos});
                        end
                    else
                        tempData=swapbytes(tempData);
                    end
                end
            end
            data=tempData;
        end

        function data=readRaw(obj,numBytes)



















            obj.LicenseCheckoutFcn();

            data=[];


            if numBytes<1
                return;
            end


            if length(obj.UnreadData)>=numBytes
                data=obj.getUnreadData(numBytes);
                if obj.StructData
                    tmp.(obj.DataFieldName)=data;
                    data=tmp;
                end
            else
                try %#ok<*EMTC>




                    numBytes=numBytes-length(obj.UnreadData);
                    [data,~,status]=obj.AsyncIOChannel.InputStream.read(numBytes);


                    if strcmp(status,'timeout')&&obj.AllowPartialReads
                        [data,status]=getPartialReadData(obj,numBytes);
                    end
                catch ex
                    rethrow(ex);
                end



                if~isempty(status)
                    errorId=obj.translateAsyncIOStatus(status);
                    throw(MException(message(errorId)));
                end

                data=[obj.getAllUnreadData(),data];
            end

            function[data,status]=getPartialReadData(obj,numBytes)





                status='';
                dataAsyncIO=[];



                numBytes=min(numBytes,obj.AsyncIOChannel.InputStream.DataAvailable);
                if numBytes>0
                    [dataAsyncIO,~,status]=...
                    obj.AsyncIOChannel.InputStream.read(numBytes);
                end



                if~isempty(status)
                    data=[];
                    return
                end







                dataUnread=[];
                if~isempty(obj.UnreadData)
                    dataUnread=obj.getAllUnreadData();
                end





                data=[dataUnread,dataAsyncIO];


                if isempty(data)
                    eID=obj.translateAsyncIOStatus('timeout');
                    throw(MException(message(eID)));
                end
            end
        end

        function data=readUntil(obj,token,wait)























            obj.LicenseCheckoutFcn();
            data=[];

            validateattributes(token,{'string','char','uint8'},{'nonempty'},mfilename,'token',3);
            token=char(token);


            if isequal(nargin,2)
                wait=true;
            end

            if~isempty(obj.UnreadData)




                arridx=strfind(obj.UnreadData,token);

                if~isempty(arridx)

                    data=obj.getUnreadData(arridx+length(token)-1);
                    return;
                end
            end



            tokenFound=false;
            startTic=tic;
            while~tokenFound
                if wait==true

                    errorId=obj.waitForDataAvailable();
                    if~isempty(errorId)
                        throw(MException(message(errorId)));
                    end
                end




                [data,tokenFound]=obj.readStreamUntil(token);
                if~wait
                    break;
                end

                if toc(startTic)>obj.AsyncIOChannel.InputStream.Timeout
                    throw(MException(message('transportlib:transport:timeout')));
                end
            end
        end

        function index=peekBytesFromEnd(obj,lastCallbackIndex,token)






















            index=[];


            [dataRead,dataCount]=obj.AsyncIOChannel.InputStream.read();

            if~isempty(dataCount)
                if obj.StructData
                    tempData=dataRead.(obj.DataFieldName);
                else
                    tempData=dataRead;
                end


                obj.UnreadData=[obj.UnreadData,tempData];
            end

            endIdx=length(obj.UnreadData);


            totalBytesWritten=obj.AsyncIOChannel.TotalBytesWritten;


            startIdx=endIdx-(totalBytesWritten-lastCallbackIndex)+1;

            if startIdx<endIdx
                dataToPeekFrom=obj.UnreadData(startIdx:endIdx);


                index=strfind(dataToPeekFrom,token);
            end
        end

        function[tokenFound,indices]=peekUntil(obj,token)

















            tokenFound=false;
            indices=0;

            validateattributes(token,{'string','char','uint8'},{'nonempty'},mfilename,'token',3);
            token=char(token);


            if~isempty(obj.UnreadData)




                arridx=strfind(obj.UnreadData,token);
                indices=arridx;

                if~isempty(arridx)

                    tokenFound=true;
                end
            end



            if~tokenFound

                [tokenFound,indices]=obj.peekStreamUntil(token);
            end
        end
    end

    methods(Access=private)

        function data=validateData(~,data)


            validateattributes(data,{'numeric','string','char'},{'nonempty'},mfilename,'data',2);

            r=size(data);
            if r>1
                throw(MException(message('transportlib:transport:invalidDataDim',2,'data')));
            end
        end

        function[data,tokenFound]=readStreamUntil(obj,token)






            tokenFound=false;
            data=[];


            [dataRead,countRead]=obj.AsyncIOChannel.InputStream.read();
            if countRead==0
                return;
            end

            if obj.StructData
                tempData=dataRead.(obj.DataFieldName);
            else
                tempData=dataRead;
            end




            searchData=[obj.UnreadData,tempData];




            index=strfind(searchData,token);


            if~isempty(index)
                tokenFound=true;


                index=index(1)+length(token)-1;



                data=searchData(1:index);


                if obj.StructData
                    dataRead.(obj.DataFieldName)=data;
                    data=dataRead;
                end


                obj.getAllUnreadData();


                obj.UnreadData=searchData(index+1:end);
            else

                obj.UnreadData=[obj.UnreadData,tempData];
            end

        end

        function[tokenFound,indices]=peekStreamUntil(obj,token)




            tokenFound=false;
            indices=0;


            [dataRead,countRead]=obj.AsyncIOChannel.InputStream.read();
            if countRead==0
                return;
            end

            if obj.StructData
                tempData=dataRead.(obj.DataFieldName);
            else
                tempData=dataRead;
            end




            obj.UnreadData=[obj.UnreadData,tempData];




            index=strfind(obj.UnreadData,token);
            indices=index;


            if~isempty(index)
                tokenFound=true;
            end
        end

        function errorId=waitForDataAvailable(obj)



            errorId='';
            if~obj.AsyncIOChannel.InputStream.DataAvailable


                status=obj.AsyncIOChannel.InputStream.wait(@(obj)obj.DataAvailable>0);


                errorId=obj.translateAsyncIOStatus(status);
            end
        end

        function data=getUnreadData(obj,arridx)




            arridx=double(arridx);


            data=obj.UnreadData(1:arridx);


            obj.UnreadData(1:arridx)=[];
        end

        function data=getAllUnreadData(obj)


            if~isempty(obj.UnreadData)


                data=obj.UnreadData;


                obj.UnreadData=[];
            else
                data=[];
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

        function errorId=translateAsyncIOStatus(~,status)








            errorId=[];

            if~strcmpi(status,'completed')&&~strcmpi(status,'done')

                if strcmpi(status,'invalid')
                    errorId='transportlib:transport:transportInvalid';
                end
                if strcmpi(status,'timeout')
                    errorId='transportlib:transport:timeout';
                end
            end
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
                throw(MException(message('transportlib:transport:unknownPrecision')));
            end
        end
    end
end