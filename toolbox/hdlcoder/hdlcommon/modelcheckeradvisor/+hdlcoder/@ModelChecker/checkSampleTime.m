function flag=checkSampleTime(this)




    flag=true;
    summary=DAStudio.message('HDLShared:hdlmodelchecker:SampleTimeChecks_error');

    infCandidateBlks=hdlcoder.ModelChecker.getInfSampleTimeSrcs(this.m_DUT);
    contCandidateBlks=hdlcoder.ModelChecker.getContinuousSampleTimeSrcs(this.m_DUT);

    for ii=1:numel(infCandidateBlks)
        this.addCheck('warning',summary,infCandidateBlks{ii},1,DAStudio.message('HDLShared:hdlmodelchecker:desc_InfSampleTime'));
        flag=false;
    end
    for ii=1:numel(contCandidateBlks)
        this.addCheck('warning',summary,contCandidateBlks{ii},1,DAStudio.message('HDLShared:hdlmodelchecker:desc_ContSampleTime'));
        flag=false;
    end
end
