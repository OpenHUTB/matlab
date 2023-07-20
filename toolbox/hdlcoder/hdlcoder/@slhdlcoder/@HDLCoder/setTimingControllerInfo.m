function setTimingControllerInfo(this,clkDomain,tcinfo)




    m=get(this,'TimingControllerInfo');
    if isobject(m)
        m(clkDomain)=tcinfo;
    else
        this.TimingControllerInfo=containers.Map(clkDomain,tcinfo);
    end
