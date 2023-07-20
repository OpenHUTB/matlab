



function out=isMultipleSampleTimes(compiledSampleTime)
    out=false;
    if iscell(compiledSampleTime)



        nTs=0;
        for i=1:numel(compiledSampleTime)
            s=slci.internal.SampleTime(compiledSampleTime{i});
            if s.isDiscrete()
                nTs=nTs+1;
            end
        end

        if(nTs>1)
            out=true;
        end
    end
end