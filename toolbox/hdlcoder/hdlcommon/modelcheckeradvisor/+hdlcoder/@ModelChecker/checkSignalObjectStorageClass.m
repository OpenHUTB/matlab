function flag=checkSignalObjectStorageClass(this)











    flag=true;
    summary=DAStudio.message('HDLShared:hdlmodelchecker:signal_storage_class_error');



    candidateSignals=hdlcoder.ModelChecker.getInvalidSignalObjectStorageClass(this.m_DUT);


    for ii=1:numel(candidateSignals)
        sigH=candidateSignals(ii);
        if ishandle(sigH)
            flag=false;
            path=get_param(sigH,'Parent');
            this.addCheck('warning',summary,path,0);
        end
    end
end
