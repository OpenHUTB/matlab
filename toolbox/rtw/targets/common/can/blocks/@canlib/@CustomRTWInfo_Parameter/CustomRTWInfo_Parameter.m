function h=CustomRTWInfo_Parameter(varargin)














    try

        h=canlib.CustomRTWInfo_Parameter;
        h.canlib_CustomRTWInfo_Parameter_Constructor(varargin{:});
    catch err
        warning(err.message);
        rethrow(err);
    end
