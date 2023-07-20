

classdef PLCExtModeException<MException
    properties
    end

    methods
        function obj=PLCExtModeException(msg,varargin)
            errorid='plccoder:extmode';
            obj@MException(errorid,msg,varargin{:});
        end

        function msg=getMessage(obj)
            msg=obj.message;
        end
    end
end


