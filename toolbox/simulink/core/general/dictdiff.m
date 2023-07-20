function htmlOut=dictdiff(source1,source2,reportID,mergingEnabled,showOnlyChanges,extraNameSort)




    if nargin<4
        mergingEnabled='false';
    end
    if nargin<5
        showOnlyChanges=true;
    end
    if nargin<6
        extraNameSort=true;
    end


    if~ischar(source1)
        s1=source1.toString;
    else
        s1=source1;
    end

    if~ischar(source2)
        s2=source2.toString;
    else
        s2=source2;
    end

    if isequal(s1,s2)
        htmlOut=diffShowChanges(source1,reportID,mergingEnabled,showOnlyChanges,extraNameSort);
    else
        htmlOut=diffTwoDictionaries(source1,source2,reportID,mergingEnabled,showOnlyChanges,extraNameSort);
    end

end

function htmlOut=diffTwoDictionaries(source1,source2,reportID,mergingEnabled,showOnlyChanges,extraNameSort)

    [source1,fullname1,shortname1,readable1]=i_resolve(source1);
    [source2,fullname2,shortname2,readable2]=i_resolve(source2);

    colors=i_defineColors();




    if strcmp(shortname1,shortname2)
        [pt1,n,e]=fileparts(readable1);
        shortname1=[n,e];
        [pt2,n,e]=fileparts(readable2);
        shortname2=[n,e];
        while strcmp(shortname1,shortname2)
            [pt1,dn1]=fileparts(pt1);
            [pt2,dn2]=fileparts(pt2);
            if isempty(dn1)&&isempty(dn2)


                break;
            end


            shortname1=fullfile(dn1,shortname1);
            shortname2=fullfile(dn2,shortname2);
        end
    end

    import matlab.io.xml.dom.*
    doc=Document('DictFileEditScript');

    root=doc.getDocumentElement;
    root.setAttribute('id',reportID);
    root.setAttribute('mergingEnabled',mergingEnabled);

    root.setAttribute('clickToSort',...
    getString(message('SLDD:sldd:DictDiffClickToSort')));
    root.setAttribute('LeftFileMsg',...
    getString(message('SLDD:sldd:DictDiffLeftFile')));
    root.setAttribute('RightFileMsg',...
    getString(message('SLDD:sldd:DictDiffRightFile')));


    root.setAttribute('ActionMsg',...
    getString(message('SLDD:sldd:DictDiffAction')));
    root.setAttribute('VarNameMsg',...
    getString(message('SLDD:sldd:DictDiffVarName')));
    root.setAttribute('ClassMsg',...
    getString(message('SLDD:sldd:DictDiffClass')));
    root.setAttribute('SizeMsg',...
    getString(message('SLDD:sldd:DictDiffSize')));
    root.setAttribute('StatusMsg',...
    getString(message('SLDD:sldd:DictDiffStatus')));
    root.setAttribute('ScopeMsg',...
    getString(message('SLDD:sldd:DictDiffScope')));
    root.setAttribute('RefNameMsg',...
    getString(message('SLDD:sldd:DictDiffRefName')));


    root.setAttribute('ContainerDifferenceOnlyMsg',...
    getString(message('SLDD:sldd:DictDiffContainerDifferenceOnly')));
    root.setAttribute('compareVarsMessage',...
    getString(message('SLDD:sldd:DictDiffCompareVars')));
    root.setAttribute('classesDifferText',...
    [getString(message('SLDD:sldd:DictDiffClassesDiffer')),' ']);
    root.setAttribute('ChangedColor',colors.modifiedvarcolor);
    root.setAttribute('BackgroundColor',colors.backgroundcolor);


    root.setAttribute('deleteLeftLinkTitle',...
    getString(message('SLDD:sldd:DictDiffDeleteLeft')));
    root.setAttribute('mergeLeftLinkTitle',...
    getString(message('SLDD:sldd:DictDiffMergeLeft')));
    root.setAttribute('deleteRightLinkTitle',...
    getString(message('SLDD:sldd:DictDiffDeleteRight')));
    root.setAttribute('mergeRightLinkTitle',...
    getString(message('SLDD:sldd:DictDiffMergeRight')));
    root.setAttribute('NoMergeLeftLinkTitle',...
    getString(message('SLDD:sldd:DictDiffNoMergeLeft')));
    root.setAttribute('NoMergeRightLinkTitle',...
    getString(message('SLDD:sldd:DictDiffNoMergeRight')));

    title=sprintf('Dictionary File Comparison - %s vs. %s',shortname1,shortname2);
    i_xmltextnode(doc,root,'Title',title);


    node=i_xmltextnode(doc,root,'LeftLocation',fullname1);
    node.setAttribute('Readable',readable1);
    node.setAttribute('ReadableNeutral',strrep(readable1,'\','/'));
    node.setAttribute('ShortName',shortname1);
    node.setAttribute('ColumnHeader',...
    getString(message('SLDD:sldd:DictDiffVariablesIn',...
    shortname1)));
    node.setAttribute('leftLoadFileLinkMessage',...
    getString(message('SLDD:sldd:DictDiffLoad',fullname1)));
    node.setAttribute('RefAttachedColumnHeader',...
    getString(message('SLDD:sldd:DictDiffRefAttached',shortname1)));


    node=i_xmltextnode(doc,root,'RightLocation',fullname2);
    node.setAttribute('Readable',readable2);
    node.setAttribute('ReadableNeutral',strrep(readable2,'\','/'));
    node.setAttribute('ShortName',shortname2);
    node.setAttribute('ColumnHeader',...
    getString(message('SLDD:sldd:DictDiffVariablesIn',...
    shortname2)));
    node.setAttribute('rightLoadFileLinkMessage',...
    getString(message('SLDD:sldd:DictDiffLoad',fullname2)));
    node.setAttribute('RefAttachedColumnHeader',...
    getString(message('SLDD:sldd:DictDiffRefAttached',shortname2)));

    dsa1=Simulink.dd.DataSourceAccessor(readable1,'-sorted');
    dsa2=Simulink.dd.DataSourceAccessor(readable2,'-sorted');

    found_diffVar=i_doDSEntryCompare(doc,root,dsa1,dsa2,showOnlyChanges,extraNameSort,colors);
    found_diffRef=i_doDSRefCompare(doc,root,dsa1,dsa2,showOnlyChanges,colors);

    found_diff=(found_diffVar||found_diffRef);


    if~found_diff

        root.setAttribute('difftype','identical');
    else
        root.setAttribute('difftype','contents');
    end



    stylesDir=fullfile(toolboxdir('shared'),'sldd','web','styles');
    stylesheet=fullfile(stylesDir,'dictdiff.xsl');

    import matlab.io.xml.transform.*


    tempXMLFile=[tempname,'.xml'];
    doc.xmlwrite(tempXMLFile)
    outStr=ResultString();
    transform(Transformer,tempXMLFile,stylesheet,outStr);
    htmlOut=char(outStr.String);
    try %#ok<TRYNC>
        delete(tempXMLFile);
    end

end

function htmlOut=diffShowChanges(source1,reportID,mergingEnabled,showOnlyChanges,extraNameSort)
    [source1,fullname1,shortname1,readable1]=i_resolve(source1);

    colors=i_defineColors();

    import matlab.io.xml.dom.*
    doc=Document('DictShowChangesScript');

    root=doc.getDocumentElement;
    root.setAttribute('id',reportID);
    root.setAttribute('mergingEnabled',mergingEnabled);

    root.setAttribute('clickToSort',...
    getString(message('SLDD:sldd:ShowChangesClickToSort')));


    root.setAttribute('ActionMsg',...
    getString(message('SLDD:sldd:ShowChangesAction')));
    root.setAttribute('VarNameMsg',...
    getString(message('SLDD:sldd:ShowChangesVarName')));
    root.setAttribute('ClassMsg',...
    getString(message('SLDD:sldd:ShowChangesClass')));
    root.setAttribute('StatusMsg',...
    getString(message('SLDD:sldd:ShowChangesStatus')));
    root.setAttribute('ScopeMsg',...
    getString(message('SLDD:sldd:ShowChangesScope')));
    root.setAttribute('RefNameMsg',...
    getString(message('SLDD:sldd:ShowChangesRefName')));
    root.setAttribute('VariablesInOrigMsg',...
    getString(message('SLDD:sldd:ShowChangesVariablesInOrig')));
    root.setAttribute('UnsavedChangesMsg',...
    getString(message('SLDD:sldd:ShowChangesUnsavedChanges')));
    root.setAttribute('DataSourceMsg',...
    getString(message('SLDD:sldd:ShowChangesDataSource')));
    root.setAttribute('LastModMsg',...
    getString(message('SLDD:sldd:ShowChangesLastMod')));
    root.setAttribute('OriginalRefMsg',...
    getString(message('SLDD:sldd:ShowChangesOriginalRef')));


    root.setAttribute('ContainerDifferenceOnlyMsg',...
    getString(message('SLDD:sldd:ShowChangesContainerDifferenceOnly')));
    root.setAttribute('compareVarsMessage',...
    getString(message('SLDD:sldd:ShowChangesCompareVars')));
    root.setAttribute('DeleteMsg',...
    getString(message('SLDD:sldd:ShowChangesDelete')));
    root.setAttribute('DeleteVarMsg',...
    getString(message('SLDD:sldd:ShowChangesDeleteVar')));
    root.setAttribute('RevertMsg',...
    getString(message('SLDD:sldd:ShowChangesRevert')));
    root.setAttribute('RevertVarMsg',...
    getString(message('SLDD:sldd:ShowChangesRevertVar')));
    root.setAttribute('RecoverMsg',...
    getString(message('SLDD:sldd:ShowChangesRecover')));
    root.setAttribute('RecoverVarMsg',...
    getString(message('SLDD:sldd:ShowChangesRecoverVar')));
    root.setAttribute('RemoveRefMsg',...
    getString(message('SLDD:sldd:ShowChangesRemoveRef')));
    root.setAttribute('DeleteRefTxtMsg',...
    getString(message('SLDD:sldd:ShowChangesDeleteRefTxt')));
    root.setAttribute('RecoverRefMsg',...
    getString(message('SLDD:sldd:ShowChangesRecoverRef')));
    root.setAttribute('RecoverRefTxtMsg',...
    getString(message('SLDD:sldd:ShowChangesRecoverRefTxt')));
    root.setAttribute('CompareMessage',...
    getString(message('SLDD:sldd:ShowChangesCompare')));
    root.setAttribute('compareVarsMessage',...
    getString(message('SLDD:sldd:ShowChangesCompareVars')));
    root.setAttribute('SameNameText',...
    getString(message('SLDD:sldd:ShowChangesSameName')));
    root.setAttribute('classesDifferText',...
    [getString(message('SLDD:sldd:ShowChangesClassesDiffer')),' ']);
    root.setAttribute('ChangedColor',colors.modifiedvarcolor);
    root.setAttribute('BackgroundColor',colors.backgroundcolor);

    title=DAStudio.message('SLDD:sldd:ShowChangesTitle',shortname1);
    i_xmltextnode(doc,root,'Title',title);


    node=i_xmltextnode(doc,root,'LeftLocation',fullname1);
    node.setAttribute('Readable',readable1);
    node.setAttribute('ReadableNeutral',strrep(readable1,'\','/'));
    node.setAttribute('ShortName',shortname1);
    node.setAttribute('leftLoadFileLinkMessage',...
    getString(message('SLDD:sldd:ShowChangesLoad',fullname1)));
    node.setAttribute('RefAttachedColumnHeader',...
    getString(message('SLDD:sldd:ShowChangesRefAttached',shortname1)));


    node=i_xmltextnode(doc,root,'RightLocation',[fullname1,'_unsaved']);
    node.setAttribute('Readable',readable1);
    node.setAttribute('ShortName',shortname1);
    node.setAttribute('ReadableNeutral',strrep(readable1,'\','/'));
    node.setAttribute('RefAttachedColumnHeader',...
    getString(message('SLDD:sldd:ShowChangesRefAttached',shortname1)));

    ddConn=Simulink.dd.open(readable1);

    found_diffVar=i_doShowChangesCompare(doc,root,ddConn,showOnlyChanges,extraNameSort,colors);
    found_diffRef=i_doDictRefChanges(doc,root,ddConn,showOnlyChanges,colors);

    found_diff=(found_diffVar||found_diffRef);

    if~found_diff

        root.setAttribute('difftype','identical');
    else
        root.setAttribute('difftype','contents');
    end



    stylesDir=fullfile(toolboxdir('shared'),'sldd','web','styles');
    stylesheet=fullfile(stylesDir,'showchanges.xsl');


    import matlab.io.xml.transform.*


    tempXMLFile=[tempname,'.xml'];
    doc.xmlwrite(tempXMLFile)
    outStr=ResultString();
    transform(Transformer,tempXMLFile,stylesheet,outStr);
    htmlOut=char(outStr.String);
    try %#ok<TRYNC>
        delete(tempXMLFile);
    end
end





function found_diff=i_doDSEntryCompare(doc,root,dsa1,dsa2,showOnlyChanges,extraNameSort,colors)

    report=containers.Map;

    found_diff=false;
    e1=dsa1.entries;
    e2=dsa2.entries;
    e1.first;
    e2.first;
    while e1.HasCurrent&&e2.HasCurrent
        clear entrynode;
        if e1.CurrentKey==e2.CurrentKey

            entry1=e1.Current;
            entry2=e2.Current;
            displayName1=entry1.Name;
            var1=entry1.Value;
            displayName2=entry2.Name;
            var2=entry2.Value;
            if isequal(entry1.LastModified,entry2.LastModified)
                match_type='yes';
            else
                match_type=comparisons.internal.variablesEqual(var1,var2);
            end
            if~strcmp(match_type,'yes')
                found_diff=true;
            elseif~isequal(displayName1,displayName2)
                found_diff=true;
                match_type='no';
            end


            if(~strcmp(match_type,'yes')||~showOnlyChanges)
                scope=i_getScopeName(dsa1,entry1.ParentUUID);
                entrynode.leftname=displayName1;
                entrynode.leftscope=scope;
                entryKey=[entrynode.leftname,'_',scope];
                entrynode.leftsize=i_getsize(var1);
                entrynode.leftclass=comparisons.internal.variableClass(var1);
                entrynode.leftentrykey=e1.CurrentKey.toString;
                entrynode.rightname=displayName2;
                scope=i_getScopeName(dsa2,entry2.ParentUUID);
                entrynode.rightscope=scope;
                entrynode.rightsize=i_getsize(var2);
                entrynode.rightclass=comparisons.internal.variableClass(var2);
                entrynode.rightentrykey=e2.CurrentKey.toString;
                entrynode.contentsMatch=match_type;


                report([entryKey,' B'])=entrynode;
            end
            e1.next;
            e2.next;
        elseif e1.CurrentKey<e2.CurrentKey

            entry=e1.Current;
            scope=i_getScopeName(dsa1,entry.ParentUUID);
            entryKey=[entry.Name,'_',scope];

            keyNote=' L';
            if report.isKey([entryKey,' R'])
                if extraNameSort
                    entrynode=report([entryKey,' R']);
                    keyNote=' B';
                    report.remove([entryKey,' R']);
                    entrynode.contentsMatch='no';
                else
                    entrynode=report([entryKey,' R']);
                    entrynode.hasDuplicateName=true;
                    report([entryKey,' R'])=entrynode;
                    clear entrynode;
                    entrynode.hasDuplicateName=true;
                end
            end

            displayName=entry.Name;
            entrynode.leftname=displayName;
            entrynode.leftscope=scope;
            var=entry.Value;
            entrynode.leftsize=i_getsize(var);
            entrynode.leftclass=comparisons.internal.variableClass(var);
            entrynode.leftentrykey=e1.CurrentKey.toString;
            report([entryKey,keyNote])=entrynode;
            found_diff=true;
            e1.next;
        else

            entry=e2.Current;
            scope=i_getScopeName(dsa2,entry.ParentUUID);
            entryKey=[entry.Name,'_',scope];

            keyNote=' R';
            if report.isKey([entryKey,' L'])
                if extraNameSort
                    entrynode=report([entryKey,' L']);
                    keyNote=' B';
                    report.remove([entryKey,' L']);
                    entrynode.contentsMatch='no';
                else
                    entrynode=report([entryKey,' L']);
                    entrynode.hasDuplicateName=true;
                    report([entryKey,' L'])=entrynode;
                    clear entrynode;
                    entrynode.hasDuplicateName=true;
                end
            end

            displayName=entry.Name;
            entrynode.rightname=displayName;
            entrynode.rightscope=scope;
            var=entry.Value;
            entrynode.rightsize=i_getsize(var);
            entrynode.rightclass=comparisons.internal.variableClass(var);
            entrynode.rightentrykey=e2.CurrentKey.toString;
            found_diff=true;
            report([entryKey,keyNote])=entrynode;
            e2.next;
        end
    end
    while e1.HasCurrent

        entry=e1.Current;
        scope=i_getScopeName(dsa1,entry.ParentUUID);
        entryKey=[entry.Name,'_',scope];

        clear entrynode;
        keyNote=' L';
        if report.isKey([entryKey,' R'])
            if extraNameSort
                entrynode=report([entryKey,' R']);
                keyNote=' B';
                report.remove([entryKey,' R']);
                entrynode.contentsMatch='no';
            else
                entrynode=report([entryKey,' R']);
                entrynode.hasDuplicateName=true;
                report([entryKey,' R'])=entrynode;
                clear entrynode;
                entrynode.hasDuplicateName=true;
            end
        end

        displayName=entry.Name;
        entrynode.leftname=displayName;
        entrynode.leftscope=scope;
        var=entry.Value;
        entrynode.leftsize=i_getsize(var);
        entrynode.leftclass=comparisons.internal.variableClass(var);
        entrynode.leftentrykey=e1.CurrentKey.toString;
        report([entryKey,keyNote])=entrynode;
        found_diff=true;
        e1.next;
    end
    while e2.HasCurrent

        entry=e2.Current;
        scope=i_getScopeName(dsa2,entry.ParentUUID);
        entryKey=[entry.Name,'_',scope];

        clear entrynode;
        keyNote=' R';
        if report.isKey([entryKey,' L'])
            if extraNameSort
                entrynode=report([entryKey,' L']);
                keyNote=' B';
                report.remove([entryKey,' L']);
                entrynode.contentsMatch='no';
            else
                entrynode=report([entryKey,' L']);
                entrynode.hasDuplicateName=true;
                report([entryKey,' L'])=entrynode;
                clear entrynode;
                entrynode.hasDuplicateName=true;
            end
        end

        displayName=entry.Name;
        entrynode.rightname=displayName;
        entrynode.rightscope=scope;
        var=entry.Value;
        entrynode.rightsize=i_getsize(var);
        entrynode.rightclass=comparisons.internal.variableClass(var);
        entrynode.rightentrykey=e2.CurrentKey.toString;
        report([entryKey,keyNote])=entrynode;
        found_diff=true;
        e2.next;
    end

    for namekey=report.keys
        entrynode=report(namekey{1});
        if~isfield(entrynode,'rightname')||isempty(entrynode.rightname)
            if isfield(entrynode,'hasDuplicateName')&&entrynode.hasDuplicateName
                node=i_xmltextnode(doc,root,'LeftVariable_NoMerge',entrynode.leftname);
            else
                node=i_xmltextnode(doc,root,'LeftVariable',entrynode.leftname);
            end
            node.setAttribute('scope',entrynode.leftscope);
            node.setAttribute('size',entrynode.leftsize);
            node.setAttribute('class',entrynode.leftclass);
            node.setAttribute('entrykey',entrynode.leftentrykey);
            node.setAttribute('contentsColor',colors.leftvarcolor);
            node.setAttribute('statusSummary',...
            getString(message('SLDD:sldd:DictDiffRemoved')));
            node.setAttribute('tableSummary',...
            getString(message('SLDD:sldd:DictDiffNotInList')));
        elseif~isfield(entrynode,'leftname')||isempty(entrynode.leftname)
            if isfield(entrynode,'hasDuplicateName')&&entrynode.hasDuplicateName
                node=i_xmltextnode(doc,root,'RightVariable_NoMerge',entrynode.rightname);
            else
                node=i_xmltextnode(doc,root,'RightVariable',entrynode.rightname);
            end
            node.setAttribute('scope',entrynode.rightscope);
            node.setAttribute('size',entrynode.rightsize);
            node.setAttribute('class',entrynode.rightclass);
            node.setAttribute('entrykey',entrynode.rightentrykey);
            node.setAttribute('contentsColor',colors.rightvarcolor);
            node.setAttribute('statusSummary',...
            getString(message('SLDD:sldd:DictDiffAdded')));
            node.setAttribute('tableSummary',...
            getString(message('SLDD:sldd:DictDiffNotInList')));
        else
            node=i_xmltextnode(doc,root,'Variable',entrynode.leftname);
            node.setAttribute('leftname',entrynode.leftname);
            node.setAttribute('leftscope',entrynode.leftscope);
            node.setAttribute('leftsize',entrynode.leftsize);
            node.setAttribute('leftclass',entrynode.leftclass);
            node.setAttribute('leftentrykey',entrynode.leftentrykey);
            node.setAttribute('rightname',entrynode.rightname);
            node.setAttribute('rightscope',entrynode.rightscope);
            node.setAttribute('rightsize',entrynode.rightsize);
            node.setAttribute('rightclass',entrynode.rightclass);
            node.setAttribute('rightentrykey',entrynode.rightentrykey);
            node.setAttribute('contentsMatch',entrynode.contentsMatch);
            if~strcmp(entrynode.contentsMatch,'yes')&&~strcmp(entrynode.contentsMatch,'classesdiffer')


                node.setAttribute('contentsColor',colors.modifiedvarcolor);
                node.setAttribute('statusSummary',...
                getString(message('SLDD:sldd:DictDiffModified')));
            else
                node.setAttribute('contentsColor',colors.backgroundcolor);
                node.setAttribute('statusSummary',...
                getString(message('SLDD:sldd:DictDiffIdentical')));
            end
        end
    end


end



function found_diff=i_doShowChangesCompare(doc,root,ddConn,showOnlyChanges,extraNameSort,colors)

    report=containers.Map;

    found_diff=false;
    idVector=ddConn.getChangedEntries()';
    for id=idVector

        clear entrynode;

        newEntry=false;
        try
            currentInfo=ddConn.getEntryInfo(id);
            if isequal(currentInfo.Status,'New')

                newEntry=true;
            end
        catch
            currentInfo='';
        end
        try
            if~newEntry
                savedInfo=ddConn.getEntryAtRevertPoint(id);
            else
                savedInfo='';
            end
        catch
            savedInfo='';
        end

        if~isempty(savedInfo)&&~isempty(currentInfo)

            entry1=savedInfo;
            entry2=currentInfo;
            displayName1=entry1.Name;
            var1=entry1.Value;
            displayName2=entry2.Name;
            var2=entry2.Value;
            if isequal(entry1.LastModified,entry2.LastModified)
                match_type='yes';
            else
                match_type=comparisons.internal.variablesEqual(var1,var2);
            end
            if~strcmp(match_type,'yes')
                found_diff=true;
            elseif~isequal(displayName1,displayName2)
                found_diff=true;
                match_type='no';
            elseif~isequal(entry1.DataSource,entry2.DataSource)
                found_diff=true;
                match_type='no';
            end


            if(~strcmp(match_type,'yes')||~showOnlyChanges)
                scope=i_getScopeName('',entry1.ParentUUID);
                entrynode.leftname=displayName1;
                entrynode.leftscope=scope;
                entryKey=[entrynode.leftname,'_',scope,'_',entry1.DataSource];
                entrynode.leftdatasource=entry1.DataSource;
                entrynode.leftclass=comparisons.internal.variableClass(var1);
                entrynode.leftentrykey=num2str(id);
                entrynode.rightname=displayName2;
                scope=i_getScopeName('',entry2.ParentUUID);
                entrynode.rightscope=scope;
                entrynode.rightdatasource=entry2.DataSource;
                entrynode.rightclass=comparisons.internal.variableClass(var2);
                entrynode.rightentrykey=num2str(id);
                entrynode.contentsMatch=match_type;
                entrynode.lastmod=Simulink.dd.private.convertISOTimeToLocal(entry2.LastModified);


                report([entryKey,' B'])=entrynode;
            end
        elseif~isempty(savedInfo)

            entry=savedInfo;
            scope=i_getScopeName('',entry.ParentUUID);
            entryKey=[entry.Name,'_',scope,'_',entry.DataSource];

            keyNote=' L';
            if report.isKey([entryKey,' R'])
                if extraNameSort
                    entrynode=report([entryKey,' R']);
                    keyNote=' B';
                    report.remove([entryKey,' R']);
                    entrynode.contentsMatch='no';
                else
                    entrynode=report([entryKey,' R']);
                    entrynode.hasDuplicateName=true;
                    report([entryKey,' R'])=entrynode;
                    clear entrynode;
                    entrynode.hasDuplicateName=true;
                end
            end

            displayName=entry.Name;
            entrynode.leftname=displayName;
            entrynode.leftscope=scope;
            var=entry.Value;
            entrynode.leftdatasource=entry.DataSource;
            entrynode.leftclass=comparisons.internal.variableClass(var);
            entrynode.leftentrykey=num2str(id);
            entrynode.lastmod=Simulink.dd.private.convertISOTimeToLocal(entry.LastModified);
            report([entryKey,keyNote])=entrynode;
            found_diff=true;
        else

            entry=currentInfo;
            scope=i_getScopeName('',entry.ParentUUID);
            entryKey=[entry.Name,'_',scope,'_',entry.DataSource];

            keyNote=' R';
            if report.isKey([entryKey,' L'])
                if extraNameSort
                    entrynode=report([entryKey,' L']);
                    keyNote=' B';
                    report.remove([entryKey,' L']);
                    entrynode.contentsMatch='no';
                else
                    entrynode=report([entryKey,' L']);
                    entrynode.hasDuplicateName=true;
                    report([entryKey,' L'])=entrynode;
                    clear entrynode;
                    entrynode.hasDuplicateName=true;
                end
            end

            displayName=entry.Name;
            entrynode.rightname=displayName;
            entrynode.rightscope=scope;
            var=entry.Value;
            entrynode.rightdatasource=entry.DataSource;
            entrynode.rightclass=comparisons.internal.variableClass(var);
            entrynode.rightentrykey=num2str(id);
            entrynode.lastmod=Simulink.dd.private.convertISOTimeToLocal(entry.LastModified);
            found_diff=true;
            report([entryKey,keyNote])=entrynode;
        end
    end

    for namekey=report.keys
        entrynode=report(namekey{1});
        if~isfield(entrynode,'rightname')||isempty(entrynode.rightname)
            if isfield(entrynode,'hasDuplicateName')&&entrynode.hasDuplicateName
                node=i_xmltextnode(doc,root,'LeftVariable_NoMerge',entrynode.leftname);
            else
                node=i_xmltextnode(doc,root,'LeftVariable',entrynode.leftname);
            end
            node.setAttribute('scope',entrynode.leftscope);
            node.setAttribute('datasource',entrynode.leftdatasource);
            node.setAttribute('class',entrynode.leftclass);
            node.setAttribute('entrykey',entrynode.leftentrykey);
            node.setAttribute('contentsColor',colors.leftvarcolor);
            node.setAttribute('statusSummary',...
            getString(message('SLDD:sldd:ShowChangesRemoved')));
            node.setAttribute('tableSummary',...
            getString(message('SLDD:sldd:ShowChangesNotInList')));
        elseif~isfield(entrynode,'leftname')||isempty(entrynode.leftname)
            if isfield(entrynode,'hasDuplicateName')&&entrynode.hasDuplicateName
                node=i_xmltextnode(doc,root,'RightVariable_NoMerge',entrynode.rightname);
            else
                node=i_xmltextnode(doc,root,'RightVariable',entrynode.rightname);
            end
            node.setAttribute('scope',entrynode.rightscope);
            node.setAttribute('datasource',entrynode.rightdatasource);
            node.setAttribute('class',entrynode.rightclass);
            node.setAttribute('entrykey',entrynode.rightentrykey);
            node.setAttribute('contentsColor',colors.rightvarcolor);
            node.setAttribute('statusSummary',...
            getString(message('SLDD:sldd:ShowChangesAdded')));
            node.setAttribute('tableSummary',...
            getString(message('SLDD:sldd:ShowChangesNotInList')));
        else
            node=i_xmltextnode(doc,root,'Variable',entrynode.leftname);
            node.setAttribute('leftname',entrynode.leftname);
            node.setAttribute('leftscope',entrynode.leftscope);
            node.setAttribute('leftdatasource',entrynode.leftdatasource);
            node.setAttribute('leftclass',entrynode.leftclass);
            node.setAttribute('leftentrykey',entrynode.leftentrykey);
            node.setAttribute('rightname',entrynode.rightname);
            node.setAttribute('rightscope',entrynode.rightscope);
            node.setAttribute('rightdatasource',entrynode.rightdatasource);
            node.setAttribute('rightclass',entrynode.rightclass);
            node.setAttribute('rightentrykey',entrynode.rightentrykey);
            if isequal(entrynode.leftentrykey,entrynode.rightentrykey)
                node.setAttribute('contentsMatch',entrynode.contentsMatch);
            else
                node.setAttribute('contentsMatch','onlyname');
            end
            if~strcmp(entrynode.contentsMatch,'yes')&&~strcmp(entrynode.contentsMatch,'classesdiffer')


                node.setAttribute('contentsColor',colors.modifiedvarcolor);
                node.setAttribute('statusSummary',...
                getString(message('SLDD:sldd:ShowChangesModified')));
            else
                node.setAttribute('contentsColor',colors.backgroundcolor);
                node.setAttribute('statusSummary',...
                getString(message('SLDD:sldd:ShowChangesIdentical')));
            end
        end
        node.setAttribute('lastmod',entrynode.lastmod);
    end


end




function found_diff=i_doDSRefCompare(doc,root,dsa1,dsa2,showOnlyChanges,colors)

    found_diff=false;
    ref1=dsa1.dictionaryReferences;
    ref2=dsa2.dictionaryReferences;
    ref1.first;
    ref2.first;
    while ref1.HasCurrent&&ref2.HasCurrent
        if ref1.CurrentKey==ref2.CurrentKey

            displayName1=ref1.Current.Filename;
            displayName2=ref2.Current.Filename;
            if~isequal(displayName1,displayName2)
                found_diff=true;
                match_type='no';
            else
                match_type='yes';
            end


            if(~strcmp(match_type,'yes')||~showOnlyChanges)
                node=i_xmltextnode(doc,root,'Reference',displayName1);
                node.setAttribute('leftname',displayName1);
                node.setAttribute('rightname',displayName2);
                node.setAttribute('contentsMatch',match_type);
                node.setAttribute('contentsColor',colors.modifiedvarcolor);
                node.setAttribute('statusSummary',...
                [getString(message('SLDD:sldd:DictDiffModified')),' ']);
            end
            ref1.next;
            ref2.next;
        elseif ref1.CurrentKey<ref2.CurrentKey

            displayName=ref1.Current.Filename;
            node=i_xmltextnode(doc,root,'LeftRef',displayName);
            node.setAttribute('refkey',ref1.CurrentKey.toString);
            node.setAttribute('contentsColor',colors.leftvarcolor);
            node.setAttribute('statusSummary',...
            getString(message('SLDD:sldd:DictDiffRemoved')));
            node.setAttribute('tableSummary',...
            getString(message('SLDD:sldd:DictDiffNotInList')));
            found_diff=true;
            ref1.next;
        else

            displayName=ref2.Current.Filename;
            node=i_xmltextnode(doc,root,'RightRef',displayName);
            node.setAttribute('refkey',ref2.CurrentKey.toString);
            node.setAttribute('contentsColor',colors.rightvarcolor);
            node.setAttribute('statusSummary',...
            getString(message('SLDD:sldd:DictDiffAdded')));
            node.setAttribute('tableSummary',...
            getString(message('SLDD:sldd:DictDiffNotInList')));
            found_diff=true;
            ref2.next;
        end
    end
    while ref1.HasCurrent

        displayName=ref1.Current.Filename;
        node=i_xmltextnode(doc,root,'LeftRef',displayName);
        node.setAttribute('refkey',ref1.CurrentKey.toString);
        node.setAttribute('contentsColor',colors.leftvarcolor);
        node.setAttribute('statusSummary',...
        getString(message('SLDD:sldd:DictDiffRemoved')));
        node.setAttribute('tableSummary',...
        getString(message('SLDD:sldd:DictDiffNotInList')));
        found_diff=true;
        ref1.next;
    end
    while ref2.HasCurrent

        displayName=ref2.Current.Filename;
        node=i_xmltextnode(doc,root,'RightRef',displayName);
        node.setAttribute('refkey',ref2.CurrentKey.toString);
        node.setAttribute('contentsColor',colors.rightvarcolor);
        node.setAttribute('statusSummary',...
        getString(message('SLDD:sldd:DictDiffAdded')));
        node.setAttribute('tableSummary',...
        getString(message('SLDD:sldd:DictDiffNotInList')));
        found_diff=true;
        ref2.next;
    end

end




function found_diff=i_doDictRefChanges(doc,root,ddConn,showOnlyChanges,colors)
    found_diff=false;

    [changedRefs,changedStatus]=ddConn.getChangedReferences();

    origRefs={};
    unsavedRefs={};

    count=length(changedRefs);
    for idx=1:count
        if isequal(changedStatus{idx},'del')
            origRefs=[origRefs,changedRefs{idx}];
        elseif isequal(changedStatus{idx},'new')
            unsavedRefs=[unsavedRefs,changedRefs{idx}];
        end
    end

    if showOnlyChanges
        diffs=setxor(origRefs,unsavedRefs);
    else
        diffs=union(origRefs,unsavedRefs);
    end
    if length(diffs)>0
        found_diff=true;

        count=length(diffs);
        for idx=1:count
            refDict=diffs{idx};
            [p,f,e]=fileparts(refDict);
            displayName=[f,e];
            if any(ismember(origRefs,refDict))
                if~showOnlyChanges&&any(ismember(unsavedRefs,refDict))
                    node=i_xmltextnode(doc,root,'Reference',displayName);
                    node.setAttribute('leftname',displayName);
                    node.setAttribute('rightname',displayName);
                    node.setAttribute('contentsMatch','yes');
                    node.setAttribute('contentsColor',colors.backgroundcolor);
                    node.setAttribute('statusSummary',...
                    [getString(message('SLDD:sldd:ShowChangesIdentical')),' ']);
                else
                    node=i_xmltextnode(doc,root,'LeftRef',displayName);
                    node.setAttribute('contentsColor',colors.leftvarcolor);
                    node.setAttribute('tableSummary',...
                    getString(message('SLDD:sldd:ShowChangesNotInList')));
                    node.setAttribute('statusSummary',...
                    getString(message('SLDD:sldd:ShowChangesRemovedRef')));
                end
            else
                node=i_xmltextnode(doc,root,'RightRef',displayName);
                node.setAttribute('contentsColor',colors.rightvarcolor);
                node.setAttribute('tableSummary',...
                getString(message('SLDD:sldd:ShowChangesNotInList')));
                node.setAttribute('statusSummary',...
                getString(message('SLDD:sldd:ShowChangesAdded')));
            end
            node.setAttribute('refkey',refDict);
        end
    end
end



function node=i_xmltextnode(docNode,parentNode,tag,content)

    node=docNode.createElement(tag);
    node.appendChild(docNode.createTextNode(content));
    parentNode.appendChild(node);
end


function str=i_getsize(var)
    sz=size(var);


    if numel(sz)==2
        str=sprintf('%dx%d',sz(1),sz(2));
    elseif numel(sz)==3
        str=sprintf('%dx%dx%d',sz(1),sz(2),sz(3));
    else

        str=sprintf('%d-D',numel(sz));
    end


end


function[source,fullname,shortname,readable]=i_resolve(source)

    if ischar(source)

        source=comparisons.internal.resolvePath(source);
        source=com.mathworks.comparisons.source.impl.LocalFileSource(java.io.File(source),source);
    end

    absnameprop=com.mathworks.comparisons.source.property.CSPropertyAbsoluteName.getInstance();
    if source.hasProperty(absnameprop)
        fullname=char(source.getPropertyValue(absnameprop,[]));
    else

        nameprop=com.mathworks.comparisons.source.property.CSPropertyName.getInstance();

        assert(source.hasProperty(nameprop));
        fullname=char(source.getPropertyValue(nameprop,[]));
    end

    shorttitleprop=com.mathworks.comparisons.source.property.CSPropertyShortTitle.getInstance();
    if source.hasProperty(shorttitleprop)
        shortname=char(source.getPropertyValue(shorttitleprop,[]));
    else

        nameprop=com.mathworks.comparisons.source.property.CSPropertyName.getInstance();

        assert(source.hasProperty(nameprop));
        shortname=char(source.getPropertyValue(nameprop,[]));
    end

    readableprop=com.mathworks.comparisons.source.property.CSPropertyReadableLocation.getInstance();

    assert(source.hasProperty(readableprop));
    readable=char(source.getPropertyValue(readableprop,[]));
end



function scope=i_getScopeName(dsa,parentUUID)



    if isequal(parentUUID.char,'dacaf35e-55a5-454d-a7c1-93db038a210e')
        scope='Design Data';
    elseif isequal(parentUUID.char,'a3b2532e-8e6e-47f5-94fb-b15daf666a84')
        scope='Configurations';
    elseif isequal(parentUUID.char,'42516768-0ace-4981-8ac7-0a9b32cba471')
        scope='Other Data';
    end

end


function colors=i_defineColors()
    import comparisons.internal.colorutil.Colors
    import comparisons.internal.colorutil.rgb2hex
    colors.backgroundcolor='#FFF';
    colors.leftvarcolor=rgb2hex(Colors.leftColor());
    colors.rightvarcolor=rgb2hex(Colors.rightColor());
    colors.modifiedvarcolor=rgb2hex(Colors.modifiedColor());

end
