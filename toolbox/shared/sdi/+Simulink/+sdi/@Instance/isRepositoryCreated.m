function ret=isRepositoryCreated()
    sdiEngine=Simulink.sdi.Instance.getSetEngine();
    ret=~isempty(sdiEngine)||sdi.Repository.hasBeenCreated();
end
