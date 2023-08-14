function launchTaskEditor(blkH,taskName)





    try
        thisExplr=DeploymentDiagram.explorer(bdroot(blkH));
        if~isempty(thisExplr)
            mapping=thisExplr.findNodes('Mapping');
            if~isempty(mapping)
                maps=thisExplr.findNodes('Maps');
                btm=findThisMap(maps,blkH,taskName);
                thisExplr.imme.selectTreeViewNode(mapping);
                thisExplr.imme.selectListViewNode(btm);
            end
        end
    catch E
        warning(E.identifier,E.message);
    end

    function btm=findThisMap(maps,blkH,taskName)


        for i=1:length(maps)
            if(maps(i).Block==blkH&&...
                strcmp(maps(i).Task.QualifiedName,taskName))
                btm=maps(i);
                break;
            end
        end
