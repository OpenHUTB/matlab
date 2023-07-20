function rtn=getNumWithUnit(inputNum,inputUnit)




    switch inputUnit
    case 'Hz'
        rtn=inputNum;
    case 'kHz'
        rtn=inputNum/1e3;
    case 'MHz'
        rtn=inputNum/1e6;
    case 'GHz'
        rtn=inputNum/1e9;
    case 'THz'
        rtn=inputNum/1e12;
    end
end


