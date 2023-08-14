function h=CustomRTWInfo_Parameter(varargin)














    try

        h=ECoderDemos.CustomRTWInfo_Parameter;
        h.ECoderDemos_CustomRTWInfo_Parameter_Constructor(varargin{:});
    catch err
        warning(err.message);
        rethrow(err);
    end
