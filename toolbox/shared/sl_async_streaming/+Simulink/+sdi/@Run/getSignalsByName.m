function signals=getSignalsByName(this,name)















    signals=Simulink.sdi.Signal.empty();

    ids=this.Repo.getSignalIDsByName(this.id,name);
    for idx=1:length(ids)
        signals(end+1)=Simulink.sdi.Signal(this.Repo,ids(idx));%#ok<AGROW>
    end
end
