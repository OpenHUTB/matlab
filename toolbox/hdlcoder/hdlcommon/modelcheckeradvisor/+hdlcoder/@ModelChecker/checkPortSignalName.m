function flag=checkPortSignalName(this)






    flag=true;

    [candidatePorts,candidateSignals]=hdlcoder.ModelChecker.getInvalidPortSignalNames(this.m_DUT);
    if~isempty(candidatePorts)
        flag=false;
    end

    summary=DAStudio.message('HDLShared:hdlmodelchecker:industry_std_portsignal_name_error');


    for ii=1:numel(candidatePorts)
        path=getfullname(candidatePorts(ii));
        this.addCheck('warning',summary,path,0);
    end


    for ii=1:numel(candidateSignals)
        sigH=candidateSignals(ii);
        blkH=get_param(sigH,'SrcBlockHandle');

        if ishandle(blkH)
            flag=false;
            path=getfullname(blkH);
            this.addCheck('warning',summary,path,0);
        end
    end
end
