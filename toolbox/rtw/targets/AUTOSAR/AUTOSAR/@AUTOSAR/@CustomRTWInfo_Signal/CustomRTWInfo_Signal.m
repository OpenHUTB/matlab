function h=CustomRTWInfo_Signal(varargin)














    try

        h=AUTOSAR.CustomRTWInfo_Signal;
        h.AUTOSAR_CustomRTWInfo_Signal_Constructor(varargin{:});
    catch err
        warning(err.identifier,'%s',err.message);
        rethrow(err);
    end
