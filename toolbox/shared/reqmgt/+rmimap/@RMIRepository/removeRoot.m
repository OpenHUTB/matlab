function wasRemoved=removeRoot(this,rootName,force)








    wasRemoved=false;

    if nargin<3
        force=false;
    end

    [~,~,ext]=fileparts(rootName);
    isSimulink=isempty(ext);

    myRoot=rmimap.RMIRepository.getRoot(this.graph,rootName);

    if isempty(myRoot)
        if~isSimulink


            warning(message('Slvnv:rmigraph:UnmatchedModelName',rootName));
        end
        return;
    end

    isSimulink=strcmp(myRoot.getProperty('source'),'linktype_rmi_simulink');



    if~force
        dependentLinks=rmimap.RMIRepository.getDependentLinks(myRoot);
        if~isempty(dependentLinks)

            return;
        end
    end


    t=M3I.Transaction(this.graph);

    if isSimulink



        this.destroyChildRoots(myRoot);
    end

    try

        myRoot.destroy();
        wasRemoved=true;
    catch Mex
        warning('Slvnv:rmigraph:ErrorOnDestroy',Mex.message);
    end

    t.commit;


    rmimap.RMIRepository.getRoot([],'');

end


