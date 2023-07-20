
classdef DriverBaseClass<hgsetget&instrument.internal.InstrumentBaseClass









    properties(SetAccess=private,GetAccess=private)





ResetListener
    end


    methods(Hidden)
        function obj=DriverBaseClass()


            obj.ResetListener=event.listener(instrument.internal.udm.InstrumentManager.getInstance,'ResetEvent',@obj.resetInstrument);

        end

        function resetInstrument(obj,~,~)
            try
                resetImpl(obj)
            catch e %#ok<NASGU>

            end
        end
    end


    methods(Hidden)
        function result=addlistener(obj)

            obj.throwUnsupportedError();
        end
        function result=empty(obj)

            obj.throwUnsupportedError();
        end

        function result=ctranspose(obj)

            obj.throwUnsupportedError();
        end

        function result=eq(obj,anotherObj)%#ok<*STOUT>

            result=obj.eq@handle(anotherObj);
        end

        function result=gt(obj,~)

            obj.throwUnsupportedError();
        end

        function result=ge(obj,~)

            obj.throwUnsupportedError();
        end

        function result=fieldnames(obj)

            result=obj.fieldnames@handle();
        end

        function result=fields(obj)

            result=obj.fields@handle();
        end

        function result=findobj(obj,varargin)

            result=obj.findobj@handle(varargin{:});
        end

        function result=findprop(obj,varargin)

            result=obj.findprop@handle(varargin{:});
        end

        function result=le(obj,~)

            obj.throwUnsupportedError();
        end
        function result=lt(obj,~)

            obj.throwUnsupportedError();
        end

        function result=ne(obj,anotherObj)

            result=obj.ne@handle(anotherObj);
        end

        function notify(obj,varargin)

            obj.notify@handle(varargin{:});
        end

        function result=permute(obj,varargin)
            obj.throwUnsupportedError();
        end

        function result=reshape(obj,varargin)
            obj.throwUnsupportedError();
        end

        function result=transpose(obj)
            obj.throwUnsupportedError();
        end


        function result=sort(obj)

            obj.throwUnsupportedError();
        end

    end



    methods(Access=protected)

        function result=checkCharArg(obj,newValue)%#ok<*MANU>
            if~isempty(newValue)
                validateattributes(newValue,{'char'},{'scalar'});
                result=newValue;
            end
        end

        function result=checkScalarBoolArg(obj,newValue)
            newValue=logical(newValue);
            validateattributes(newValue,{'logical'},{'scalar'});
            result=newValue;
        end


        function result=checkVectorBoolArg(obj,newValue)
            newValue=logical(newValue);
            validateattributes(newValue,{'logical'},{'vector'});
            result=newValue;
        end


        function result=checkDoubleArg(obj,newValue)
            newValue=double(newValue);
            validateattributes(newValue,{'double'},{'scalar'});
            result=double(newValue);
        end

        function result=checkVectorSingleArg(obj,newValue)
            newValue=single(newValue);
            validateattributes(newValue,{'single'},{'vector'});
            result=single(newValue);
        end

        function result=checkScalarUint8Arg(obj,newValue)
            newValue=uint8(newValue);
            validateattributes(newValue,{'uint8'},{'scalar'});
            result=newValue;
        end

        function result=checkScalarInt16Arg(obj,newValue)
            newValue=int16(newValue);
            validateattributes(newValue,{'int16'},{'scalar'});
            result=newValue;
        end

        function result=checkVectorInt16Arg(obj,newValue)
            newValue=int16(newValue);
            validateattributes(newValue,{'int16'},{'vector'});
            result=newValue;
        end

        function result=checkScalarInt32Arg(obj,newValue)
            newValue=int32(newValue);
            validateattributes(newValue,{'int32'},{'scalar'});
            result=int32(newValue);
        end

        function result=checkInt32Arg(obj,newValue)
            newValue=int32(newValue);
            validateattributes(newValue,{'int32'},{'vector'});
            result=int32(newValue);
        end

        function result=checkScalarInt64Arg(obj,newValue)
            newValue=int64(newValue);
            validateattributes(newValue,{'int64'},{'scalar'});
            result=newValue;
        end

        function result=checkVectorInt32Arg(obj,newValue)
            newValue=int32(newValue);
            validateattributes(newValue,{'int32'},{'vector'});
            result=newValue;
        end

        function result=checkScalarDoubleArg(obj,newValue)
            newValue=double(newValue);
            validateattributes(newValue,{'double'},{'scalar'});
            result=newValue;
        end

        function result=checkVectorDoubleArg(obj,newValue)
            newValue=double(newValue);
            validateattributes(newValue,{'double'},{'vector'});
            result=newValue;
        end

        function result=checkScalarStringArg(obj,newValue)
            if~isempty(newValue)
                validateattributes(newValue,{'char'},{'vector'});
            end
            result=newValue;
        end

        function result=checkVectorStringArg(obj,newValue)
            if~isempty(newValue)
                newValue=char(newValue);
                validateattributes(newValue,{'char'},{'vector'});
                result=newValue;
            end
        end
    end



    methods(Access=protected)
        function throwUnsupportedError(obj)



            fcnName=dbstack;fcnName=fcnName(2).name;
            error(message('instrument:general:unsupported',fcnName,class(obj)));
        end
    end
end
