function licStatus=focshared(block)



    licType=focsharedtest(block);
    [licStatus,errMsg]=focsharedeval(licType);


    if licStatus==0
        error(errMsg);
    end

end