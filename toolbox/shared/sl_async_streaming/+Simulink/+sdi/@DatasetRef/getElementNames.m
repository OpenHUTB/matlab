function ret=getElementNames(this)





    ret=this.Repo.safeTransaction(@locGetElementNames,this);
end


function ret=locGetElementNames(this)
    sigIDs=getSortedSignalIDs(this);
    ret=cell(size(sigIDs));
    for idx=1:numel(sigIDs)
        sig=Simulink.sdi.Signal(this.Repo,sigIDs(idx));
        ret{idx}=sig.Name;
    end
end
