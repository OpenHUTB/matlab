

classdef InfoHandle<handle

    properties(Access=private)
        key(1,1)string
    end

    methods
        function obj=InfoHandle(key)
            if nargin<1
                key="";
            end
            obj.key=key;
        end
    end
end

