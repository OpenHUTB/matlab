function fireRunMetaDataUpdatedEvent(mdl,varargin)




    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    fw.fireRunMetaDataUpdatedEvent(mdl,varargin{:});
end
