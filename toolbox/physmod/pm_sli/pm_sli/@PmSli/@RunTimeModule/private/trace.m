function trace(varargin)




    if doTrace

        fn=pm_private('pm_trace');
        fn('SSC:RTM ',varargin{:});

    end


