function isReplicable=isReusableSS(this,slbh)



    if slbh==-1
        isReplicable=false;
    else
        if strcmp(hdlgetparameter('subsystemreuse'),'Atomic only')
            atomic_ss=strcmp(get_param(slbh,'TreatAsAtomicUnit'),'on');
            sf_ss=~strcmpi(get_param(slbh,'SFBlockType'),'NONE');
            isReplicable=atomic_ss||sf_ss;
        else
            isReplicable=false;
        end
    end
end
