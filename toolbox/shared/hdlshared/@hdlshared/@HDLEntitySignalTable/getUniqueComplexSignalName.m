function[urname,uiname]=getUniqueComplexSignalName(this,name)







    realpostfix=hdlgetparameter('complex_real_postfix');
    imagpostfix=hdlgetparameter('complex_imag_postfix');


    uname=name;
    nameList=this.getNames;

    uniq=1;
    uniq_limit=100000;
    names=getComplexNames(uname,realpostfix,imagpostfix);

    while(any(ismember(nameList,names))&&(uniq<uniq_limit))
        uname=sprintf('%s_%d',name,uniq);
        uniq=uniq+1;
        names=getComplexNames(uname,realpostfix,imagpostfix);
    end

    if uniq==uniq_limit
        error(message('HDLShared:hdlshared:entitysignalerror',uname));
    end

    urname=names{1};
    uiname=names{2};


    function names=getComplexNames(name,realpostfix,imagpostfix)

        names={[name,realpostfix],[name,imagpostfix]};
