function out=getAllSignalIDs(this,runID,qType,~)
    if isempty(runID)
        out=[];
    else
        if nargin<3
            qType='all';
        end
        Simulink.sdi.internal.flushStreamingBackend();
        out=this.sigRepository.getAllSignalIDs(int32(runID),qType);
    end
end