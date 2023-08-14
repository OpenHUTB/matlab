function storedValue=setTest(h,proposedValue)




    try
        setAttribute(h.JavaHandle,'test',proposedValue);
    catch ME
        warning(ME.message);
    end

    storedValue='';
