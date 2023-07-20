function cache=setAndCacheParameter(this,param,value,cache)







    cache{end+1}=param;
    cache{end+1}=hdlgetparameter(param);


    hdlsetparameter(param,value);


