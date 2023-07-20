function cba_buildinfopaste





    me=TflDesigner.getexplorer;
    if~isempty(me)&&~me.getRoot.iseditorbusy&&...
        strcmpi(me.getaction('EDIT_PASTEBUILDINFO').Enabled,'on')==1

        me.getRoot.iseditorbusy=true;
        curnode=me.getRoot.currenttreenode;

        if isempty(curnode)||~ishandle(curnode);
            return;
        end

        me.getaction('EDIT_PASTEBUILDINFO').Enabled='off';

        selectednodes=TflDesigner.getselectedlistnodes;
        if isa(curnode,'TflDesigner.root')&&isempty(selectednodes)
            selectednodes=me.imme.getVisibleListNodes;
            if isempty(selectednodes)
                return;
            end
            selectednodes=[selectednodes{:}]';
        end

        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:PasteInProgressStatusMsg'));
        if~isempty(selectednodes)
            contents=me.getRoot.buildinfouiclipboard.contents{1}.object;
            for idx=1:length(selectednodes)
                entry=selectednodes(idx).object;
                if~isa(class(entry),'RTW.TflCustomization')
                    entry.Implementation.HeaderFile=contents.Implementation.HeaderFile;
                    entry.Implementation.SourceFile=contents.Implementation.SourceFile;
                    entry.Implementation.HeaderPath=contents.Implementation.HeaderPath;
                    entry.Implementation.SourcePath=contents.Implementation.SourcePath;
                    entry.AdditionalHeaderFiles=contents.AdditionalHeaderFiles;
                    entry.AdditionalSourceFiles=contents.AdditionalSourceFiles;
                    entry.OtherFiles=contents.OtherFiles;
                    entry.AdditionalIncludePaths=contents.AdditionalIncludePaths;
                    entry.AdditionalSourcePaths=contents.AdditionalSourcePaths;
                    entry.AdditionalLinkObjs=contents.AdditionalLinkObjs;
                    entry.AdditionalLinkObjsPaths=contents.AdditionalLinkObjsPaths;
                    entry.AdditionalLinkFlags=contents.AdditionalLinkFlags;
                    entry.SearchPaths=contents.SearchPaths;
                    entry.GenCallback=contents.GenCallback;
                end
            end
        end

        selectednodes(1).firepropertychanged;
        TflDesigner.setcurrentlistnode(selectednodes(1));
        me.getRoot.iseditorbusy=false;
        me.getaction('EDIT_PASTEBUILDINFO').Enabled='on';
        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));
    end


