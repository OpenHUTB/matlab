function path=getFullMdlRefPath(this)






    if~isempty(this.hMdlRefBlock)
        path=this.hMdlRefBlock.getFullMdlRefPath.convertToCell;
        path=[path;this.CachedFullName];
    else
        path={this.CachedFullName};
    end

    path=Simulink.SimulationData.BlockPath(path);

end
