function flag=isSpecifiedTypeMode(mode)






    flag=isa(mode,'embedded.numerictype')||strncmp(mode,'Custom',6);
