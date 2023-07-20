function flag=checkToplevelName(this)








    flag=true;


    [candidateDUT,candidatePorts]=hdlcoder.ModelChecker.getInvalidPortAndDutNames(this.m_DUT);
    if~isempty(candidateDUT)||~isempty(candidatePorts)
        flag=false;
    end
    summary=DAStudio.message('HDLShared:hdlmodelchecker:industry_std_toplevelname_error');


    if~isempty(candidateDUT)
        path=getfullname(candidateDUT);
        this.addCheck('warning',summary,path,0);
    end


    for ii=1:numel(candidatePorts)
        path=getfullname(candidatePorts(ii));
        this.addCheck('warning',summary,path,0);
    end
end
