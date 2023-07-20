function h=pm_private(fcnName)









    narginchk(1,1);
    h=eval(['@',fcnName]);

end



