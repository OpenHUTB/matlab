function[counterSize,prescalerSize]=getTimerRegisterSizes_C5x(timerOpt)




    timerReg=c5000_getMaxTimerBits(timerOpt);
    switch timerOpt
    case '16bit-timer',
        counterSize=timerReg.counter;
        prescalerSize=timerReg.prescaler;
    case '64bit-timer',
        counterSize=timerReg.counter_period;
        prescalerSize=0;
    case '32bit-timer-chained',
        counterSize=timerReg.counter_period;
        prescalerSize=timerReg.prescaler_period;
    case '32bit-timer-unchained',

        counterSize=timerReg.timer2_period;
        prescalerSize=0;
    otherwise
        error(message('TICCSEXT:util:UnsupportedTimerModeOption',timerOpt));
    end


