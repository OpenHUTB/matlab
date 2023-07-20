classdef Edits<xmlcomp.internal.BaseEdits


    properties(Access=private)
LeftFile
RightFile
    end

    methods(Access=public)
        function obj=Edits(jDriverFacade)
            obj=obj@xmlcomp.internal.BaseEdits(...
            jDriverFacade,...
            @(jNode)xmlcomp.internal.edits.Node(jNode)...
            );
        end
    end

    methods(Static,Access=public)

        function edits=create(jDriverFacade)
            xmlcomp.internal.BaseEdits.checkArgument(jDriverFacade,'com.mathworks.comparisons.matlab.edits.EditsDriverFacade');
            baseEdits=xmlcomp.internal.edits.Edits(jDriverFacade);

            edits=xmlcomp.Edits(baseEdits);

        end

        function edits=createFromJava(jDriverFacade,variableName)
            narginchk(2,2);

            xmlcomp.internal.BaseEdits.checkArgument(jDriverFacade,'com.mathworks.comparisons.matlab.edits.EditsDriverFacade');

            baseEdits=xmlcomp.internal.edits.Edits(jDriverFacade);
            edits=xmlcomp.Edits(baseEdits);

            varName=matlab.lang.makeValidName(variableName);
            assignin('base',varName,edits);

        end

    end

end
