



classdef LUTWidgetWarningPolicy<handle
    properties(Access=private)
        m_hasError=false;
    end

    methods
        function handleError(obj,msgid,varargin)
            obj.m_hasError=true;
            errmsg=message(msgid,varargin{:});
            warning(errmsg);
        end
        function result=gotErrors(obj)
            result=obj.m_hasError;
        end
    end
end
