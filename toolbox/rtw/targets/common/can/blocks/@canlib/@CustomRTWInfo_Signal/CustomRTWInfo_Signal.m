function h=CustomRTWInfo_Signal(varargin)














    try

        h=canlib.CustomRTWInfo_Signal;
        h.canlib_CustomRTWInfo_Signal_Constructor(varargin{:});
    catch err
        warning(err.message);
        rethrow(err);
    end
