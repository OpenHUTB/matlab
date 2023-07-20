function fireRunMetaDataUpdatedEvent(this,mdl,varargin)




    notify(this.Engine_,'runMetaDataUpdated',Simulink.sdi.internal.SDIEvent('runMetaDataUpdated',mdl));

    if nargin>2
        runID=varargin{1};
        if this.Engine_.isValidRunID(runID)
            status=varargin{2};
            notify(this.Engine_,'treeRunPropertyEvent',...
            Simulink.sdi.internal.SDIEvent('treeRunPropertyEvent',runID,status,'runStatus'));
        end
    end
end