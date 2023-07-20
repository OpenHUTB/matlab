function[result,badIdx]=safeGet(h,propName,varargin)

















    [result,badIdx]=mlreportgen.utils.safeGet(h,propName,varargin{:});
    warning(message("slreportgen:report:warning:functionDeprecationWarning","slreportgen.utils.safeGet","22a","mlreportgen.utils.safeGet"));


