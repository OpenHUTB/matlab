function flag=checkSubsystemName(this)






    flag=true;

    candidateBlks=hdlcoder.ModelChecker.getInvalidSubsystemNames(this.m_DUT);
    if~isempty(candidateBlks)
        flag=false;
        summary=DAStudio.message('HDLShared:hdlmodelchecker:industry_std_subsystem_name_error');


        for ii=1:numel(candidateBlks)
            path=getfullname(candidateBlks(ii));
            this.addCheck('warning',summary,path,0);
        end
    end
end
