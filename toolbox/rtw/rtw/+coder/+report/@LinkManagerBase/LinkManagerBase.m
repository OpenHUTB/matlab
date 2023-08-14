classdef LinkManagerBase<handle





    methods(Abstract)
        getLinkToFile(obj,fullFileName)
        getLinkToVar(obj,var)
        getLinkToFunction(obj,fcn)
        getLinkToType(obj,type)
        getLinkToFrontEnd(obj,id,txt)
    end
end


