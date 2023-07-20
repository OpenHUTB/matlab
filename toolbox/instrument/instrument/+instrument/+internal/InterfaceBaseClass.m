classdef InterfaceBaseClass<handle&instrument.internal.InstrumentBaseClass











    methods(Hidden)
        function result=addlistener(obj)%#ok<*STOUT>

            obj.throwUnsupportedError();
        end
        function result=empty(obj)

            obj.throwUnsupportedError();
        end

        function result=ctranspose(obj)

            obj.throwUnsupportedError();
        end

        function result=eq(obj,~)

            obj.throwUnsupportedError();
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

            obj.throwUnsupportedError();
        end

        function result=findprop(obj,varargin)

            obj.throwUnsupportedError();
        end

        function result=le(obj,~)

            obj.throwUnsupportedError();
        end
        function result=lt(obj,~)

            obj.throwUnsupportedError();
        end

        function result=ne(obj,~)

            obj.throwUnsupportedError();
        end

        function notify(obj,varargin)

            obj.throwUnsupportedError();
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
        function throwUnsupportedError(obj)


            fcnName=dbstack;fcnName=fcnName(2).name;
            error(message('instrument:general:unsupported',fcnName,class(obj)));
        end
    end
end
