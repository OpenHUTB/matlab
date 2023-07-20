function returnedValue=getTest(h,~)




    try
        returnedValue=char(getAttribute(h.JavaHandle,'test'));
    catch ME
        warning(ME.message);
        returnedValue='';
    end
