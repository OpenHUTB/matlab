function clearComponent(libC)




    try
        delete(libC.ComponentInstance);
    catch ME
        rptgen.displayMessage(ME.message,2);
    end

    libC.ComponentInstance=[];

