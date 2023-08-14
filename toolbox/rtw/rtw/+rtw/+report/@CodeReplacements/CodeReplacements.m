classdef CodeReplacements<coder.report.CodeReplacementsBase





    properties
        ModelName='';
        SourceSubsystem='';
    end

    methods
        function obj=CodeReplacements(modelName,sourceSubsys,aTfl)
            obj=obj@coder.report.CodeReplacementsBase(aTfl);
            obj.ModelName=modelName;
            obj.SourceSubsystem=sourceSubsys;
        end
    end

    methods(Access=protected)
        htmlStr=getSourcelocationFromSID(obj,sid)
    end
end


