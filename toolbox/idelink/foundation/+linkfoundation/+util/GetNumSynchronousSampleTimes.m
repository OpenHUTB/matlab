function numSynchronousSampleTimes=GetNumSynchronousSampleTimes(rtwSampleTimes)







    numSynchronousSampleTimes=0;

    for i=1:length(rtwSampleTimes)

        if(rtwSampleTimes{i}.PeriodAndOffset(1)~=-1)
            numSynchronousSampleTimes=numSynchronousSampleTimes+1;
        end

    end

