classdef SubcomparisonFormatter<handle



    methods(Abstract,Access=public)
        bool=canHandle(obj,subcomparison)
        formattedSubcomparison=getFormattedSubcomparison(obj,subcomparison,side)
    end

end