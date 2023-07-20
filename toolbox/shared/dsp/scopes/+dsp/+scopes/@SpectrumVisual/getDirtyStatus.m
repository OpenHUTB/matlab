function dirtyStatus=getDirtyStatus(this)





    dirtyStatus='on';
    hSource=this.Application.DataSource;
    if~isempty(hSource)&&strcmp(hSource.Type,'Simulink')
        dirtyStatus=get_param(bdroot(this.Application.DataSource.BlockHandle.handle),'Dirty');
    end
end
