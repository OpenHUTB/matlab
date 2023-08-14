function root=ensureRoot(this,name)






    root=rmimap.RMIRepository.getRoot(this.graph,name);
    if isempty(root)
        switch exist(name,'file')
        case 2
            fPath=rmiut.absolute_path(name);
        case 4
            load_system(name);
            fPath=get_param(name,'FileName');
        otherwise
            error('RMIRepository:ensureRoot() failed for "%s"',name);
        end
        root=this.loadIfExists(fPath);
    end
    if isempty(root)

        try
            modelH=get_param(name,'Handle');
            root=this.addModel(modelH);


            rmidata.RmiSlData.getInstance.register(modelH);
        catch
            error('RMIRepository:ensureRoot() failed for "%s"',name);
        end
    end
end


