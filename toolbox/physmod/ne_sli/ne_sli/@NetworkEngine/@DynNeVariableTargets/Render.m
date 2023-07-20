function[retVal,schema]=Render(hThis,~)












    vars=hThis.DefaultTargets;
    nVars=numel(vars);

    [retVal,allChildren]=renderChildren(hThis);
    allChildren=reshape(allChildren,[],nVars)';
    items=cellfun(@(item)item.Items{1},allChildren,'UniformOutput',false);
    params=cellfun(@(item)item.Source.ValueBlkParam,items,'UniformOutput',false);
    itemMap=containers.Map(params,items);

    columns={'Specify','Variable','Priority','Value','Unit'};
    iCol=lIndexStruct(columns);


    hdrTable=lMakeHeader(iCol,hThis.ObjId);
    hdrTable=lArrangeItems(hdrTable,0,0);


    itemTable=lMakeItemTable(iCol,vars,itemMap,hThis.ObjId);
    itemTable=lArrangeItems(itemTable,1,0);


    iPriority=find(strcmp(columns,'Priority'));
    iValue=find(strcmp(columns,'Value'));
    iUnit=find(strcmp(columns,'Unit'));
    iDefCol=lIndexStruct(columns([iPriority,iValue,iUnit]));
    defaultTable=lMakeDefaultTable(iDefCol,...
    itemTable(:,[iPriority,iValue,iUnit]),vars,hThis);

    basePanel.Name='';
    basePanel.Type='panel';
    basePanel.Tag=hThis.ObjId;
    basePanel.LayoutGrid=[nVars+1,numel(columns)];
    basePanel.RowSpan=[1,1];
    basePanel.ColSpan=[1,1];
    basePanel.ColStretch=zeros(numel(columns));
    basePanel.ColStretch(iCol.Value)=1;
    basePanel.Items=[hdrTable(:)',itemTable(:)',defaultTable(:)'];

    schema=basePanel;
end

function itemTable=lArrangeItems(itemTable,rowOffset,colOffset)
    for iRow=1:size(itemTable,1)
        rowSpan=[iRow,iRow]+rowOffset;
        for iCol=1:size(itemTable,2)
            itemTable{iRow,iCol}.ColSpan=[iCol,iCol]+colOffset;
            itemTable{iRow,iCol}.RowSpan=rowSpan;
        end
    end
end

function msg=lMessageFcn()
    msgBase='physmod:ne_sli:dialog:';
    msg=@(key)getString(message([msgBase,key]));
end

function itemTable=lMakeHeader(iCol,baseTag)
    headerBuffer='  ';
    lookupKey=lMessageFcn();
    msg=@(key)[lookupKey(key),headerBuffer];
    cols={{'specify',msg('VariableOverrideHeader'),msg('VariableOverrideHeaderToolTip')}
    {'variable',msg('VariableNameHeader'),msg('VariableNameHeaderToolTip')}
    {'priority',msg('VariablePriorityHeader'),msg('VariablePriorityHeaderToolTip')}
    {'value',msg('VariableValueHeader'),msg('VariableValueHeaderToolTip')}
    {'unit',msg('VariableUnitHeader'),msg('VariableUnitHeaderToolTip')}
    }';

    hdrItems=cellfun(@(col)lTextItem(...
    [baseTag,'._',col{1},'.Header'],col{2},...
    col{3},true),cols,'UniformOutput',false);


    itemTable(1,[iCol.Specify,iCol.Variable,iCol.Priority,iCol.Value,iCol.Unit])=hdrItems;
end

function tt=lItemToolTip(baseLabel,typeKey,baseId,suffix)
    msg=lMessageFcn();
    type=msg(typeKey);
    tt=sprintf('<html>%s: %s<br><b>%s%s</b></html>',baseLabel,type,baseId,suffix);
end

function itemTable=lMakeItemTable(iCol,vars,itemMap,baseTag)
    nVars=numel(vars);
    itemTable=cell(nVars,5);
    for iVar=1:nVars
        var=vars(iVar);
        id=var.ID;
        baseLabel=var.Label;
        spec=itemMap([id,'_specify']);
        override=logical(spec.Value);
        spec.ToolTip=lItemToolTip(baseLabel,'VariableOverrideHeader',id,'_specify');
        itemTable{iVar,iCol.Specify}=spec;
        itemTable{iVar,iCol.Variable}=lTextItem([baseTag,'.',id,'_label.Text'],baseLabel,'',false);

        pri=itemMap([id,'_priority']);
        pri.Visible=override;
        itemTable{iVar,iCol.Priority}=pri;

        val=itemMap(id);
        val.Visible=override;
        itemTable{iVar,iCol.Value}=val;

        unit=itemMap([id,'_unit']);
        unit.Visible=override;
        itemTable{iVar,iCol.Unit}=unit;
    end
end

function defTable=lMakeDefaultTable(iDefCol,defTable,vars,src)
    assert(size(defTable,1)==numel(vars));
    msg=lMessageFcn();
    ttfcn=@(baseLabel,typeKey)[baseLabel,': ',msg(typeKey)];
    for iRow=1:size(defTable,1)
        var=vars(iRow);
        baseLabel=var.Label;
        defTable{iRow,iDefCol.Priority}.Value=find(strcmp(var.Default.Priority,{'High','Low','None'}))-1;
        defTable{iRow,iDefCol.Value}.Value=var.Default.Value.Value;
        defTable{iRow,iDefCol.Unit}.Value=var.Default.Value.Unit;
        defTable{iRow,iDefCol.Priority}.ToolTip=ttfcn(baseLabel,'DefaultPriority');
        defTable{iRow,iDefCol.Value}.ToolTip=ttfcn(baseLabel,'DefaultValue');
        defTable{iRow,iDefCol.Unit}.ToolTip=ttfcn(baseLabel,'DefaultUnit');
        paramSuffix={'_priority','','_unit'};
        for iCol=1:size(defTable,2)
            item=defTable{iRow,iCol};
            item.Visible=~item.Visible;
            item.Tag=[item.Tag,'_default'];
            item.Source=src;
            item.ObjectMethod='targetChangedCallback';
            item.MethodArgs={'%dialog','%tag','%value'};
            item.ArgDataTypes={'handle','string','mxArray'};
            item.ObjectProperty='';
            item.UserData=struct('SpecifyParameter',{[var.ID,'_specify']},...
            'BlockParameter',{[var.ID,paramSuffix{iCol}]},...
            'BaseParam',var.ID,...
            'DefaultValue',{item.Value});
            defTable{iRow,iCol}=item;
        end
    end
end

function item=lTextItem(tag,name,tooltip,isBold)
    item=struct('Name',{name},...
    'Tag',{tag},...
    'ToolTip',{tooltip},...
    'Type',{'text'},...
    'Bold',{isBold});
end

function s=lIndexStruct(fieldNames)
    for idx=1:numel(fieldNames)
        s.(fieldNames{idx})=idx;
    end
end
