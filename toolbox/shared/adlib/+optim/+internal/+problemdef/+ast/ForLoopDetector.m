classdef ForLoopDetector<optim.internal.problemdef.ast.DefaultVisitor





    properties

ContainsForLoop
    end

    methods

        function hasFL=getOutputs(interp)
            hasFL=interp.ContainsForLoop;
        end

    end


    methods



        function result=handleForLoop(interp,loopVariable,loopRange,loopBody)

            result=handleForLoop@optim.internal.problemdef.ast.DefaultVisitor(...
            interp,loopVariable,loopRange,loopBody);

            interp.ContainsForLoop=true;
        end


        function var=handleVariable(~,var)

        end

    end
end
