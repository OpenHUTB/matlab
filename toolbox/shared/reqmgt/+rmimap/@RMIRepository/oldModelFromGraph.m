function oldModel=oldModelFromGraph(oldGraph)





    for r=1:oldGraph.roots.size
        root=oldGraph.roots.at(r);
        rootSrcType=root.getProperty('source');
        if any(strcmp(rootSrcType,{'Simulink','linktype_rmi_simulink'}))
            oldModel=root;
            break;
        end
    end

    for i=1:oldModel.links.size
        link=oldModel.links.at(i);

        destUrl=link.getProperty('dependeeUrl');
        source=rmimap.RMIRepository.getRoot(oldGraph,destUrl);

        destType=source.getProperty('source');
        link.setProperty('source',destType);


        if strcmp(destType,'linktype_rmi_simulink')&&strcmp(destUrl,'$ModelName$')
            link.setProperty('dependeeUrl',root.url);
            description=link.getProperty('description');
            if description(1)=='/'
                link.setProperty('description',[root.url,description]);
            end
        end
    end
end


