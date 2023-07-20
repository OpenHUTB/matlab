function boolOut=canCastData(dataIn,enumClassName)




    try
        slwebwidgets.doSLCast(dataIn,enumClassName);
        boolOut=true;
    catch

        boolOut=false;
    end
