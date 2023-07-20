function[doThisOne]=instrumentThisParam(this,SignalName,ParamName)





    doThisOne=false;

    switch SignalName
    case 'Accumulator'
        if any(strcmp(ParamName,{'accumMode','accumWordLength'}))
            doThisOne=true;
        end
    case 'Product output'
        if any(strcmp(ParamName,{'prodOutputMode','prodOutputWordLength'}))
            doThisOne=true;
        end
    case 'Output'
        if any(strcmp(ParamName,{'outputMode','outputWordLength'}))
            doThisOne=true;
        end
    case{'State','Input state','Output state'}
        if any(strcmp(ParamName,{'memoryMode','memoryWordLength'}))
            doThisOne=true;
        end
    case 'Tap sum'
        if any(strcmp(ParamName,{'tapSumMode','tapSumWordLength'}))
            doThisOne=true;
        end
    case 'Multiplicand'
        if any(strcmp(ParamName,{'multiplicandMode','multiplicandWordLength'}))
            doThisOne=true;
        end
    case{'Section input','Section output'}
        if any(strcmp(ParamName,{'stageIOMode','stageIOWordLength'}))
            doThisOne=true;
        end
    end


