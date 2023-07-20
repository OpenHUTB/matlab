classdef IOServerBlockClient<handle&...
    matlabshared.transportclients.internal.CRC.J1850_CRC














    properties(Constant,Hidden)
        DefaultWriteToken=uint8(170);
        DefaultReadToken=uint8(85);
        DecodeFilter=fullfile(toolboxdir(fullfile('shared','transportlib','bin',computer('arch'))),'ioserverblockfilter');
    end

    properties(Access=private)

        Transport(1,1){mustBeNonempty};
    end

    properties(GetAccess=public,SetAccess=private,Dependent)

        NumBlocksAvailable=0;
    end

    properties(GetAccess=public,SetAccess=private)


        Connected(1,1)logical{mustBeNonempty}=false;
    end

    properties

        ReadStartToken(1,:)uint8{mustBeNonempty}=matlabshared.transportclients.internal.IOServerClient.IOServerBlockClient.DefaultReadToken;


        WriteStartToken(1,:)uint8{mustBeNonempty}=matlabshared.transportclients.internal.IOServerClient.IOServerBlockClient.DefaultWriteToken;



        EnableCRC(1,1){mustBeNumericOrLogical,mustBeBoolean(EnableCRC)}=true;




        MaxExpectedPayloadSize(1,1){mustBeNonzero,mustBeNumeric,mustBeInteger}=-1;



        NotifyOnDecodeFailure(1,1){mustBeNumericOrLogical,mustBeBoolean(NotifyOnDecodeFailure)}=true;



        IOServerBlockReadFcn=function_handle.empty();



        ErrorOccurredFcn=function_handle.empty();



        CallbackLimiter(1,1){mustBeNonempty,mustBeNumeric,mustBePositive}=.5;
    end


    methods
        function obj=IOServerBlockClient(transport)









            narginchk(1,1);


            if~isa(transport,'matlabshared.transportlib.internal.ITransport')||...
                ~isa(transport,'matlabshared.transportlib.internal.IFilterable')
                throw(MException('transportclients:ioserverblock:invalidTransportType',...
                message('transportclients:ioserverblock:invalidTransportType').getString()));
            end
            obj.Transport=transport;



            obj.Transport.ErrorOccurredFcn=@obj.ErrorOccurredCallback;
        end

        function connect(obj)

            try

                options.EnableCRC=obj.EnableCRC;
                options.ReadStartToken=obj.ReadStartToken;
                options.MaxExpectedPayloadSize=obj.MaxExpectedPayloadSize;
                options.NotifyOnDecodeFailure=obj.NotifyOnDecodeFailure;

                obj.Transport.addInputFilter(obj.DecodeFilter,options);
                obj.Transport.NativeDataType='cell';
                obj.Connected=true;
            catch ex
                throwAsCaller(ex);
            end
        end

        function disconnect(obj)


            try
                obj.Transport.removeInputFilter(obj.DecodeFilter);
                obj.Connected=false;
            catch ex
                throwAsCaller(ex);
            end
        end
    end

    methods(Hidden)
        function delete(obj)

            if isa(obj.Transport,'matlabshared.transportlib.internal.ITransport')&&...
                isvalid(obj.Transport)
                obj.IOServerBlockReadFcn=[];
                obj.ErrorOccurredFcn=[];
            end
        end
    end

    methods

        function write(obj,data)








            try
                narginchk(2,2);

                validateattributes(data,{'uint8'},{'nonempty'},mfilename,'data',1);

                r=size(data);
                if(r>1)
                    throw(MException('transportlib:transport:invalidDataDim',...
                    message('transportlib:transport:invalidDataDim',2,'data').getString()));
                end


                obj.validateConnected();

            catch validationEx
                throwAsCaller(validationEx);
            end

            try



                N=uint16(length(data));
                N=typecast(N,'uint8');

                if obj.EnableCRC

                    CRC=obj.calculateCRC(data);
                    sendData=[obj.WriteStartToken,N,data,uint8(CRC)];
                else
                    sendData=[obj.WriteStartToken,N,data];
                end

                obj.Transport.write(sendData);
            catch ex
                throwAsCaller(MException('transportclients:ioserverblock:writeFailed',...
                message('transportclients:ioserverblock:writeFailed',ex.message).getString()));
            end
        end

        function data=read(obj,count)






            try
                narginchk(1,2);
                if nargin==1
                    count=obj.NumBlocksAvailable;
                end

                validateattributes(count,{'numeric'},{'>=',0,'integer','scalar','finite','nonnan'},mfilename,'count',2);


                obj.validateConnected();

            catch validationEx
                throwAsCaller(validationEx);
            end


            if~isempty(obj.IOServerBlockReadFcn)
                throw(MException(message('transportclients:ioserverblock:readWhileStreaming')));
            end

            try
                data=obj.readRaw(count,true);
            catch ex
                throwAsCaller(ex);
            end
        end


        function value=get.NumBlocksAvailable(obj)

            obj.validateConnected();


            value=obj.Transport.NumBytesAvailable;
        end

        function set.IOServerBlockReadFcn(obj,val)


            if isempty(val)
                val=function_handle.empty();
            end
            try
                validateattributes(val,{'function_handle'},{},mfilename,'IOServerBlockReadFcn');



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
            obj.IOServerBlockReadFcn=val;
        end

        function set.ErrorOccurredFcn(obj,val)

            if isempty(val)
                val=function_handle.empty();
            end
            try
                validateattributes(val,{'function_handle'},{},mfilename,'ErrorOccurredFcn');



                if~isequal(val,function_handle.empty())
                    nargin(val);
                end
            catch ex
                throwAsCaller(ex);
            end
            obj.ErrorOccurredFcn=val;
        end

        function set.EnableCRC(obj,val)





            obj.validateDisconnected();


            val=(val==1);

            try
                obj.Transport.tuneInputFilter(struct('EnableCRC',val));%#ok<MCSUP>
            catch ex
                throwAsCaller(ex);
            end
            obj.EnableCRC=val;
        end

        function set.NotifyOnDecodeFailure(obj,val)





            obj.validateDisconnected();

            try
                obj.Transport.tuneInputFilter(struct('NotifyOnDecodeFailure',val));%#ok<MCSUP>
            catch ex
                throwAsCaller(ex);
            end
            obj.NotifyOnDecodeFailure=val;
        end

        function set.ReadStartToken(obj,val)



            obj.validateDisconnected();

            try
                obj.Transport.tuneInputFilter(struct('ReadStartToken',val));%#ok<MCSUP>
            catch ex
                throwAsCaller(ex);
            end
            obj.ReadStartToken=val;
        end

        function set.MaxExpectedPayloadSize(obj,val)







            obj.validateDisconnected();

            try
                obj.Transport.tuneInputFilter(struct('MaxExpectedPayloadSize',val));%#ok<MCSUP>
            catch ex
                throwAsCaller(ex);
            end
            obj.MaxExpectedPayloadSize=val;
        end
    end


    methods(Access=private)

        function data=readRaw(obj,count,wait)














            data=[];
            try
                blocksAvailable=obj.Transport.NumBytesAvailable;
                if blocksAvailable==0&&~wait
                    return;
                end
                data=obj.Transport.readRaw(count);
            catch ex
                errorId=obj.getReadErrorId(ex);
                throw(MException(errorId,message(errorId).getString()));
            end
        end

        function ErrorOccurredCallback(obj,~,evt)




            if isempty(obj.ErrorOccurredFcn)
                return;
            end

            errorId=evt.ID;
            switch errorId
            case{'transportlib:filter:CRCCheckFailed',...
                'transportlib:filter:invalidStartToken',...
                'transportlib:filter:payloadSizeError',...
                'transportlib:filter:unexpectedError',}


                if obj.NotifyOnDecodeFailure&&~isempty(obj.ErrorOccurredFcn)
                    obj.ErrorOccurredFcn(obj,...
                    matlabshared.transportlib.internal.ErrorInfo(errorId,evt.Message));
                end
            otherwise


                if~isempty(obj.ErrorOccurredFcn)
                    obj.ErrorOccurredFcn(obj,...
                    matlabshared.transportlib.internal.ErrorInfo(errorId,message(errorId).getString()));
                else
                    error(errorId,message(errorId).getString());
                end
            end
        end

        function DataAvailableCallback(obj,~,~)


            if isempty(obj.IOServerBlockReadFcn)
                return;
            end

            startTic=tic;
            while true

                data=[];
                errorMsg=[];
                try
                    data=obj.readRaw(obj.NumBlocksAvailable,false);
                catch ex
                    errorMsg=ex.message;
                end



                if~isempty(errorMsg)
                    if~isempty(obj.ErrorOccurredFcn)
                        obj.ErrorOccurredFcn(obj,...
                        matlabshared.transportlib.internal.ErrorInfo('transportclients:ioserverblock:readFailed',message('transportclients:ioserverblock:readFailed',errorMsg).getString()));
                    else
                        error('transportclients:ioserverblock:readFailed',message('transportclients:ioserverblock:readFailed',errorMsg).getString());
                    end
                end

                if~isempty(data)

                    obj.IOServerBlockReadFcn(obj,...
                    matlabshared.transportclients.internal.IOServerClient.IOServerBlockInfo(data));
                else
                    break;
                end


                if toc(startTic)>obj.CallbackLimiter
                    break;
                end
            end
        end

        function errorId=getReadErrorId(~,ex)


            if contains(ex.message,'timeout','IgnoreCase',true)||...
                contains(ex.message,'timed','IgnoreCase',true)
                errorId='transportclients:ioserverblock:timeout';
            elseif contains(ex.identifier,'invalidConnectionState')
                errorId='transportclients:ioserverblock:invalidConnectionState';
            else
                errorId=ex.identifier;
            end
        end

        function validateConnected(obj)




            if~obj.Connected
                throwAsCaller(MException('transportlib:transport:invalidConnectionState',...
                message('transportlib:transport:invalidConnectionState','IOServerBlockClient transport').getString()));
            end
        end

        function validateDisconnected(obj)




            if obj.Connected
                throwAsCaller(MException(message('transportlib:transport:cannotSetWhenConnected')));
            end
        end
    end

    methods(Static=true,Hidden=true)
        function out=loadobj(s)




            out=[];
            if isstruct(s)
                transport=s.Transport;
                if~isempty(transport)
                    connect(transport);
                    out=matlabshared.transportclients.internal.IOServerClient.IOServerBlockClient(transport);
                    out.ReadStartToken=s.ReadStartToken;
                    out.WriteStartToken=s.WriteStartToken;
                    out.EnableCRC=s.EnableCRC;
                    out.CallbackLimiter=s.CallbackLimiter;
                    out.MaxExpectedPayloadSize=s.MaxExpectedPayloadSize;
                    if s.Connected
                        out.connect();
                    end
                end
            end
        end
    end

    methods(Hidden)
        function s=saveobj(obj)

            s.ReadStartToken=obj.ReadStartToken;
            s.WriteStartToken=obj.WriteStartToken;
            s.EnableCRC=obj.EnableCRC;
            s.Transport=obj.Transport;
            s.CallbackLimiter=obj.CallbackLimiter;
            s.MaxExpectedPayloadSize=obj.MaxExpectedPayloadSize;
            s.Connected=obj.Connected;
        end
    end
end

function mustBeBoolean(val)
    if~isequal(val,0)&&...
        ~isequal(val,1)
        error(message('transportlib:transport:invalidLogical').getString());
    end
end