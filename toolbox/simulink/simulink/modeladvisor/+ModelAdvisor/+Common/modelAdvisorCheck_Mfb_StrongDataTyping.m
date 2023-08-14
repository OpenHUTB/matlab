



function[bResultStatus,resultDescription,resultHandles]=...
    modelAdvisorCheck_Mfb_StrongDataTyping(system,checkSize,MSG)

    bResultStatus=true;
    resultDescription={};
    resultHandles={};

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    sysObj=get_param(system,'Object');

    htmlTable=initializeResultTable(MSG);

    emcObjects=sysObj.find('-isa','Stateflow.EMChart');
    emfObjects=sysObj.find('-isa','Stateflow.EMFunction');
    emObjects=[emcObjects;emfObjects];


    if isempty(emObjects)

        htmlTable.setSubResultStatus('Pass');
        htmlTable.setSubResultStatusText(...
        TEXT(MSG,'Himl0002_PassNoMatlabFunctionBlocks'));
        htmlTable.setSubBar(false);
        resultDescription{end+1}=htmlTable;
        resultHandles{end+1}=[];
        return;
    end

    emObjects=mdladvObj.filterResultWithExclusion(emObjects);

    for idx=1:numel(emObjects)

        interface=getInterface(emObjects(idx));
        issues=checkInterface(interface,checkSize,MSG);
        issues=mergeNameAndScope(issues);

        if~isempty(issues)

            bResultStatus=false;
            detailsTable=createDeatilsTable(issues,MSG);

            switch class(emObjects(idx))
            case 'Stateflow.EMChart'
                SID=Simulink.ID.getSID(emObjects(idx));
            case 'Stateflow.EMFunction'

                SID=Simulink.ID.getSID(emObjects(idx));
            end
            modelLink=ModelAdvisor.Text(SID);

            htmlTable.addRow({modelLink,detailsTable});

        end

    end

    finalizeResultTable(htmlTable,bResultStatus,checkSize,MSG);

    resultDescription{end+1}=htmlTable;
    resultHandles{end+1}=[];

end

function string=TEXT(MSG,ID)
    string=DAStudio.message([MSG,ID]);
end

function htmlTable=initializeResultTable(MSG)

    htmlTable=ModelAdvisor.FormatTemplate('TableTemplate');
    htmlTable.setCheckText(TEXT(MSG,'Himl0002_CheckText'));


    referenceText1=TEXT(MSG,'Himl0002_Reference1');
    htmlTable.setColTitles(...
    {...
    TEXT(MSG,'Himl0002_TableHead1'),...
    TEXT(MSG,'Himl0002_TableHead2')...
    });

end

function finalizeResultTable(htmlTable,bResultStatus,checkSize,MSG)

    if bResultStatus

        htmlTable.setSubResultStatus('Pass');
        htmlTable.setSubResultStatusText(TEXT(MSG,'Himl0002_Pass'));
    else

        htmlTable.setSubResultStatus('Warn');
        htmlTable.setSubResultStatusText(TEXT(MSG,'Himl0002_Fail'));

        actionText1=ModelAdvisor.Text(TEXT(MSG,'Himl0002_ActionText1'));

        actionList=ModelAdvisor.List();
        actionList.addItem(TEXT(MSG,'Himl0002_ActionItem1'));
        actionList.addItem(TEXT(MSG,'Himl0002_ActionItem2'));
        if checkSize
            actionList.addItem(TEXT(MSG,'Himl0002_ActionItem3'));
        end

        htmlTable.setRecAction([actionText1,actionList]);
    end

    htmlTable.setSubBar(false);

end

function interface=getInterface(blockObject)

    interface=struct(...
    'Name',{},...
    'Scope',{},...
    'Type',{},...
    'Size',{},...
    'Complexity',{},...
    'VariableSize',{});

    dataObjects=blockObject.find('-isa','Stateflow.Data');

    thisObjectSubSystem=sfprivate('chart2block',blockObject.Id);

    for idx=1:length(dataObjects)

        thisObject=dataObjects(idx);

        interface(idx).Name=thisObject.Name;
        interface(idx).Scope=thisObject.Scope;
        interface(idx).Type=thisObject.DataType;
        interface(idx).Size=thisObject.Props.Array.Size;









        if Advisor.Utils.Simulink.isEnumOutDataTypeStr(bdroot(thisObjectSubSystem),thisObject.DataType)||...
            Advisor.Utils.Simulink.isBusDataTypeStr(bdroot(thisObjectSubSystem),thisObject.DataType)||...
            strcmp(thisObject.DataType,'boolean')

            interface(idx).Complexity='Not Defined';

        else

            interface(idx).Complexity=thisObject.Props.Complexity;

        end

        if thisObject.Props.Array.IsDynamic

            interface(idx).VariableSize='true';
            analysisOptions.AllowUnsavedChanges=true;

        else

            interface(idx).VariableSize='false';

        end

    end

end

function issues=checkInterface(interface,checkSize,MSG)
    issues=cell(0,4);

    for row=1:length(interface)

        if strcmp(interface(row).Scope,'Data Store Memory')==1



            continue;
        end

        if checkSize&&strcmp(interface(row).Size,'-1')==1


            issues{end+1,1}=interface(row).Name;%#ok<AGROW> no prealloc
            issues{end,2}=interface(row).Scope;
            issues{end,3}=TEXT(MSG,'Himl0002_DetailsSize');
            issues{end,4}=interface(row).Size;

        end

        if strcmp(interface(row).Type,'Inherit: Same as Simulink')||...
            strcmp(interface(row).Type,'Inherit: From definition in chart')

            issues{end+1,1}=interface(row).Name;%#ok<AGROW> no prealloc
            issues{end,2}=interface(row).Scope;
            issues{end,3}=TEXT(MSG,'Himl0002_DetailsType');
            issues{end,4}=interface(row).Type;

        end



        if strcmp(interface(row).Complexity,'Inherited')==1

            issues{end+1,1}=interface(row).Name;%#ok<AGROW> no prealloc
            issues{end,2}=interface(row).Scope;
            issues{end,3}=TEXT(MSG,'Himl0002_DetailsComplexity');
            issues{end,4}=interface(row).Complexity;
        end

    end

end

function issuesNew=mergeNameAndScope(issues)

    oldName='';
    issuesNew=issues;

    for r=1:size(issuesNew,1)

        currentName=issuesNew{r,1};
        currentScope=issuesNew{r,2};

        if strcmp(currentName,oldName)==1
            issuesNew{r,1}='&nbsp;';
        else

            issuesNew{r,1}=[currentName,'<br/>(',currentScope,')'];
            oldName=currentName;
        end
        analysisOptions.AllowUnsavedChanges=true;

    end

    issuesNew(:,2)=[];

end

function detailsTable=createDeatilsTable(issues,MSG)

    hiddenContent=sprintf('%d %s',...
    size(issues,1),...
    DAStudio.message([MSG,'Himl0002_Issues']));

    detailsTable=ModelAdvisor.Table(size(issues,1),size(issues,2));

    detailsTable.setColHeading(1,TEXT(MSG,'Himl0002_DetailsHeading1'));
    detailsTable.setColHeading(2,TEXT(MSG,'Himl0002_DetailsHeading2'));
    detailsTable.setColHeading(3,TEXT(MSG,'Himl0002_DetailsHeading3'));

    detailsTable.setEntries(issues);

    detailsTable.setBorder(1);

    detailsTable.setCollapsibleMode('all');
    detailsTable.setHiddenContent(hiddenContent);
    detailsTable.setDefaultCollapsibleState('collapsed');

    detailsTable.setColWidth(1,1);
    detailsTable.setColWidth(2,1);
    detailsTable.setColWidth(3,1);

end

