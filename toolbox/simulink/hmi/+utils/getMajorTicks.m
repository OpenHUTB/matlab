

function majorTicks=getMajorTicks(minimumValue,tickInterval,maximumValue,scaleType)


    switch scaleType
    case{'Log'}
        majorTicks(1)=minimumValue;
        nextTick=minimumValue*tickInterval;
        while(nextTick<=maximumValue)
            majorTicks(end+1)=nextTick;%#ok
            if isequal(tickInterval,1)

                nextTick=majorTicks(end)+tickInterval;
            else

                nextTick=majorTicks(end)*tickInterval;
            end
        end

        if(majorTicks(end)~=maximumValue)
            majorTicks(end+1)=maximumValue;
        end
    case{'Linear'}

        numTicks=(maximumValue-minimumValue)/tickInterval;
        if numTicks>1000
            majorTicks=nan;
        else
            majorTicks=minimumValue:tickInterval:maximumValue;
            if~isequal(majorTicks(end),maximumValue)
                majorTicks=[majorTicks,maximumValue];
            end
        end
    end
end










