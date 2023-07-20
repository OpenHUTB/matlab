function h=CustomRTWInfo_Parameter(varargin)














    try

        h=AUTOSAR.CustomRTWInfo_Parameter;
        h.AUTOSAR_CustomRTWInfo_Parameter_Constructor(varargin{:});
    catch err
        warning(err.identifier,'%s',err.message);
        rethrow(err);
    end
