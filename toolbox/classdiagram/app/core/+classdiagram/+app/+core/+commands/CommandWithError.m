classdef CommandWithError<diagram.editor.Command


    methods
        function cmd=CommandWithError(data,syntax)
            cmd@diagram.editor.Command(data,syntax);
        end
    end

    methods(Access=protected)
        function execute(obj)

            obj.noMethod;
        end
    end
end