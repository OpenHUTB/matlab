function pm_callwarning(id,msg)







    narginchk(2,2);

    msg=pm_unsprintf(msg);


    warnProp(1)=warning('query','backtrace');
    warnProp(2)=warning('query','verbose');


    warning off backtrace;


    cl=onCleanup(@()warning(warnProp));

    warning(id,msg);

end
