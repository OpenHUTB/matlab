function ret=isInitialized(reg)







    ret=(~isempty(reg.pit_default))||(~isempty(reg.pit_custom));
