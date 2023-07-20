classdef OutputPackageException<MException








    properties(Access=private)
Stack
LineNumber
Arg
    end

    methods
        function obj=OutputPackageException(sourceException)
            obj@MException(sourceException.identifier,'%s',sourceException.message);

            obj.Stack=sourceException.stack(end,:);
            obj.message=sourceException.message;
            obj.type=sourceException.type;


            obj.LineNumber=obj.Stack(1).line;
            obj.Arg=obj.getArgs();
        end

        function args=getArgs(~)
            args={''};
        end
    end

    methods(Access=protected)
        function stack=getStack(obj)




            stack=obj.Stack;
        end
    end
end

