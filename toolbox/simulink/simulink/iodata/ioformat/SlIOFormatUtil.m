classdef(Hidden)SlIOFormatUtil<handle





    properties(Constant)

        SDI_REPO_CHANNEL_UPPER_LIMIT=30000;
    end


    methods(Static)

        function SampleDims=getTimeseriesDimension(ts)

            tssize=size(ts.Data);


            if ts.IsTimeFirst
                SampleDims=tssize(2:end);


            else

                SampleDims=tssize(1:end-1);

                if isscalar(ts.Time)&&isvector(ts.Data)||...
                    isscalar(ts.Time)&&(tssize(1)~=1&&tssize(end)~=1)


                    SampleDims=tssize;
                end
            end
        end
    end

end
