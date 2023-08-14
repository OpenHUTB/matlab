function h=CustomRTWInfo_Signal(varargin)














    try

        h=ECoderDemos.CustomRTWInfo_Signal;
        h.ECoderDemos_CustomRTWInfo_Signal_Constructor(varargin{:});
    catch err
        warning(err.message);
        rethrow(err);
    end
