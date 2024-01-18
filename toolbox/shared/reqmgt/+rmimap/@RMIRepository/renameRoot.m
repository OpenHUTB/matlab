function renameRoot(this,currentName,newName,varargin)

    if~ischar(newName)
        newName=get_param(newName,'Name');
    end

    if~strcmp(currentName,newName)
        myRoot=rmimap.RMIRepository.getRoot(this.graph,currentName);
        if isempty(myRoot)
            error(message('Slvnv:rmigraph:UnmatchedModelName',currentName));
        else
            t1=M3I.Transaction(this.graph);
            myRoot.url=newName;
            t1.commit;

            if~isempty(varargin)&&strcmp(varargin{1},'linktype_rmi_matlab')
                rmiml.RmiMlData.rename(currentName,newName);
            end

        end

        rmimap.RMIRepository.getRoot([],'');
    end
end


