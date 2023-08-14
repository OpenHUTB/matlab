function val=getIOGroup(this,val)



    val=configset.ert.getter(this,val);
    if strcmp('Default',val)
        val=this.GroupRootIO;
    end
end
