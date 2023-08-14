

function dlgItemStruct=createDialogSchemaForInputParamBlockTable(this,InputParameterType,UIType,dlgItemStruct,curParam,paramIndex)
    dlgItemStruct.Enabled=true;
    dlgItemStruct.Type='group';
    dlgItemStruct.Flat=true;
    dlgItemStruct.Items={};
    dlgItemStruct.LayoutGrid=[5,4];
    dlgItemStruct.ColStretch=[1,1,1,0];

    tableItem.Name=curParam.Description;
    tableItem.Type='table';
    tableItem.Tag=[dlgItemStruct.Tag,'_table'];
    if strcmp(InputParameterType,'BlockType')
        tableItem.ColHeader={'BlockType','MaskType'};
    else
        tableItem.ColHeader={'BlockType','MaskType','Parameter'};
    end
    tableItem.Size=size(curParam.Value);

    if tableItem.Size(2)==0
        tableItem.Size(2)=numel(tableItem.ColHeader);
    end
    tableData=curParam.Value;
    if strcmp(InputParameterType,'BlockTypeWithParameter')
        for i=1:size(tableData,1)
            currentRowParameter='';
            for j=1:length(tableData{i,3})
                if j>1
                    currentRowParameter=[currentRowParameter,' ',tableData{i,3}{j}];%#ok<AGROW>
                else
                    currentRowParameter=tableData{i,3}{j};
                end
            end
            tableData{i,3}=currentRowParameter;
        end
    end
    tableItem.Data=tableData;
    tableItem.HeaderVisibility=[0,1];
    tableItem.Editable=curParam.Enable;
    tableItem.ColumnStretchable=[1,1,1];
    tableItem.ValueChangedCallback=@tableChanged;
    tableItem.SelectionBehavior='Row';
    tableItem.RowSpan=[1,5];
    tableItem.ColSpan=[1,3];




    dlgItemStruct.Items{end+1}=tableItem;

    addButton.Name=DAStudio.message('ModelAdvisor:engine:Add');
    addButton.Type='pushbutton';
    addButton.Enabled=curParam.Enable;
    addButton.RowSpan=[3,3];
    addButton.ColSpan=[4,4];
    if strcmp(UIType,'MA')
        addButton.MatlabMethod='handleCheckEvent';
        addButton.MatlabArgs={this,'%tag','%dialog'};
    else
        addButton.ObjectMethod='handleCheckEvent';
        addButton.MethodArgs={'%tag','%dialog'};
        addButton.ArgDataTypes={'string','handle'};
    end
    addButton.DialogRefresh=true;
    addButton.Tag=['BlockTypeAddRow_',num2str(paramIndex)];
    dlgItemStruct.Items{end+1}=addButton;

    removeButton.Name=DAStudio.message('ModelAdvisor:engine:Remove');
    removeButton.Type='pushbutton';
    removeButton.RowSpan=[4,4];
    removeButton.ColSpan=[4,4];
    removeButton.Enabled=~isempty(curParam.Value)&&curParam.Enable;
    if strcmp(UIType,'MA')
        removeButton.MatlabMethod='handleCheckEvent';
        removeButton.MatlabArgs={this,'%tag','%dialog'};
    else
        removeButton.ObjectMethod='handleCheckEvent';
        removeButton.MethodArgs={'%tag','%dialog'};
        removeButton.ArgDataTypes={'string','handle'};
    end
    removeButton.DialogRefresh=true;
    removeButton.Tag=['BlockTypeRemoveRow_',num2str(paramIndex)];
    dlgItemStruct.Items{end+1}=removeButton;

    importButton.Name=DAStudio.message('ModelAdvisor:engine:AddFrom');
    importButton.Type='pushbutton';
    importButton.Enabled=curParam.Enable;
    importButton.RowSpan=[5,5];
    importButton.ColSpan=[4,4];
    if strcmp(UIType,'MA')
        importButton.MatlabMethod='handleCheckEvent';
        importButton.MatlabArgs={this,'%tag','%dialog'};
    else
        importButton.ObjectMethod='handleCheckEvent';
        importButton.MethodArgs={'%tag','%dialog'};
        importButton.ArgDataTypes={'string','handle'};
    end
    importButton.DialogRefresh=true;
    importButton.Tag=['BlockTypeImport_',num2str(paramIndex)];
    if strcmp(InputParameterType,'BlockType')
        dlgItemStruct.Items{end+1}=importButton;
    end
end

function tableChanged(dlg,ridx,cidx,value)
    ConfigUIObj=dlg.getSource;
    if isa(ConfigUIObj,'DAStudio.DAObjectProxy')
        ConfigUIObj=Advisor.Utils.convertMCOS(dlg.getSource);
    end
    if isa(ConfigUIObj,'ModelAdvisor.Task')
        ConfigUIObj=ConfigUIObj.Check;
    end


    for i=1:length(ConfigUIObj.InputParameters)
        if ismember(ConfigUIObj.InputParameters{i}.Type,{'BlockType','BlockTypeWithParameter'})
            tableID=['InputParameters_',num2str(i),'_table'];
            if~isempty(dlg.getWidgetSource(tableID))

                if dlg.getSelectedTableRow(tableID)==ridx
                    if strcmp(ConfigUIObj.InputParameters{i}.Type,'BlockTypeWithParameter')&&cidx==2
                        convertedValue={};
                        while~isempty(value)
                            [convertedValue{end+1},value]=strtok(value);
                        end
                        value=convertedValue;
                    end
                    ConfigUIObj.InputParameters{i}.Value{ridx+1,cidx+1}=value;
                end
            end
        end
    end
end