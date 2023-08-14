classdef WDECustomCommand<diagram.editor.Command





    properties(Constant)
        Success=diagram.editor.command.Result.Success;
        Fail=diagram.editor.command.Result.Fail;
    end

    methods
        function cmd=WDECustomCommand(data,syntax)
            cmd@diagram.editor.Command(data,syntax);
        end
    end

    methods(Access=protected)
        function response=execute(obj)


            response=diagram.editor.command.Response;
            response.result=obj.Success;
        end
    end
end
