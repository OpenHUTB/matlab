function uniquename=hdluniqueentityname(nodename)






    nodename=hdllegalname(nodename);
    uniq=1;
    uniq_limit=100000;
    uname=nodename;
    while(hdlentitynameexists(uname)==1)&&(uniq<uniq_limit)
        uname=sprintf('%s%s%d',nodename,hdlgetparameter('entity_conflict_postfix'),uniq);
        uniq=uniq+1;
    end
    if uniq==uniq_limit
        error(message('HDLShared:directemit:entitynameerror',nodename));
    end
    uniquename=hdllegalnamersvd(uname);



