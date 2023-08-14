function rtn=applyUnit(inputNum,inputUnit)




    switch inputUnit
    case 'mil'
        rtn=inputNum*0.0000254;
    case 'inch'
        rtn=inputNum*0.0254;
    case 'um'
        rtn=inputNum*1e-6;
    case 'mm'
        rtn=inputNum*1e-3;
    case{'Hz','m'}
        rtn=inputNum;
    case 'kHz'
        rtn=inputNum*1e3;
    case 'MHz'
        rtn=inputNum*1e6;
    case 'GHz'
        rtn=inputNum*1e9;
    case 'THz'
        rtn=inputNum*1e12;
    end
end


