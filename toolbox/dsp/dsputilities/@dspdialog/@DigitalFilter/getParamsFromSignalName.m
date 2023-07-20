function[paramNames]=getParamsFromSignalName(this,SignalName)





    paramNames.skipThisSignal=0;
    paramNames.unknownParam=0;

    switch SignalName
    case 'Accumulator'
        paramNames.modeStr='accumMode';
        paramNames.wlStr='accumWordLength';
        paramNames.flStr='accumFracLength';

    case 'Product output'
        paramNames.modeStr='prodOutputMode';
        paramNames.wlStr='prodOutputWordLength';
        paramNames.flStr='prodOutputFracLength';

    case 'Output'
        paramNames.modeStr='outputMode';
        paramNames.wlStr='outputWordLength';
        paramNames.flStr='outputFracLength';

    case{'State','Input state','Output state'}
        paramNames.modeStr='memoryMode';
        paramNames.wlStr='memoryWordLength';
        paramNames.flStr='memoryFracLength';

    case 'Tap sum'
        paramNames.modeStr='tapSumMode';
        paramNames.wlStr='tapSumWordLength';
        paramNames.flStr='tapSumFracLength';

    case 'Multiplicand'
        paramNames.modeStr='multiplicandMode';
        paramNames.wlStr='multiplicandWordLength';
        paramNames.flStr='multiplicandFracLength';

    case 'Section input'
        paramNames.modeStr='stageIOMode';
        paramNames.wlStr='stageIOWordLength';
        paramNames.flStr='stageInFracLength';

    case 'Section output'
        paramNames.modeStr='stageIOMode';
        paramNames.wlStr='stageIOWordLength';
        paramNames.flStr='stageOutFracLength';

    otherwise
        paramNames.unknownParam=1;
    end


