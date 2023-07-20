classdef DefineMapFactory





    methods(Static)
        function defineMap=fromBuildInfo(buildInfo)
            [~,defineNames,defineValues]=buildInfo.getDefines;


            defineValues=cellfun(@strtrim,defineValues,'UniformOutput',false);
            defineValues=cellfun(@(x)regexprep(x,'''',''),defineValues,'UniformOutput',false);
            defineValues=cellfun(@(x)regexprep(x,'"',''),defineValues,'UniformOutput',false);


            defineMap=containers.Map(defineNames,defineValues);
        end
    end
end