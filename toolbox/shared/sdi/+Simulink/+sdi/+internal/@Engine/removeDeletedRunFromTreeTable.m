function removeDeletedRunFromTreeTable(this,runID,varargin)
    if isempty(varargin)


        runApp=this.sigRepository.getRunApp(int32(runID));
    else

        runApp=varargin{1};
    end
    notify(this,'runDeleteEvent',Simulink.sdi.internal.SDIEvent(...
    'runDeleteEvent',runID,runApp));
end