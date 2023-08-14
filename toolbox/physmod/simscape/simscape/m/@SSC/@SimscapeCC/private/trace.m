function trace(varargin)




    if doTrace

        fn=ssc_private('ssc_trace');
        fn('SSC:PCC ',varargin{:});

    end

