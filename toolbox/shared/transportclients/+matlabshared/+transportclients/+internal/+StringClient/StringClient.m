classdef StringClient<handle

    properties(Access=private)

        Transport(1,1){mustBeNonempty};
    end

    properties(GetAccess=public,SetAccess=private,Hidden)

        UserTerminator=[]
    end

    properties(Constant)
        TerminatorRange={0,255}
    end

    properties

        Terminator=uint8(10)
        StringReadFcn=function_handle.empty()
        ErrorOccurredFcn=function_handle.empty()

        CallbackLimiter(1,1){mustBeNonempty,mustBeNumeric,mustBePositive}=0.5

        LastCallbackIdx=0
    end


    methods
        function obj=StringClient(varargin)

            narginchk(1,3);
            varargin=instrument.internal.stringConversionHelpers.str2char(varargin);

            try
                transport=varargin{1};
                if~isa(transport,'matlabshared.transportlib.internal.ITransport')||...
                    ~isa(transport,'matlabshared.transportlib.internal.ITokenReader')
                    throw(MException(message('transportclients:string:invalidTransportType')));
                end
                obj.Transport=transport;


                inputs=varargin(2:end);
                obj.initProperties(inputs);
            catch ex
                throwAsCaller(ex);
            end
        end
    end

    methods(Hidden)
        function delete(obj)

            if isa(obj.Transport,'matlabshared.transportlib.internal.ITransport')...
                &&isvalid(obj.Transport)
                obj.StringReadFcn=function_handle.empty();
            end
        end
    end

    methods

        function write(varargin)

            try
                narginchk(2,2);

                varargin=instrument.internal.stringConversionHelpers.str2char(varargin);
                obj=varargin{1};


                data=varargin{2};
                try
                    validateattributes(data,{'char','string'},{'nonempty'},mfilename,'string',2);
                catch ex
                    throw(MException('transportlib:transport:invalidDataType',...
                    message('transportlib:transport:invalidDataType',2,'data').getString()));
                end
                r=size(data);
                if r>1
                    throw(MException('transportlib:transport:invalidDataDim',...
                    message('transportlib:transport:invalidDataDim',2,'data').getString()));
                end

            catch validationException
                throwAsCaller(validationException);
            end

            try

                data=[uint8(data),obj.getWriteTerminator()];

                obj.Transport.write(data,'uint8');
            catch ex
                throwAsCaller(MException('transportclients:string:writeFailed',...
                message('transportclients:string:writeFailed',ex.message).getString()));
            end
        end

        function data=read(varargin)

            try
                narginchk(1,2);

                varargin=instrument.internal.stringConversionHelpers.str2char(varargin);
                obj=varargin{1};

                precision='char';
                if isequal(nargin,2)
                    precision=varargin{2};
                end


                precision=validatestring(precision,{'char','string'},mfilename,'precision',2);

            catch validationException
                throwAsCaller(validationException);
            end

            try

                data=obj.readRaw(true);
                data=data(1:end-length(obj.getReadTerminator()));
                data=char(data);
                if strcmpi(precision,'string')
                    data=string(data);
                end
            catch ex
                throwAsCaller(ex);
            end
        end


        function set.StringReadFcn(obj,val)

            if isempty(val)
                val=function_handle.empty();
            end
            try
                validateattributes(val,{'function_handle'},{},mfilename,'StringReadFcn');

                if~isequal(val,function_handle.empty())
                    nargin(val);
                end

                if~isempty(val)
                    obj.Transport.BytesAvailableEventCount=1;
                    obj.Transport.BytesAvailableFcn=@obj.DataAvailableCallback;
                else
                    obj.Transport.BytesAvailableFcn=[];
                end
            catch ex
                throwAsCaller(ex);
            end


            obj.recalculateLastCBIndex();
            obj.StringReadFcn=val;
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

        function out=get.Terminator(obj)
            out=obj.Terminator;
        end

        function set.Terminator(obj,value)

            try
                oldValue=obj.UserTerminator;%#ok<*MCSUP>


                if isempty(oldValue)
                    obj.UserTerminator="LF";
                else
                    obj.UserTerminator=value;
                end

                value=instrument.internal.stringConversionHelpers.str2char(value);


                validateattributes(value,{'char','string','numeric','cell'},{},mfilename,'Terminator');

                if iscell(value)
                    [r,c]=size(value);
                    if~isequal(r,1)||~isequal(c,2)
                        throw(MException(message('transportclients:string:invalidTerminatorDim')));
                    end
                    valueNew{1,1}=obj.validateTerminator(value{1,1});
                    valueNew{1,2}=obj.validateTerminator(value{1,2});
                else
                    if isnumeric(value)&&~isscalar(value)
                        throw(MException(message('transportclients:string:invalidTerminatorDim')));
                    end
                    valueNew=obj.validateTerminator(value);
                end
            catch ex


                obj.UserTerminator=oldValue;
                throwAsCaller(ex);
            end


            obj.Terminator=valueNew;
        end
    end


    methods(Access=private)

        function initProperties(obj,inputs)

            p=inputParser;
            p.PartialMatching=true;
            addParameter(p,'Terminator',10,@(x)validateattributes(x,{'char','string','numeric','cell'},{'nonempty'}));
            parse(p,inputs{:});
            output=p.Results;

            obj.Terminator=output.Terminator;
        end

        function value=getReadTerminator(obj)

            if iscell(obj.Terminator)
                value=obj.Terminator{1,1};
            else
                value=obj.Terminator;
            end
        end

        function value=getWriteTerminator(obj)

            if iscell(obj.Terminator)
                value=obj.Terminator{1,2};
            else
                value=obj.Terminator;
            end
        end

        function value=validateTerminator(obj,value)


            if ischar(value)
                if strcmpi(value,'CR/LF')
                    value=uint8([13,10]);
                elseif strcmpi(value,'LF/CR')
                    value=uint8([10,13]);
                elseif strcmpi(value,'LF')
                    value=uint8(10);
                elseif strcmpi(value,'CR')
                    value=uint8(13);
                else
                    throw(MException(message('transportclients:string:invalidTerminator')));
                end
            else
                if value<obj.TerminatorRange{1}||value>obj.TerminatorRange{2}
                    throw(MException(message('transportclients:string:invalidTerminator')));
                end
                value=uint8(value);
            end
        end

        function data=readRaw(obj,wait)

            try
                data=obj.Transport.readUntil(obj.getReadTerminator,wait);
            catch ex

                errorId=obj.getReadErrorId(ex);
                if~isempty(errorId)
                    throw(MException(message(errorId)));
                else
                    throw(ex);
                end
            end
        end

        function DataAvailableCallback(obj,~,~)

            if isempty(obj.StringReadFcn)
                return;
            end
            startTic=tic;
            while true

                idx=[];
                errorId=[];
                numBytesWritten=obj.Transport.getTotalBytesWritten();
                try
                    if~isempty(numBytesWritten)
                        readTerminator=obj.getReadTerminator;
                        idx=obj.Transport.peekBytesFromEnd(obj.LastCallbackIdx,readTerminator);

                        if isequal(readTerminator,[13,10])
                            idx=idx+1;
                        end
                    end
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

                if~isempty(idx)
                    numCallbacksToFire=length(idx);
                    obj.LastCallbackIdx=obj.LastCallbackIdx+idx(end);


                    for i=1:numCallbacksToFire
                        if~isempty(obj.StringReadFcn)
                            obj.StringReadFcn(obj,...
                            matlabshared.transportclients.internal.StringClient.StringInfo(1));
                        end
                    end
                else
                    break;
                end

                if toc(startTic)>obj.CallbackLimiter
                    break;
                end
            end
        end

        function errorId=getReadErrorId(~,ex)

            errorId=[];
            if contains(ex.message,'timeout','IgnoreCase',true)||...
                contains(ex.message,'timed','IgnoreCase',true)
                errorId='transportclients:string:timeoutToken';
            elseif contains(ex.identifier,'invalidConnectionState')
                errorId='transportclients:string:invalidConnectionState';
            end
        end

        function recalculateLastCBIndex(obj)
            if~isempty(obj.Transport)&&obj.Transport.Connected
                obj.LastCallbackIdx=...
                obj.Transport.getTotalBytesWritten()-obj.Transport.NumBytesAvailable;
            else
                obj.LastCallbackIdx=0;
            end
        end
    end

    methods(Static=true,Hidden=true)
        function out=loadobj(s)

            out=[];
            if isstruct(s)
                transport=s.Transport;
                if~isempty(transport)
                    out=matlabshared.transportclients.internal.StringClient.StringClient(transport);
                    out.Terminator=getLoadObjTerminator(s.Terminator);
                    out.CallbackLimiter=s.CallbackLimiter;
                end
            end

            function value=getLoadObjTerminator(value)

                if iscell(value)
                    value{1}=convertNumericCRLFTerminator(value{1});
                    value{2}=convertNumericCRLFTerminator(value{2});
                else
                    value=convertNumericCRLFTerminator(value);
                end

                function value=convertNumericCRLFTerminator(value)

                    if isnumeric(value)
                        if~isscalar(value)&&value(1)==13&&value(2)==10
                            value="CR/LF";
                        end
                    end
                end
            end
        end

    end

    methods(Hidden)
        function s=saveobj(obj)

            s.Terminator=obj.Terminator;
            s.Transport=obj.Transport;
            s.CallbackLimiter=obj.CallbackLimiter;
        end
    end
end