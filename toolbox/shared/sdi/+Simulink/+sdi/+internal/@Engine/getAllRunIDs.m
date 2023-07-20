function out=getAllRunIDs(this,appStr)
    if nargin<2
        appStr='sdi';
    end
    Simulink.sdi.checkPendingRunDelete();
    out=this.sigRepository.getAllRunIDs(appStr);
end
