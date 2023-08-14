classdef(Abstract=true)AbstractCommand<handle
    properties
MCodeComment
Name
    end

    methods
        function str=tomcode(hObj)
            str=sprintf('%s',hObj.Name);
        end

        function str=toString(hObj)
            str=getString(message('MATLAB:uistring:uiundo:CommandString',hObj.Name));
        end
    end
end

