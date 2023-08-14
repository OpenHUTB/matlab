classdef(Abstract,Hidden)Object<handle






    methods(Hidden,Access=public)

        function result=findobj(this,varargin)
            result=findobj@handle(this,varargin{:});
        end

        function result=findprop(this,varargin)
            result=findprop@handle(this,varargin{:});
        end

        function lh=addlistener(this,varargin)
            lh=addlistener@handle(this,varargin{:});
        end

        function lh=listener(this,varargin)
            lh=listener@handle(this,varargin{:});
        end

        function notify(this,varargin)
            notify@handle(this,varargin{:});
        end

        function bool=eq(this,varargin)
            bool=eq@handle(this,varargin{:});
        end

        function bool=ge(this,varargin)
            bool=ge@hanlde(this,varargin{:});
        end

        function bool=gt(this,varargin)
            bool=gt@handle(this,varargin{:});
        end

        function bool=le(this,varargin)
            bool=le@handle(this,varargin{:});
        end

        function bool=lt(this,varargin)
            bool=lt@handle(this,varargin{:});
        end

        function bool=ne(this,varargin)
            bool=ne@handle(this,varargin{:});
        end

    end

    methods(Hidden,Access=protected)

        function object=Object(varargin)
            object@handle(varargin{:});
        end

    end

end