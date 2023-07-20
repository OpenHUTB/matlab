classdef(Sealed)UDP<matlabshared.network.internal.UDPBase







































    properties(GetAccess=public,SetAccess=private,Dependent)

NumDatagramsAvailable


NumDatagramsWritten
    end

    properties(Access=public)




        DatagramsAvailableEventCount=1



        DatagramsAvailableFcn=function_handle.empty()



        LastCallbackVal=0
    end

    properties(Hidden,Dependent)




        AllowPartialReads(1,1)logical{mustBeNonempty}
    end



    methods
        function set.AllowPartialReads(obj,val)

            try
                obj.validateConnected();
            catch ex
                throwAsCaller(ex);
            end
            obj.TransportChannel.AllowPartialReads=val;
        end

        function value=get.AllowPartialReads(obj)

            obj.validateConnected();
            value=obj.TransportChannel.AllowPartialReads;
        end

        function set.DatagramsAvailableEventCount(obj,val)
            try
                validateattributes(val,{'numeric'},{'>',0,'integer','scalar','finite','nonnan'},mfilename,'DatagramsAvailableEventCount');
            catch ex
                throwAsCaller(ex);
            end
            obj.DatagramsAvailableEventCount=val;
        end

        function set.DatagramsAvailableFcn(obj,val)
            if isempty(val)
                val=function_handle.empty();
            end
            try
                validateattributes(val,{'function_handle'},{},mfilename,'DatagramsAvailableFcn');
            catch ex
                throwAsCaller(ex);
            end


            obj.recalculateLastCBValue();
            obj.DatagramsAvailableFcn=val;
        end

        function value=get.NumDatagramsAvailable(obj)

            obj.validateConnected();
            value=obj.TransportChannel.NumBytesAvailable;
        end

        function value=get.NumDatagramsWritten(obj)

            obj.validateConnected();
            value=double(obj.AsyncIOChannel.NumDatagramsWritten);
        end
    end


    methods(Access=public)



        function obj=UDP(varargin)





















            obj@matlabshared.network.internal.UDPBase();
            try

                inputs=instrument.internal.stringConversionHelpers.str2char(varargin(1:end));


                obj.initProperties(inputs);
            catch validationException
                throwAsCaller(validationException);
            end
        end


        function[data,datagramaddress,datagramport]=read(varargin)




















































            narginchk(1,3);
            data=[];
            datagramaddress=[];
            datagramport=[];
            datagramtype=[];

            try
                obj=varargin{1};
                obj.validateConnected();
            catch validationEx
                throwAsCaller(validationEx);
            end

            try



                udpRaw=strcmp(obj.NativeDataType,'struct')&&...
                strcmp(obj.DataFieldName,'Data');

                ret=obj.TransportChannel.read(varargin{2:end});
                isRetUdp=isfield(ret,{'Address','Port','IsIpv4'});
                if udpRaw&&all(isRetUdp)
                    for i=1:length(ret)
                        data{i}=ret(i).Data;
                        datagramaddress{i}=ret(i).Address;
                        datagramport{i}=ret(i).Port;
                        datagramtype{i}=ret(i).IsIpv4;
                    end
                else
                    data=ret;
                end
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
    end

    methods(Access=protected)


        function initProperties(obj,inputs)









            p=initProperties@matlabshared.network.internal.UDPBase(obj,inputs);
            fields=fieldnames(p.Unmatched);



            newInputs={};



            for i=1:length(fields)
                newInputs{end+1}=fields{i};
                newInputs{end+1}=p.Unmatched.(fields{i});%#ok<*AGROW>
            end


            addParameter(p,'OutputDatagramPacketSize',512,@isscalar);



            p.KeepUnmatched=false;
            parse(p,newInputs{:});

            output=p.Results;
            obj.OutputDatagramPacketSize=output.OutputDatagramPacketSize;
        end

        function initializeChannel(obj)




            options.OutputDatagramPacketSize=obj.OutputDatagramPacketSize;
            initializeChannel@matlabshared.network.internal.UDPBase(obj,options);
        end
    end

    methods(Hidden)
        function onDataReceived(obj,~,~)


            if isempty(obj.DatagramsAvailableFcn)
                return;
            end



            deltaFromLastCallback=obj.AsyncIOChannel.TotalDatagramsWritten-obj.LastCallbackVal;





            numCallbacks=floor(double(deltaFromLastCallback)/double(obj.DatagramsAvailableEventCount));

            for idx=1:numCallbacks






                if isempty(obj.DatagramsAvailableFcn)
                    break;
                end

                obj.DatagramsAvailableFcn(obj,...
                matlabshared.transportlib.internal.DataAvailableInfo(obj.DatagramsAvailableEventCount));
            end




            obj.LastCallbackVal=obj.LastCallbackVal+...
            numCallbacks*obj.DatagramsAvailableEventCount;
        end

        function recalculateLastCBValue(obj)








            if~isempty(obj.AsyncIOChannel)&&obj.Connected
                obj.LastCallbackVal=...
                obj.AsyncIOChannel.TotalDatagramsWritten-obj.NumDatagramsAvailable;
            else
                obj.LastCallbackVal=0;
            end
        end
    end

    methods(Static=true,Hidden=true)
        function out=loadobj(s)




            out=[];
            if isstruct(s)
                out=matlabshared.network.internal.UDP();
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


    methods(Hidden)

        function s=saveobj(obj)


            s=saveobj@matlabshared.network.internal.UDPBase(obj);

        end
    end
end