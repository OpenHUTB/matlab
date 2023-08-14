classdef(Hidden=true)Promise<handle


    properties(SetAccess=private)
State
Value
Future
    end

    methods


        function obj=Promise(varargin)
            if nargin==1
                obj.State=connector.internal.PromiseState.Resolved;
                obj.Value=varargin{1};
            elseif nargin==2
                obj.State=connector.internal.PromiseState.Failed;
                obj.Value=varargin{1};
            else
                obj.State=connector.internal.PromiseState.Unresolved;
            end
        end

        function future=getFuture(obj)
            if~isempty(obj.Future)
                ex=MException('Connector:Framework:SingleFuture',...
                'Promise can have only one future');
                throw(ex);
            end

            obj.Future=connector.internal.Future(obj);
            future=obj.Future;
        end

        function setValue(obj,value)
            if obj.State==connector.internal.PromiseState.Unresolved
                obj.State=connector.internal.PromiseState.Resolved;
                obj.Value=value;
                obj.notifyFuture();
            else
                ex=MException('Connector:Framework:PromiseResolved','The promise is already resolved.');
                throw(ex);
            end
        end

        function setException(obj,value)
            if obj.State==connector.internal.PromiseState.Unresolved
                obj.State=connector.internal.PromiseState.Failed;
                obj.Value=value;
                obj.notifyFuture();
            else
                ex=MException('Connector:Framework:PromiseResolved','The promise is already resolved.');
                throw(ex);
            end
        end
    end

    methods(Access=protected)
        function notifyFuture(obj)
            if~isempty(obj.Future)
                obj.Future.notifyFuture();
            end
        end
    end


    methods(Access={?connector.internal.Future})
        function notifyGet(obj)

        end
    end
end
