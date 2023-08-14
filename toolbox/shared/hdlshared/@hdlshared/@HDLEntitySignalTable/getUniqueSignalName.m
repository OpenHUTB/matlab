function uname=getUniqueSignalName(this,name)





    uname=name;
    nameList=this.getNames;

    uniq=1;
    uniq_limit=100000;

    while(any(strcmpi(uname,nameList))&&(uniq<uniq_limit))
        uname=sprintf('%s_%d',name,uniq);
        uniq=uniq+1;
    end

    if uniq==uniq_limit
        error(message('HDLShared:hdlshared:entitysignalerror',uname));
    end
