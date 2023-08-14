classdef(Sealed)UDPByte<matlabshared.transportlib.internal.ITransport&...
    matlabshared.transportlib.internal.ITokenReader&...
    matlabshared.network.internal.UDPBase







































    properties(GetAccess=public,SetAccess=private,Dependent)


NumBytesAvailable
    end

    properties(Hidden,Constant)


        DefaultBytesAvailableEventCount=64
    end

    properties



        BytesAvailableEventCount=...
        matlabshared.network.internal.UDPByte.DefaultBytesAvailableEventCount



        BytesAvailableFcn=function_handle.empty();







        SingleCallbackMode=false



        LastCallbackVal=0
    end

    properties(Hidden,Dependent)




        AllowPartialReads(1,1)logical{mustBeNonempty}
    end

    methods
        function value=get.AllowPartialReads(obj)

            obj.validateConnected();
            value=obj.TransportChannel.AllowPartialReads;
        end

        function set.BytesAvailableFcn(obj,val)
            if isempty(val)
                val=function_handle.empty();
            end
            try
                validateattributes(val,{'function_handle'},{},mfilename,'BytesAvailableFcn');



                if~isequal(val,function_handle.empty())


                    nargin(val);
                end
            catch ex
                throwAsCaller(ex);
            end


            obj.recalculateLastCBValue();
            obj.BytesAvailableFcn=val;
        end

        function set.BytesAvailableEventCount(obj,val)
            try
                validateattributes(val,{'numeric'},{'>',0,'integer','scalar','finite','nonnan'},mfilename,'BytesAvailableEventCount');
            catch ex
                throwAsCaller(ex);
            end
            obj.BytesAvailableEventCount=val;
        end

        function set.AllowPartialReads(obj,val)

            try
                obj.validateConnected();
            catch ex
                throwAsCaller(ex);
            end
            obj.TransportChannel.AllowPartialReads=val;
        end

        function value=get.NumBytesAvailable(obj)

            try
                obj.validateConnected();
            catch ex
                throwAsCaller(ex);
            end
            value=obj.TransportChannel.NumBytesAvailable;
        end

        function obj=UDPByte(varargin)




















            obj@matlabshared.network.internal.UDPBase;
            try
                inputs=instrument.internal.stringConversionHelpers.str2char(varargin(1:end));


                obj.initProperties(inputs);
            catch validationException
                throwAsCaller(validationException);
            end
        end

        function connect(obj)





            connect@matlabshared.network.internal.UDPBase(obj);
        end

        function disconnect(obj)





            disconnect@matlabshared.network.internal.UDPBase(obj);
        end

        function data=read(varargin)













































            try
                narginchk(1,3);
                obj=varargin{1};
                obj.validateConnected();

            catch validationEx
                throwAsCaller(validationEx);
            end

            try
                data=obj.TransportChannel.read(varargin{2:end});
            catch ex



                if obj.AllowPartialReads&&...
                    strcmpi(ex.identifier,'transportlib:transport:timeout')
                    data=[];
                    return
                end

                if~isempty(ex.cause)
                    throwAsCaller(ex.cause{1});
                else
                    throwAsCaller(MException('network:udp:receiveFailed',...
                    message('network:udp:receiveFailed',ex.message).getString()));
                end
            end
        end

        function data=readUntil(varargin)















            try
                narginchk(2,3);
                obj=varargin{1};
                obj.validateConnected();
            catch validationEx
                throwAsCaller(validationEx);
            end

            try
                data=obj.TransportChannel.readUntil(varargin{2:end});
            catch ex
                throwAsCaller(MException('network:udp:receiveFailed',...
                message('network:udp:receiveFailed',ex.message).getString()));
            end
        end

        function tokenFound=peekUntil(obj,token)

















            try
                obj.validateConnected();
            catch validationEx
                throwAsCaller(validationEx);
            end

            try
                tokenFound=obj.TransportChannel.peekUntil(token);
            catch ex
                throwAsCaller(MException('network:udp:peekFailed',...
                message('network:udp:peekFailed',ex.message).getString()));
            end
        end

        function data=getTotalBytesWritten(obj)



            data=[];
            if~isempty(obj.AsyncIOChannel)
                data=obj.AsyncIOChannel.TotalBytesWritten;
            end
        end

        function index=peekBytesFromEnd(obj,lastCallbackIndex,token)






















            try
                narginchk(3,3);
                obj.validateConnected();
            catch validationEx
                throwAsCaller(validationEx);
            end

            try
                index=obj.TransportChannel.peekBytesFromEnd(lastCallbackIndex,token);
            catch ex
                throwAsCaller(MException('network:udp:peekFailed',...
                message('network:udp:peekFailed',ex.message).getString()));
            end
        end

        function write(varargin)





























            write@matlabshared.network.internal.UDPBase(varargin{:});
        end

        function data=readRaw(varargin)


























            data=readRaw@matlabshared.network.internal.UDPBase(varargin{:});
        end
    end

    methods(Access=protected)

        function initProperties(obj,inputs)









            p=initProperties@matlabshared.network.internal.UDPBase(obj,inputs);
            fields=fieldnames(p.Unmatched);



            newInputs={};
            for i=1:length(fields)
                newInputs{end+1}=fields{i};%#ok<*AGROW>
                newInputs{end+1}=p.Unmatched.(fields{i});
            end
            p.KeepUnmatched=false;



            parse(p,newInputs{:});
        end
    end

    methods(Hidden)


        function onDataReceived(obj,~,~)


            if isempty(obj.BytesAvailableFcn)
                return;
            end


            if obj.SingleCallbackMode
                obj.BytesAvailableFcn(obj,...
                matlabshared.transportlib.internal.DataAvailableInfo(obj.BytesAvailableEventCount));

            else


                deltaFromLastCallback=obj.AsyncIOChannel.TotalBytesWritten-obj.LastCallbackVal;





                numCallbacks=floor(double(deltaFromLastCallback)/double(obj.BytesAvailableEventCount));

                for idx=1:numCallbacks






                    if isempty(obj.BytesAvailableFcn)
                        break;
                    end

                    obj.BytesAvailableFcn(obj,...
                    matlabshared.transportlib.internal.DataAvailableInfo(obj.BytesAvailableEventCount));
                end




                obj.LastCallbackVal=obj.LastCallbackVal+...
                numCallbacks*obj.BytesAvailableEventCount;
            end
        end

        function recalculateLastCBValue(obj)








            if~isempty(obj.AsyncIOChannel)&&obj.Connected
                obj.LastCallbackVal=...
                obj.AsyncIOChannel.TotalBytesWritten-obj.NumBytesAvailable;
            else
                obj.LastCallbackVal=0;
            end
        end

        function s=saveobj(obj)


            s=saveobj@matlabshared.network.internal.UDPBase(obj);

        end
    end

    methods(Static=true,Hidden=true)
        function out=loadobj(s)




            out=[];
            if isstruct(s)
                out=matlabshared.network.internal.UDPByte();
                out=loadobj@matlabshared.network.internal.UDPBase(out,s);



                if strcmpi(s.Connected,'Connected')
                    try
                        out.connect();
                    catch connectFailed



                        warning('network:udp:connectFailed','%s',connectFailed.message);
                    end
                end
            end
        end
    end
end