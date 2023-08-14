function trace(varargin)




    if doTrace

        fn=pm_private('pm_trace');
        fn('MECH:SMCC ',varargin{:});

    end

