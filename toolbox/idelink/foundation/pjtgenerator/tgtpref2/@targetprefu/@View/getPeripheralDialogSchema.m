function dlgstruct=getPeripheralDialogSchema(hView,Data,name)%#ok<INUSD>



    tagprefix='TargetPrefPeripherals_';


    tagssofar={'Dummy'};

    PeripheralHints=hView.mController.getPeripheralHints(tagprefix);

    peripheralNames=Data.getPeripheralNames();
    PeripheralMapStack.Type='widgetstack';
    PeripheralMapStack.Tag=[tagprefix,'PeripheralMapStack'];
    PeripheralMapStack.ActiveWidget=0;
    PeripheralMapStack.Items=cell(1,numel(PeripheralHints));
    PeripheralMapStack.RowSpan=[2,6];
    PeripheralMapStack.ColSpan=[4,6];
    for i=1:numel(PeripheralHints)
        PeripheralDetail=PeripheralHints{i};
        PeripheralMapPanel.Type='panel';
        PeripheralMapPanel.Items=cell(1,numel(PeripheralDetail)+1);
        for j=1:numel(PeripheralDetail)
            WidgetHint=PeripheralDetail{j};
            found=strmatch(WidgetHint.Tag,tagssofar,'exact');
            assert(isempty(found),'Have %s already',WidgetHint.Tag);
            tagssofar{end+1}=WidgetHint.Tag;
            PeripheralWidget=hView.getPeripheralWidgetFor(WidgetHint,i,j);
            PeripheralWidget.ListenToProperties={'mPeripheralPanel'};
            PeripheralMapPanel.Items{j}=PeripheralWidget;
        end
        spacer.Type='panel';
        spacer.RowSpan=[numel(PeripheralDetail)+1,numel(PeripheralDetail)+1];
        PeripheralMapPanel.Items{end}=spacer;
        PeripheralMapPanel.LayoutGrid=[numel(PeripheralDetail)+1,5];
        PeripheralMapPanel.RowStretch=[zeros(1,numel(PeripheralDetail)),1];
        PeripheralMapPanel.ColStretch=[0,0,1,0,0];
        PeripheralMapStack.Items{i}=PeripheralMapPanel;
    end

    PeripheralMap.Name=Data.getCurChipName();
    PeripheralMap.Type='tree';
    PeripheralMap.TreeItems=peripheralNames;
    PeripheralMap.TreeItemIds=num2cell(0:length(PeripheralMap.TreeItems)-1);
    PeripheralMap.Tag=[tagprefix,'PeripheralMap'];
    PeripheralMap.TargetWidget=[tagprefix,'PeripheralMapStack'];
    if(~isempty(peripheralNames))
        PeripheralMap.Value=PeripheralMap.TreeItems{1};
    end
    PeripheralMap.RowSpan=[2,6];
    PeripheralMap.ColSpan=[1,3];
    PeripheralMap.Graphical=true;
    PeripheralMap.MinimumSize=[128,128];

    PeripheralsSchemaItems.Type='panel';
    PeripheralsSchemaItems.Tag=[tagprefix,'panel'];
    PeripheralsSchemaItems.Items={PeripheralMap,PeripheralMapStack};
    PeripheralsSchemaItems.LayoutGrid=[3,9];

    dlgstruct.Name='Peripherals';
    dlgstruct.Items={PeripheralsSchemaItems};

