function dlgstruct=getDialogSchema(this,~)




    items=getItems(this);
    dlgstruct=getDlgStruct(this,items);
end

function items=getItems(this)
    if this.currentRow==0
        this.currentRow=1;
    end
    items=generateDetailedRow(this);
end

function items=generateDetailedRow(this)
    InfoPanel=generateSummaryRow(this.currentRow,this);

    items=generateSelectionRow(this);

    issueNum=this.currentRow;

    srcBlockPath=this.violations.SrcBlockPath;
    srcPortIdx=this.violations.SrcPortIdx;
    dstBlockPath=this.violations.DstMismatches(issueNum).DstBlockPath;
    dstPortIdx=this.violations.DstMismatches(issueNum).DstPortIdx;

    srcBlockName=regexp(srcBlockPath,'(?<=/)[^/]*$','match');
    srcBlockName=srcBlockName{1};
    dstBlockName=regexp(dstBlockPath,'(?<=/)[^/]*$','match');
    dstBlockName=dstBlockName{1};

    dstMismatches=this.violations.DstMismatches(this.currentRow).MismatchList;
    numMismatches=numel(dstMismatches);

    mmTable=cell(numMismatches+1,2);

    srcLink.Name=[srcBlockName,'/',num2str(srcPortIdx+1)];
    srcLink.Type='hyperlink';
    srcLink.Tag='src_block_link';

    dstLink.Name=[dstBlockName,'/',num2str(dstPortIdx+1)];
    dstLink.Type='hyperlink';
    dstLink.Tag='dst_block_link';
    mmTable{1,1}=srcLink;
    mmTable{1,2}=dstLink;

    for i=1:numMismatches
        srcAttr.Name=dstMismatches(i).SrcAttr;
        srcAttr.Type='text';
        srcAttr.Tag='text_status';

        dstAttr.Name=dstMismatches(i).DstAttr;
        dstAttr.Type='text';
        dstAttr.Tag='text_status';

        mmTable{i+1,1}=srcAttr;
        mmTable{i+1,2}=dstAttr;
    end

    mmAttribTable.Type='table';
    mmAttribTable.Tag='mmAttribTable';
    mmAttribTable.HeaderVisibility=[1,1];
    mmAttribTable.ColumnStretchable=[1,1];
    mmAttribTable.HideName=true;

    mmAttribTable.Data=mmTable;
    mmAttribTable.Editable=true;
    mmAttribTable.ItemClickedCallback=@portSelected;
    mmAttribTable.ItemDoubleClickedCallback=@attributeSelected;
    mmAttribTable.RowHeader=[...
    DAStudio.message('Simulink:tools:EditTimeMismatchPortHeader')...
    ,{dstMismatches(:).Attribute}];
    mmAttribTable.ColHeader={...
    DAStudio.message('Simulink:tools:EditTimeMismatchSourcePort'),...
    DAStudio.message('Simulink:tools:EditTimeMismatchDestPort')};
    mmAttribTable.Size=[numMismatches+1,2];
    mmAttribTable.RowSpan=[1,1];
    mmAttribTable.ColSpan=[1,1];

    if this.groupLook
        container.Type='group';
    else
        container.Type='panel';
    end

    container.Flat=false;
    container.LayoutGrid=[1,1];
    container.RowSpan=[2,2];
    container.RowStretch=0;
    container.ColSpan=[2,4];
    container.ColStretch=1;
    container.ContentsMargins=[2,2];
    container.Items={mmAttribTable};

    items=[InfoPanel,items,{container}];

end

function items=generateSummaryRow(~,this)
    row=1;
    column=1;
    items={};
    issueType.Type='image';
    imagepath=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','private');
    issueType.FilePath=fullfile(imagepath,'task_failed.png');
    issueType.Tag='issueType';
    issueType.RowSpan=[row,row];
    issueType.ColSpan=[column,column];
    issueType.DialogRefresh=true;
    issueType.ToolTip='';
    column=column+1;
    items{end+1}=issueType;


    summary.Name=DAStudio.message('Simulink:tools:EditTimeMismatchSummary',num2str(length(this.violations.DstMismatches)));
    summary.Type='text';
    summary.Tag='summary';
    summary.RowSpan=[row,row];
    summary.ColSpan=[column,column];
    summary.FontPointSize=11;
    items{end+1}=summary;

    if this.groupLook
        container.Type='group';
    else
        container.Type='panel';
    end

    container.Flat=false;
    container.LayoutGrid=[1,column];
    container.RowSpan=[1,1];
    container.RowStretch=1;
    container.ColSpan=[1,4];
    colStrech=zeros(1,column);
    colStrech(column)=1;
    container.ColStretch=colStrech;
    container.ContentsMargins=[2,2];
    if(this.backgroundControl)
        container.BackgroundColor=this.backgroundColor;
    end
    container.Items=items;
    items={container};
end

function items=generateSelectionRow(this)
    dstBlockNames=regexp({this.violations.DstMismatches(:).DstBlockPath},'(?<=/)[^/]*$','match');
    dstBlockNames=[dstBlockNames{:}];
    dstPortIdx={this.violations.DstMismatches(:).DstPortIdx};

    dstBlockPorts=cellfun(@(x,y)[x,'/',num2str(y+1)],dstBlockNames,dstPortIdx,'UniformOutput',false);

    dstPortSelection.Name=DAStudio.message('Simulink:tools:EditTimeMismatchDestPortSelection');
    dstPortSelection.Type='listbox';
    dstPortSelection.Tag='dst_selection';
    dstPortSelection.SelectedItem=this.currentRow-1;
    dstPortSelection.Entries=dstBlockPorts;
    dstPortSelection.Values=1:numel(dstBlockPorts);
    dstPortSelection.MultiSelect=false;
    dstPortSelection.DialogRefresh=true;
    dstPortSelection.ObjectMethod='selectRow';
    dstPortSelection.MethodArgs={'%dialog','%value'};
    dstPortSelection.ArgDataTypes={'handle','mxArray'};
    dstPortSelection.RowSpan=[1,1];
    dstPortSelection.ColSpan=[1,1];
    items={dstPortSelection};

    if this.groupLook
        container.Type='group';
    else
        container.Type='panel';
    end

    container.Flat=false;
    container.LayoutGrid=[1,1];
    container.RowSpan=[2,2];
    container.RowStretch=0;
    container.ColSpan=[1,1];
    container.ColStretch=0;
    container.Items=items;
    container.ContentsMargins=[2,2];
    items={container};

end

function dlgstruct=getDlgStruct(~,items)
    dlgstruct.DialogTitle=DAStudio.message('Simulink:tools:EditTimeMismatchTitle');
    dlgstruct.DialogTag=DAStudio.message('Simulink:tools:EditTimeMismatchTitle');
    dlgstruct.LayoutGrid=[2,4];
    dlgstruct.RowStretch=[0,0];
    dlgstruct.ColStretch=[1,1,1,1];
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.IsScrollable=false;
    dlgstruct.Transient=false;
    dlgstruct.DialogStyle='framed';
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.MinimalApply=true;
    dlgstruct.ExplicitShow=true;
    dlgstruct.Items=items;
end

function portSelected(h,~,col,~)
    mismatch=h.getSource.violations;
    if col>0
        blockPath=mismatch.DstMismatches(h.getSource.currentRow).DstBlockPath;
        portIdx=mismatch.DstMismatches(h.getSource.currentRow).DstPortIdx;
        h.getSource().openBlockDlg(blockPath,portIdx+1,'',true);
    else
        blockPath=mismatch.SrcBlockPath;
        portIdx=mismatch.SrcPortIdx;
        h.getSource().openBlockDlg(blockPath,portIdx+1,'',false);
    end
end

function attributeSelected(h,row,col,~)
    mismatch=h.getSource.violations;
    selAttr=mismatch.DstMismatches(h.getSource.currentRow).MismatchList(row).Attribute;
    if col>0
        blockPath=mismatch.DstMismatches(h.getSource.currentRow).DstBlockPath;
        portIdx=mismatch.DstMismatches(h.getSource.currentRow).DstPortIdx;
        h.getSource().openBlockDlg(blockPath,portIdx+1,selAttr,true);
    else
        blockPath=mismatch.SrcBlockPath;
        portIdx=mismatch.SrcPortIdx;
        h.getSource().openBlockDlg(blockPath,portIdx+1,selAttr,false);
    end
end
