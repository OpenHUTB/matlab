function out=execute(this,d,varargin)





    adSL=rptgen_sl.appdata_sl;

    if strcmpi(adSL.Context,'datadictionary')
        dictPath=adSL.CurrentDataDictionary;
    else
        error('csl_data_dictionary:context',msg(this,'contextError'));
    end

    out=d.createDocumentFragment;

    try
        dictObj=Simulink.data.dictionary.open(dictPath);



        origVal=dictObj.EnableAccessToBaseWorkspace;
        discardDD=~dictObj.HasUnsavedChanges;
        dictObj.EnableAccessToBaseWorkspace=false;
        scopedCleanup=onCleanup(@()locDicObjCleanup(dictObj,origVal,discardDD));

    catch ME
        error('csl_data_dictionary:open',...
        msg(this,'openError',strrep(dictPath,'\\','/'),ME.message));
    end

    if this.IncludeDesignDataSection

        dictSect=getSection(dictObj,'Design Data');

        if locSectionContainsDuplicateEntries(dictSect)
            error('csl_data_dictionary:design_data_dup',...
            msg(this,'errorDesignDataDups',dictPath));
        end

        data=evalin(dictSect,'whos');

        if~isempty(data)

            sectNode=locCreateDataSummary(this,d,dictPath,dictSect,...
            'Design Data',data,dictObj.DataSources,...
            this.IncludeChildDictionariesList);
            appendChild(out,sectNode);


            sectNode=locCreateDataDetails(this,d,dictPath,dictSect,...
            'Design Data',data);
            appendChild(out,sectNode);

        end

    end

    if this.IncludeOtherDataSection

        dictSect=getSection(dictObj,'Other Data');

        if locSectionContainsDuplicateEntries(dictSect)
            error('csl_data_dictionary:other_data_dup',...
            msg(this,'errorOtherDataDups',dictPath));
        end

        data=evalin(dictSect,'whos');

        if~isempty(data)


            sectNode=locCreateDataSummary(this,...
            d,dictPath,dictSect,'Other Data',data,...
            dictObj.DataSources,false);
            appendChild(out,sectNode);


            sectNode=locCreateDataDetails(this,d,dictPath,dictSect,...
            'Other Data',data);
            appendChild(out,sectNode);

        end

    end

    if this.IncludeConfigurationsSection

        dictSect=getSection(dictObj,'Configurations');

        if locSectionContainsDuplicateEntries(dictSect)
            error('csl_data_dictionary:config_dup',...
            msg(this,'errorConfigDups',dictPath));
        end

        data=evalin(dictSect,'whos');

        if~isempty(data)


            sectNode=locCreateDataSummary(this,d,dictPath,dictSect,...
            'Configurations',data,dictObj.DataSources,false);
            appendChild(out,sectNode);


            warningID='Simulink:ConfigSet:SimModeMovedToMdlInvalidGet';
            warning('off',warningID);
            sectNode=locCreateDataDetails(this,d,dictPath,dictSect,...
            'Configurations',data);
            warning('on',warningID);

            appendChild(out,sectNode);

        end

    end

end

function sectNode=locCreateDataSummary(this,d,dictPath,dictSect,...
    sectName,data,dataSources,showChildDictionaryList)


    entries=arrayfun(@(datum)getEntry(dictSect,datum.name),data,...
    'UniformOutput',false);

    types=arrayfun(@(datum)datum.class,data,'UniformOutput',false);

    [~,thisDictName,ext]=fileparts(dictPath);
    thisDictName=[thisDictName,ext];

    sectNode=createElement(d,'simplesect');
    sectTitleDOM=createElement(d,'title');
    titleContentDOM=createTextNode(d,[sectName,' Summary']);
    appendChild(sectTitleDOM,titleContentDOM);
    appendChild(sectNode,sectTitleDOM);

    propNames=locGetPropsToInclude(this);
    propNameCount=numel(propNames);

    cellTableBody=cell(numel(entries),numel(propNames));

    for r=1:numel(entries)
        sectEntry=entries{r};
        sectEntryDataType=types{r};

        id=locCreateEntryID(dictPath,sectName,sectEntry.Name);
        link=makeLink(d,id,sectEntry.Name);
        if rptgen.use_java
            cellTableBody(r,1)=link;
        else
            cellTableBody{r,1}=link;
        end

        for c=2:propNameCount
            propName=propNames{c};
            switch propName
            case 'class'
                propValue=sectEntryDataType;
            case 'Value'
                value=getValue(sectEntry);
                if isa(value,'Simulink.Parameter')
                    value=value.Value;
                end
                if(isnumeric(value)||islogical(value))&&...
                    isscalar(value)
                    propValue=num2str(value);
                else
                    if ischar(value)&&(min(size(value))==1)
                        propValue=value;
                    else
                        propValue=msg(this,'seeDetails');
                    end
                end
            case 'LastModified'
                propValue=locFormatTime(sectEntry.(propName));
            otherwise
                propValue=sectEntry.(propName);
            end
            if rptgen.use_java
                cellTableBody(r,c)=createTextNode(d,propValue);
            else
                cellTableBody{r,c}=createTextNode(d,propValue);
            end
        end

    end

    dataSourceList=unique(dataSources);

    if this.IncludeChildDictionaries
        if this.MakeSeparateTableForChild
            dataSourceList=[{thisDictName},dataSourceList];
            nSources=numel(dataSourceList);
            for i=1:nSources
                dataSource=dataSourceList{i};
                idx=cellfun(@(e)strcmp(e.DataSource,dataSource),...
                entries);
                cellSourceTableBody=cellTableBody(idx,:);
                cellTableHead=locCreateTableHead(d,propNames,propNameCount);
                cellTable=[cellTableHead;cellSourceTableBody];
                tm=makeNodeTable(d,cellTable);
                tm.setTitle(dataSource);
                tm.setPageWide(true);
                tm.setNumHeadRows(1);
                nodeTable=createTable(tm);
                appendChild(sectNode,nodeTable);
            end
        else
            cellTableHead=locCreateTableHead(d,propNames,propNameCount);
            cellTable=[cellTableHead;cellTableBody];
            tm=makeNodeTable(d,cellTable);
            tm.setTitle(thisDictName);
            tm.setPageWide(true);
            tm.setNumHeadRows(1);
            nodeTable=createTable(tm);
            appendChild(sectNode,nodeTable);
        end
    else
        idx=cellfun(@(e)strcmp(e.DataSource,thisDictName),entries);
        cellTableBody=cellTableBody(idx,:);
        if~isempty(cellTableBody)
            cellTableHead=locCreateTableHead(d,propNames,propNameCount);
            cellTable=[cellTableHead;cellTableBody];
            tm=makeNodeTable(d,cellTable);
            tm.setTitle(thisDictName);
            tm.setPageWide(true);
            tm.setNumHeadRows(1);
            nodeTable=createTable(tm);
            appendChild(sectNode,nodeTable);
        end
    end

    if showChildDictionaryList
        idx=cellfun(@(childDict)~strcmp(childDict,thisDictName),...
        dataSourceList);
        dataSourceList=dataSourceList(idx);
        if~isempty(dataSourceList)
            if rptgen.use_java
                lm=com.mathworks.toolbox.rptgencore.docbook.ListMaker(dataSourceList);
                lm.setTitle([this.msg('DictionaryReportField_ChildDictionariesListTitle'),':']);
                lm.setListType('itemizedlist');
                listNode=lm.createList(java(d));
            else
                lm=mlreportgen.re.internal.db.ListMaker(dataSourceList);
                setTitle(lm,[this.msg('DictionaryReportField_ChildDictionariesListTitle'),':']);
                setListType(lm,'itemizedlist');
                listNode=createList(lm,d.Document);
            end
            appendChild(sectNode,listNode);
        end
    end

end

function cellTableHead=locCreateTableHead(d,propNames,propNameCount)
    cellTableHead=cell(1,propNameCount);
    for c=1:propNameCount
        if rptgen.use_java
            cellTableHead(1,c)=createTextNode(d,propNames{c});
        else
            cellTableHead{1,c}=createTextNode(d,propNames{c});
        end
    end
end

function sectNode=locCreateDataDetails(this,d,dictPath,dictSect,...
    sectName,data)

    sectNode=createElement(d,'simplesect');
    sectTitleDOM=createElement(d,'title');
    titleContentDOM=createTextNode(d,[sectName,' Details']);
    appendChild(sectTitleDOM,titleContentDOM);
    appendChild(sectNode,sectTitleDOM);

    [~,thisDictName,ext]=fileparts(dictPath);
    thisDictName=[thisDictName,ext];

    vd=rptgen.rpt_var_display;
    for i=1:numel(data)
        entry=getEntry(dictSect,data(i).name);
        if this.IncludeChildDictionaries||...
            strcmp(entry.DataSource,thisDictName)
            eStruct.Value=getValue(entry);
            eStruct.DataType=data(i).class;
            eStruct.LastModified=locFormatTime(entry.LastModified);
            eStruct.LastModifiedBy=entry.LastModifiedBy;
            eStruct.Status=entry.Status;
            eStruct.DataSource=entry.DataSource;
            entryNode=vd.reportVariable(d,entry.Name,eStruct);
            id=locCreateEntryID(dictPath,sectName,entry.Name);
            anchorNode=makeLink(d,id);
            appendChild(sectNode,anchorNode);
            appendChild(sectNode,entryNode);
        end
    end

end

function id=locCreateEntryID(dictPath,sectName,dataName)
    id=[dictPath,sectName,dataName];
    id=char(mlreportgen.utils.normalizeLinkID(id));
end

function timeOut=locFormatTime(timeIn)
    timeOut=datestr(datenum(timeIn,...
    'yyyy-mmm-dd HH:MM:SS'),...
    'yyyy-mm-dd HH:MM');
end

function propsToInclude=locGetPropsToInclude(this)
    propsToInclude={'Name','Value'};
    if this.ShowDataType
        propsToInclude{length(propsToInclude)+1}='class';
    end

    if this.ShowLastModified
        propsToInclude{length(propsToInclude)+1}='LastModified';
    end
    if this.ShowLastModifiedBy
        propsToInclude{length(propsToInclude)+1}='LastModifiedBy';
    end
    if this.ShowStatus
        propsToInclude{length(propsToInclude)+1}='Status';
    end

    if this.IncludeChildDictionaries&&this.ShowDataSource...
        &&~this.MakeSeparateTableForChild
        propsToInclude{length(propsToInclude)+1}='DataSource';
    end

end

function tf=locSectionContainsDuplicateEntries(sect)
    entries=find(sect);
    entries={entries.Name};
    tf=numel(unique(entries))<numel(entries);
end

function locDicObjCleanup(dictObj,origVal,discardDD)
    dictObj.EnableAccessToBaseWorkspace=origVal;
    if discardDD
        dictObj.discardChanges;
    end
end


