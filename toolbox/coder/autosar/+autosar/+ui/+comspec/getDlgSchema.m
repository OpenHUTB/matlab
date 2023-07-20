




function dlgstruct=getDlgSchema(obj)

    m3iPort=obj.getM3iObject();
    mdlName=obj.getModelName();

    if~isempty(m3iPort)
        dlgstruct=getDlgSchemaSpreadsheet(m3iPort,mdlName);

        dlgstruct.DialogTag='autosar_comspec_dialog';
    else
        dlgstruct.DialogTitle='';
        dlgstruct.Items={};
    end
    dlgstruct.EmbeddedButtonSet={''};
end

function dlgstruct=getDlgSchemaSpreadsheet(m3iPort,mdlName)

    dlgstruct=[];

    arExplorer=autosar.ui.utils.findExplorer(m3iPort.modelM3I);
    assert(~isempty(arExplorer));

    if autosar.api.Utils.isNvPort(m3iPort)
        m3iInfo=m3iPort.Info;
        comSpecPropName='ComSpec';
    else
        m3iInfo=m3iPort.info;
        comSpecPropName='comSpec';
    end

    colHeaders={'DataElement'};
    sortBy=colHeaders{1};

    for infoIdx=1:m3iInfo.size()

        m3iComSpec=m3iInfo.at(infoIdx).(comSpecPropName);
        comSpecProps=properties(m3iComSpec);


        comSpecProps=filterComSpecProps(comSpecProps,m3iComSpec);
        colHeaders=[colHeaders,...
        comSpecProps(~ismember(comSpecProps,colHeaders))'];%#ok<AGROW>
    end


    for i=2:length(colHeaders)
        colHeaders{i}(1)=upper(colHeaders{i}(1));
        if strcmp(colHeaders{i},'InitialValue')
            colHeaders{i}='InitValue';
        end
    end


    colHeaders=unique(colHeaders,'stable');



    queueLengthIdx=find(ismember(colHeaders,'QueueLength'));
    if~isempty(queueLengthIdx)
        colHeaders{end+1}=colHeaders{queueLengthIdx};
        colHeaders(queueLengthIdx)=[];
    end

    if length(colHeaders)>1
        comSpecSpreadsheetFilter.Type='spreadsheetfilter';
        comSpecSpreadsheetFilter.RowSpan=[1,1];
        comSpecSpreadsheetFilter.Tag='AutosarComSpecSpreadsheetFilter';
        comSpecSpreadsheetFilter.TargetSpreadsheet='AutosarComSpecSpreadsheet';
        comSpecSpreadsheetFilter.PlaceholderText='Filter';
        comSpecSpreadsheetFilter.Clearable=true;

        comSpecSpreadsheet.Type='spreadsheet';
        comSpecSpreadsheet.Columns=colHeaders';
        comSpecSpreadsheet.SortColumn=sortBy;
        comSpecSpreadsheet.SortOrder=true;
        comSpecSpreadsheet.RowSpan=[2,2];
        comSpecSpreadsheet.Enabled=true;
        comSpecSpreadsheet.Source=autosar.ui.comspec.Spreadsheet(m3iPort,mdlName,dlgstruct);
        comSpecSpreadsheet.Tag='AutosarComSpecSpreadsheet';

        bottomSpacer.Type='panel';
        bottomSpacer.RowSpan=[3,3];
        data={...
        comSpecSpreadsheetFilter,...
        comSpecSpreadsheet,bottomSpacer};
        dlgstruct.DialogTitle=DAStudio.message('RTW:autosar:uiComSpecTitleSpreadsheet');

        dlgstruct.Items=data;
        dlgstruct.LayoutGrid=[3,1];
        dlgstruct.RowStretch=[0,0,1];
    else
        dlgstruct.DialogTitle='';
        dlgstruct.Items={};
    end
end

function comSpecProps=filterComSpecProps(comSpecProps,m3iComSpec)

    idx=find(ismember(comSpecProps,'InitialValue'),1);
    if~isempty(idx)
        initValueName=autosar.mm.mm2sl.ConstantBuilder.getInitValuePropertyName(m3iComSpec);
        comSpecProps{idx}=initValueName;
    end

    idx=find(ismember(comSpecProps,'UsesEndToEndProtection'),1);
    if~isempty(idx)
        comSpecProps(idx)=[];
    end

    idx=find(ismember(comSpecProps,'InitialValueROM'),1);
    if~isempty(idx)
        comSpecProps(idx)=[];
    end
end





