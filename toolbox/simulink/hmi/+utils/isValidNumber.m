

function[success,errormsg]=isValidNumber(num,param)
    success=true;
    errormsg='';
    if utils.isValidFloatField(num)
        success=false;
        errormsg=DAStudio.message('SimulinkHMI:dialogs:NonNumericParameter',param);
        return;
    end

    if num<(-realmax)
        success=false;
        errormsg=DAStudio.message('SimulinkHMI:dialogs:ValueLessThanNegativeRealMax',param);
        return;
    end

    if num>realmax
        success=false;
        errormsg=DAStudio.message('SimulinkHMI:dialogs:ValueGreaterThanRealMax',param);
        return;
    end

end