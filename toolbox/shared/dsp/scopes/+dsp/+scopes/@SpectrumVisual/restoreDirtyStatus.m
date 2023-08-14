function restoreDirtyStatus(this,dirtyFlag)




    hSource=this.Application.DataSource;
    if~isempty(hSource)&&strcmp(hSource.Type,'Simulink')
        model=bdroot(this.Application.DataSource.BlockHandle.handle);



        if strcmp(dirtyFlag,'off')&&strcmp(get_param(model,'Dirty'),'on')
            set_param(model,'Dirty','off');
        end
    end
end
