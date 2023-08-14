function invokeCrtoolHighlighEntry(modelname,entryUID)

    hLib=[];

    try
        hLib=get_param(modelname,'TargetFcnLibHandle');
    catch
    end

    if~isempty(hLib)&&~isempty(entryUID)
        strparts=strsplit(entryUID,':');
        tblName=strparts{1};

        daRoot=DAStudio.Root;
        me=daRoot.find('-isa','TflDesigner.explorer');
        if isempty(me)
            crtool(hLib);
        else

        end
        aExplorer=TflDesigner.getexplorer;
        aRoot=aExplorer.getRoot;
        tables=aRoot.getChildren;
        for idx=1:length(tables)
            if strcmp(tables(idx).Name,tblName)
                aRoot.currenttreenode=tables(idx);
                aExplorer.imme.selectTreeViewNode(tables(idx));
                tableEntries=tables(idx).getChildren;
                for idy=1:length(tableEntries)
                    if strcmp(tableEntries(idy).object.UID,entryUID)
                        aExplorer.imme.selectListViewNode(tableEntries(idy));

                        break;
                    end
                end
                break;
            end
        end
    end
