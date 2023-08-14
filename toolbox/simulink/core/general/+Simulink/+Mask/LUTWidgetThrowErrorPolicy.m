



classdef LUTWidgetThrowErrorPolicy<handle
    properties(Access=private)
        m_hasError=false;
    end

    methods
        function handleError(~,msgid,varargin)
            errmsg=message(msgid,varargin{:});
            throw(MException(errmsg));
        end

        function result=gotErrors(obj)
            result=obj.m_hasError;
        end
    end
end
