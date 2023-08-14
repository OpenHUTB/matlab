function[rtnNum,unit]=getNumUnit(inputNum)




    tenDigit=floor(log10(inputNum));
    if tenDigit<=3
        unit='Hz';
        rtnNum=inputNum;
    elseif tenDigit>3&&tenDigit<=6
        unit='kHz';
        rtnNum=inputNum/1e3;
    elseif tenDigit>6&&tenDigit<=9
        unit='MHz';
        rtnNum=inputNum/1e6;
    elseif tenDigit>9&&tenDigit<=12
        unit='GHz';
        rtnNum=inputNum/1e9;
    else
        unit='THz';
        rtnNum=inputNum/1e12;
    end
end


