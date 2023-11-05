function[timerIntPeriod,timerIntPrescaler,timerIntPostscaler,timerIntPeriodLast]=checkTimerValues_C5x(timerIntPeriod,timerIntPrescaler,timerIntPostscaler,timerOpt,numCycles,buildAction)

    [counterSize,prescalerSize]=ticcsext.Utilities.getTimerRegisterSizes_C5x(timerOpt);


    timerIntPeriodLast=(2^counterSize)-1;
    if(numCycles>((2^counterSize)*(2^prescalerSize)))
        timerIntPostscaler=(floor(numCycles/((2^counterSize)*(2^prescalerSize))));
        if(timerIntPostscaler>((2^12)-1))


            if nargin>4&&strcmpi(buildAction,'Archive_library')

            else


                timerIntPeriod=[];
                timerIntPrescaler=[];
                return;
            end
        elseif(timerIntPostscaler==(numCycles/((2^counterSize)*(2^prescalerSize))))
            timerIntPostscaler=timerIntPostscaler-1;
        else
            timerIntPeriodLast=floor((numCycles/(2^prescalerSize))-(timerIntPostscaler*(2^counterSize)));
            if(timerIntPeriodLast>=1000)
                timerIntPeriodLast=timerIntPeriodLast-700;
            else
                timerIntPeriodLast=(2^counterSize)-1;
                timerIntPostscaler=timerIntPostscaler-1;
            end
        end
        timerIntPeriod=(2^counterSize)-1;
        timerIntPrescaler=(2^prescalerSize)-1;
        return;
    end

    while(timerIntPeriod>(2^counterSize))


        temp_timerIntPrescaler=timerIntPrescaler+1;
        if(temp_timerIntPrescaler>(2^prescalerSize))


            if nargin>4&&strcmpi(buildAction,'Archive_library')

            else


                timerIntPeriod=[];
                timerIntPrescaler=[];
                return
            end
        end

        temp_timerIntPeriod=linkfoundation.util.GetTimerPeriod(numCycles,temp_timerIntPrescaler);

        timerIntPeriod=temp_timerIntPeriod;
        timerIntPrescaler=temp_timerIntPrescaler;
    end


    [timerIntPeriod,timerIntPrescaler]=DecrementTimerCounterAndPrescaler(timerIntPeriod,timerIntPrescaler);



    function[timerIntPeriod,timerIntPrescaler]=DecrementTimerCounterAndPrescaler(timerIntPeriod,timerIntPrescaler)
        timerIntPeriod=timerIntPeriod-1;
        timerIntPrescaler=timerIntPrescaler-1;


