classdef InstrumentImpl<instrument.internal.InstrumentBaseClass&handle





    properties(Hidden)
BinblockClient
StringClient
Transport
        ICTLicenseFcn(1,1)function_handle=...
        instrument.internal.InterfaceFunctionGetter.InstrumentLicenseFcn
    end

    methods
        function obj=InstrumentImpl(transport,stringClient)



            obj@instrument.internal.InstrumentBaseClass();


            if~isa(transport,'matlabshared.transportlib.internal.ITransport')
                throwAsCaller(...
                MException(message('transportlib:transport:invalidTransportType')));
            end


            if~isa(stringClient,'matlabshared.transportclients.internal.StringClient.StringClient')
                throwAsCaller(...
                MException(message('transportclients:string:notStringClient','stringClient')));
            end

            try
                obj.Transport=transport;
                obj.BinblockClient=...
                matlabshared.transportclients.internal.BinBlockClient.BinBlockClient(obj.Transport);
                obj.StringClient=stringClient;
            catch ex
                throwAsCaller(ex);
            end
        end

        function data=readbinblock(obj,varargin)


            try

                obj.ICTLicenseFcn();

                data=read(obj.BinblockClient,varargin{:});
            catch ex
                throwAsCaller(ex);
            end
        end

        function writebinblock(obj,varargin)


            try

                obj.ICTLicenseFcn();

                write(obj.BinblockClient,varargin{:});
            catch ex
                throwAsCaller(ex);
            end
        end

        function response=writeread(obj,varargin)



            try

                obj.ICTLicenseFcn();

                narginchk(2,2);
                write(obj.StringClient,varargin{:});
                response=read(obj.StringClient,class(varargin{1}));
            catch ex
                throwAsCaller(ex);
            end
        end

        function delete(obj)

            obj.BinblockClient=[];
            obj.StringClient=[];
            obj.Transport=[];
        end
    end
end