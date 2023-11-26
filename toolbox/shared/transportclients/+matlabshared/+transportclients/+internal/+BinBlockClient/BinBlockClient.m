classdef BinBlockClient<handle&...
    matlabshared.transportlib.internal.ByteOrder

    properties(Access=private)

        ReadState=0;

        DigitsToFollow=[];

        NumBytesToRead=[];

        Transport(1,1){mustBeNonempty};
    end

    properties(Constant,Hidden)


        ValidPrecisions={'uint8','int8','uint16','int16','uint32',...
        'int32','uint64','int64','single','double','char','string'};
    end

    properties(Hidden,Constant)

        StartToken='#';
    end

    properties


        BinBlockReadFcn=function_handle.empty();

        ErrorOccurredFcn=function_handle.empty();


        CallbackLimiter(1,1){mustBeNonempty,mustBeNumeric,mustBePositive}=.5;
    end


    methods
        function obj=BinBlockClient(transport)

            narginchk(1,1);
            if~isa(transport,'matlabshared.transportlib.internal.ITransport')||...
                ~isa(transport,'matlabshared.transportlib.internal.ITokenReader')
                throw(MException('transportclients:binblock:invalidTransportType',...
                message('transportclients:binblock:invalidTransportType').getString()));
            end
            obj.Transport=transport;


            obj.ReadState=0;
        end
    end

    methods(Hidden)
        function delete(obj)

            if isa(obj.Transport,'matlabshared.transportlib.internal.ITransport')...
                &&isvalid(obj.Transport)
                obj.BinBlockReadFcn=[];
            end
        end
    end

    methods

        function write(varargin)

            try
                narginchk(2,4);

                varargin=instrument.internal.stringConversionHelpers.str2char(varargin);
                obj=varargin{1};

                data=varargin{2};
                validateattributes(data,{'numeric','char','string'},{'nonempty'},mfilename,'data',2);

                r=size(data);
                if r>1
                    throw(MException(message('transportlib:transport:invalidDataDim',2,'data')));
                end

                precision='uint8';
                if nargin>=3
                    precision=varargin{3};
                end


                validateattributes(precision,{'string','char'},{'nonempty'},mfilename,'precision',3);
                precision=validatestring(precision,obj.ValidPrecisions,mfilename,'precision',3);

                header='';
                if nargin==4
                    header=varargin{4};

                    validateattributes(header,{'string','char'},{'nonempty'},mfilename,'header',4);
                    header=uint8(char(header));
                end
            catch validationEx
                throwAsCaller(validationEx);
            end

            try


                if~any(strcmpi(precision,{'string','char'}))
                    data=cast(data,precision);
                    if obj.NeedByteSwap(obj.Transport.ByteOrder)
                        data=swapbytes(data);
                    end
                    data=typecast(data,'uint8');
                else


                    data=uint8(char(data));
                end


                D=uint8(num2str(length(data)));
                N=uint8(num2str(length(char(D))));


                obj.Transport.write([header,'#',N,D,data]);
            catch ex
                throwAsCaller(MException('transportclients:binblock:writeFailed',...
                message('transportclients:binblock:writeFailed',ex.message).getString()));
            end
        end

        function data=read(varargin)

            try
                narginchk(1,2);

                varargin=instrument.internal.stringConversionHelpers.str2char(varargin);
                obj=varargin{1};

                precision='uint8';
                if nargin==2
                    precision=varargin{2};
                end


                precision=validatestring(precision,obj.ValidPrecisions,'read','precision',2);

            catch validationEx
                throwAsCaller(validationEx);
            end


            if~isempty(obj.BinBlockReadFcn)
                throw(MException(message('transportclients:binblock:readWhileStreaming')));
            end

            try
                obj.ReadState=0;
                data=obj.readRaw(true);


                if any(strcmpi(precision,{'string','char'}))
                    data=char(data);

                    if strcmpi(precision,'string')
                        data=string(data);
                    end
                else
                    data=typecast(data,precision);
                    if obj.NeedByteSwap(obj.Transport.ByteOrder)
                        data=swapbytes(data);
                    end
                end
            catch ex
                throwAsCaller(ex);
            end
        end


        function set.BinBlockReadFcn(obj,val)

            if isempty(val)
                val=function_handle.empty();
            end
            try
                validateattributes(val,{'function_handle'},{},mfilename,'BinBlockReadFcn');



                if~isequal(val,function_handle.empty())
                    nargin(val);
                end




                if~isempty(val)
                    obj.Transport.BytesAvailableEventCount=1;%#ok<MCSUP>
                    obj.Transport.BytesAvailableFcn=@obj.DataAvailableCallback;%#ok<MCSUP>
                else
                    obj.Transport.BytesAvailableFcn=[];%#ok<MCSUP>
                end
            catch ex
                throwAsCaller(ex);
            end
            obj.BinBlockReadFcn=val;
        end

        function set.ErrorOccurredFcn(obj,val)

            if isempty(val)
                val=function_handle.empty();
            end
            try
                validateattributes(val,{'function_handle'},{},mfilename,'ErrorOccurredFcn');
            catch ex
                throwAsCaller(ex);
            end
            obj.ErrorOccurredFcn=val;
        end
    end


    methods(Access=private)

        function data=readRaw(obj,wait)

            data=[];
            errorId='';
            done=false;

            try
                bytesAvailable=obj.Transport.NumBytesAvailable;
            catch ex
                errorId=obj.getReadErrorId(ex);
                throw(MException(message(errorId)));
            end
            while~done
                switch obj.ReadState
                case 0


                    try
                        tmp=obj.Transport.readUntil(obj.StartToken,wait);
                    catch ex
                        errorId=obj.getReadErrorId(ex);
                        break;
                    end
                    if isempty(tmp)
                        break;
                    end
                    obj.ReadState=1;
                case 1
                    if~wait&&bytesAvailable<1
                        break;
                    end


                    try
                        obj.DigitsToFollow=obj.Transport.readRaw(1);
                    catch ex
                        errorId=obj.getReadErrorId(ex);
                        break;
                    end
                    [obj.DigitsToFollow,n,errorStr]=sscanf(char(obj.DigitsToFollow),'%d');
                    if~isequal(n,1)||~isempty(errorStr)||obj.DigitsToFollow<1
                        errorId='transportclients:binblock:binBlockFormatError';
                        break;
                    end
                    obj.ReadState=2;
                case 2
                    if~wait&&bytesAvailable<obj.DigitsToFollow
                        break;
                    end

                    try
                        obj.NumBytesToRead=obj.Transport.readRaw(obj.DigitsToFollow);
                    catch ex
                        errorId=obj.getReadErrorId(ex);
                        break;
                    end

                    [obj.NumBytesToRead,n,errorStr]=sscanf(char(obj.NumBytesToRead),'%d');
                    if~isequal(n,1)||~isempty(errorStr)||obj.NumBytesToRead<1
                        errorId='transportclients:binblock:binBlockFormatError';
                        break;
                    end
                    obj.ReadState=3;
                case 3
                    if~wait&&bytesAvailable<obj.NumBytesToRead
                        break;
                    end

                    try
                        data=obj.Transport.readRaw(obj.NumBytesToRead);
                    catch ex
                        errorId=obj.getReadErrorId(ex);
                        break;
                    end
                    obj.ReadState=0;
                    done=true;
                end
            end

            if~isempty(errorId)
                obj.ReadState=0;
                if obj.Transport.Connected
                    obj.Transport.flushInput();
                end
                throw(MException(message(errorId)));
            end
        end

        function DataAvailableCallback(obj,~,~)


            if isempty(obj.BinBlockReadFcn)
                return;
            end

            startTic=tic;
            while true

                data=[];
                errorId=[];
                try
                    data=obj.readRaw(false);
                catch ex
                    errorId=ex.identifier;
                end



                if errorId
                    if~isempty(obj.ErrorOccurredFcn)
                        obj.ErrorOccurredFcn(obj,...
                        matlabshared.transportlib.internal.ErrorInfo(errorId,message(errorId).getString()));
                    else
                        warning(message(errorId).getString());
                    end
                end

                if~isempty(data)

                    obj.BinBlockReadFcn(obj,...
                    matlabshared.transportclients.internal.BinBlockClient.BinBlockInfo({data},1));
                else
                    break;
                end


                if toc(startTic)>obj.CallbackLimiter
                    break;
                end
            end
        end

        function errorId=getReadErrorId(obj,ex)


            if contains(ex.message,'timeout','IgnoreCase',true)||...
                contains(ex.message,'timed','IgnoreCase',true)
                if obj.ReadState==0
                    errorId='transportclients:binblock:timeoutToken';
                else
                    errorId='transportclients:binblock:timeout';
                end
            elseif contains(ex.identifier,'invalidConnectionState')
                errorId='transportclients:binblock:invalidConnectionState';
            else
                errorId=ex.identifier;
            end
        end
    end

    methods(Static=true,Hidden=true)
        function out=loadobj(s)




            out=[];
            if isstruct(s)
                transport=s.Transport;
                if~isempty(transport)
                    out=matlabshared.transportclients.internal.BinBlockClient.BinBlockClient(transport);
                    out.CallbackLimiter=s.CallbackLimiter;
                end
            end
        end
    end

    methods(Hidden)
        function s=saveobj(obj)

            s.CallbackLimiter=obj.CallbackLimiter;
            s.Transport=obj.Transport;
        end
    end
end