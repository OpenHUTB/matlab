function flag=checkObsoleteDelays(this)




    flag=true;
    summary=DAStudio.message('HDLShared:hdlmodelchecker:ObsoleteDelaysChecks_error');

    udeBlks=hdlcoder.ModelChecker.find_system_MAWrapper(this.m_DUT,...
    'MaskType','Unit Delay Enabled');
    udrBlks=hdlcoder.ModelChecker.find_system_MAWrapper(this.m_DUT,...
    'MaskType','Unit Delay Resettable');
    uderBlks=hdlcoder.ModelChecker.find_system_MAWrapper(this.m_DUT,...
    'MaskType','Unit Delay Enabled Resettable');

    for ii=1:numel(udeBlks)
        this.addCheck('warning',summary,udeBlks{ii},1,DAStudio.message('HDLShared:hdlmodelchecker:desc_ObsoleteUDEs'));
        flag=false;
    end
    for ii=1:numel(udrBlks)
        this.addCheck('warning',summary,udrBlks{ii},1,DAStudio.message('HDLShared:hdlmodelchecker:desc_ObsoleteUDRs'));
        flag=false;
    end
    for ii=1:numel(uderBlks)
        this.addCheck('warning',summary,uderBlks{ii},1,DAStudio.message('HDLShared:hdlmodelchecker:desc_ObsoleteUDERs'));
        flag=false;
    end
end