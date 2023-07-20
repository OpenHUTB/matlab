function dlg=transformDataTypeGroup(origDlg)




    dlg=origDlg;



    [slimRootPanel,slimRootPanelIdx]=findItemByTag(dlg.Items,'SlimRootPanel');
    if isempty(slimRootPanel)
        return;
    end


    [tabsContainer,tabsContainerIdx]=findItemByTag(slimRootPanel.Items,'TabsContainer');
    if isempty(tabsContainer)
        return;
    end


    [dataTypesTab,dataTypesTabIdx]=findItemByTag(tabsContainer.Items,'DataTypesTab');
    if isempty(dataTypesTab)
        return;
    end


    fixptOperationItem=[];
    fixptTextItem=[];
    typesPanelItem=[];
    additionalTextItems=[];
    lockScaleItem=[];
    outputDataTypeItem=[];
    for i=1:numel(dataTypesTab.Items)
        item=dataTypesTab.Items{i};
        if isWidgetHidden(item)

            continue;
        elseif isfield(item,'Tag')&&strcmp(item.Tag,'FixPtOpParamsGroupBox')
            fixptOperationItem=item;
        elseif isfield(item,'Tag')&&strcmp(item.Tag,'FixPtBlurbTextLabel')
            fixptTextItem=item;
        elseif isfield(item,'Tag')&&strcmp(item.Tag,'TypesTablePanel')
            typesPanelItem=item;
        elseif strcmp(item.Type,'text')&&~isfield(item,'Buddy')


            additionalTextItems{end+1}=item;
        elseif isfield(item,'WidgetId')&&strcmp(item.WidgetId,'Simulink.Builtin.LockScale')
            lockScaleItem=item;
        elseif strcmp(item.Type,'combobox')&&...
            isfield(item,'WidgetId')&&...
            startsWith(item.WidgetId,'Simulink.Builtin.')


            outputDataTypeItem.dropDown=item;
            outputDataTypeItem.label=dataTypesTab.Items{i-1};
        end
    end


    if~isempty(fixptOperationItem)
        numRowsReduced=0;
        for i=1:numel(fixptOperationItem.Items)
            type=fixptOperationItem.Items{i}.Type;
            if strcmp(type,'text')
                tag=string(fixptOperationItem.Items{i}.Tag);
                visible=fixptOperationItem.Items{i}.Visible;
                if tag.endsWith("ModeValue")&&visible==1


                    fixptOperationItem.Items{i-1}.ColSpan=[1,1];
                    fixptOperationItem.Items{i}.ColSpan=[2,2];
                    row=fixptOperationItem.Items{i-1}.RowSpan(1)-numRowsReduced;
                    fixptOperationItem.Items{i-1}.RowSpan=[row,row];
                    fixptOperationItem.Items{i}.RowSpan=[row,row];

                    numRowsReduced=numRowsReduced+1;
                end
            end
        end

        newRows=fixptOperationItem.LayoutGrid(1)-numRowsReduced;
        fixptOperationItem.LayoutGrid(1)=newRows;
        fixptOperationItem.RowStretch=zeros(1,newRows);
        fixptOperationItem.RowStretch(newRows)=1;
    end


    hiddenItems=[];
    dataTypeItems=[];
    minMaxItems=[];
    if~isempty(typesPanelItem)&&~isWidgetHidden(typesPanelItem)
        origDataTypeItems=typesPanelItem.Items;
        numItems=numel(origDataTypeItems);
        for i=1:numItems
            item=origDataTypeItems{i};
            if isfield(item,'Visible')&&item.Visible==0

                hiddenItems{end+1}=item;
            else

                type=item.Type;
                tag=string(item.Tag);
                if tag.endsWith("|DataTypePanel")&&isfield(item,'WidgetId')

                    wid=item.WidgetId;

                    aDataTypeLabel=origDataTypeItems{i-1};

                    aDataTypeLabel.ToolTip="<p><strong>"+extractAfter(wid,'Simulink.Builtin.')+"</strong></p>";
                    aDataTypeLabel.ColSpan=[1,1];
                    aDataTypeItem.label=aDataTypeLabel;

                    aDataTypeItem.widget=item;
                    dataTypeItems{end+1}=aDataTypeItem;%#ok<*AGROW>


                    if i+2<=numItems
                        if strcmp(origDataTypeItems{i+1}.Type,'edit')&&...
                            ~isWidgetHidden(origDataTypeItems{i+1})&&...
                            strcmp(origDataTypeItems{i+2}.Type,'edit')&&...
                            ~isWidgetHidden(origDataTypeItems{i+2})

                            aMinMaxItem.label=aDataTypeLabel;
                            aMinMaxItem.label.ToolTip='';

                            aMinMaxItem.min=origDataTypeItems{i+1};
                            aMinMaxItem.max=origDataTypeItems{i+2};
                            minMaxItems{end+1}=aMinMaxItem;
                        end
                    end
                elseif tag.endsWith("UDTStrValue")&&strcmp(type,'text')


                    aDataTypeLabel=origDataTypeItems{i-1};
                    aDataTypeLabel.ColSpan=[1,1];
                    aDataTypeItem.label=aDataTypeLabel;
                    item.ColSpan=[2,2];
                    aDataTypeItem.widget=item;
                    dataTypeItems{end+1}=aDataTypeItem;

                end
            end
        end
    end



    if~isempty(dataTypeItems)
        numDataTypes=numel(dataTypeItems);
        typesPanelItem.Items=cell(1,numDataTypes*2);
        for i=1:numDataTypes

            aLabel=dataTypeItems{i}.label;
            aLabel.RowSpan=[i,i];
            typesPanelItem.Items{2*i-1}=aLabel;

            aDTW=dataTypeItems{i}.widget;
            aDTW.RowSpan=[i,i];
            typesPanelItem.Items{2*i}=aDTW;
        end
        typesPanelItem.LayoutGrid=[numDataTypes,2];
    end


    if~isempty(minMaxItems)
        numMinMaxItems=numel(minMaxItems);

        minMaxPanelIndex=dataTypesTabIdx+1;
        minMaxPanel.Type='togglepanel';
        minMaxPanel.Name='Min/Max Values';
        minMaxPanel.Tag='MinMaxPanel';
        minMaxPanel.ColSpan=[1,2];
        minMaxPanel.LayoutGrid=[2*numMinMaxItems,2];
        minMaxPanel.ColStretch=[1,1];
        minMaxPanel.Visible=1;
        minMaxPanel.Enabled=1;
        minMaxPanel.RowSpan=[minMaxPanelIndex,minMaxPanelIndex];
        minMaxPanel.Expand=0;

        minMaxPanelItems=cell(1,3*numMinMaxItems);
        for i=1:numel(minMaxItems)

            labelIndex=3*i-2;
            minMaxPanelItems{labelIndex}=minMaxItems{i}.label;
            minMaxPanelItems{labelIndex}.RowSpan=[labelIndex,labelIndex];
            minMaxPanelItems{labelIndex}.ColSpan=[1,2];

            minIndex=labelIndex+1;
            minMaxPanelItems{minIndex}=minMaxItems{i}.min;
            minMaxPanelItems{minIndex}.RowSpan=[minIndex,minIndex];

            maxIndex=minIndex+1;
            minMaxPanelItems{maxIndex}=minMaxItems{i}.max;
            minMaxPanelItems{maxIndex}.RowSpan=[minIndex,minIndex];
        end
        minMaxPanel.Items=minMaxPanelItems;















    end


    rowCount=0;
    dlg.Items{slimRootPanelIdx}.Items{tabsContainerIdx}.Items{dataTypesTabIdx}.Items=[];

    if~isempty(outputDataTypeItem)
        rowCount=rowCount+1;
        outputDataTypeItem.label.RowSpan=[rowCount,rowCount];
        outputDataTypeItem.dropDown.RowSpan=[rowCount,rowCount];
        dlg.Items{slimRootPanelIdx}.Items{tabsContainerIdx}.Items{dataTypesTabIdx}.Items{end+1}=outputDataTypeItem.label;
        dlg.Items{slimRootPanelIdx}.Items{tabsContainerIdx}.Items{dataTypesTabIdx}.Items{end+1}=outputDataTypeItem.dropDown;
    end


    if~isempty(fixptOperationItem)
        rowCount=rowCount+1;
        fixptOperationItem.RowSpan=[rowCount,rowCount];
        dlg.Items{slimRootPanelIdx}.Items{tabsContainerIdx}.Items{dataTypesTabIdx}.Items{end+1}=fixptOperationItem;
    end

    if~isempty(fixptTextItem)

        rowCount=rowCount+1;fixptTextItem.RowSpan=[rowCount,rowCount];
        dlg.Items{slimRootPanelIdx}.Items{tabsContainerIdx}.Items{dataTypesTabIdx}.Items{end+1}=fixptTextItem;
    end

    if~isempty(typesPanelItem)
        rowCount=rowCount+1;
        typesPanelItem.RowSpan=[rowCount,rowCount];
        dlg.Items{slimRootPanelIdx}.Items{tabsContainerIdx}.Items{dataTypesTabIdx}.Items{end+1}=typesPanelItem;
    end

    if~isempty(minMaxItems)
        rowCount=rowCount+1;
        minMaxPanel.RowSpan=[rowCount,rowCount];
        dlg.Items{slimRootPanelIdx}.Items{tabsContainerIdx}.Items{dataTypesTabIdx}.Items{end+1}=minMaxPanel;
    end

    if~isempty(lockScaleItem)
        rowCount=rowCount+1;
        lockScaleItem.RowSpan=[rowCount,rowCount];
        dlg.Items{slimRootPanelIdx}.Items{tabsContainerIdx}.Items{dataTypesTabIdx}.Items{end+1}=lockScaleItem;
    end

    for i=1:numel(additionalTextItems)
        aTextItem=additionalTextItems{i};
        rowCount=rowCount+1;
        aTextItem.RowSpan=[rowCount,rowCount];
        dlg.Items{slimRootPanelIdx}.Items{tabsContainerIdx}.Items{dataTypesTabIdx}.Items{end+1}=aTextItem;
    end

    if rowCount>0

        dlg.Items{slimRootPanelIdx}.Items{tabsContainerIdx}.Items{dataTypesTabIdx}.LayoutGrid=[rowCount,2];
    end

end

function[item,index]=findItemByTag(items,tag)


    item=[];
    index=0;
    for i=1:numel(items)
        if isfield(items{i},'Tag')&&strcmp(items{i}.Tag,tag)
            item=items{i};
            index=i;
            break;
        end
    end

end

function tf=isWidgetHidden(widget)


    tf=isfield(widget,'Visible')&&widget.Visible==0;

end
