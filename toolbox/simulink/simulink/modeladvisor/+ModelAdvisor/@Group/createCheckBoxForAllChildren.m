


function[checkboxArray,masterSelectAll,totalRows]=createCheckBoxForAllChildren(this,startRow)

    checkboxArray={};
    masterSelectAll=true;
    totalRows=0;
    currentRow=startRow;

    for i=1:length(this.ChildrenObj)
        curChildren=this.ChildrenObj{i};
        if strcmp(curChildren.Type,'Container')

            if strcmp(this.CheckBoxMode,'All')
                [childcheckboxArray,childmasterSelectAll,childtotalRows]=loc_createCheckBoxForAllChildren(curChildren,currentRow);
            elseif strcmp(this.CheckBoxMode,'Direct')
                checkbox.Type='checkbox';
                checkbox.Name=curChildren.DisplayName;
                checkbox.ToolTip=curChildren.Description;
                checkbox.RowSpan=[currentRow,currentRow];
                checkbox.ColSpan=[2,10];
                checkbox.Enabled=curChildren.Enable;
                checkbox.Value=curChildren.Selected;
                checkbox.Tag=['CheckBox_',num2str(curChildren.Index)];



                checkbox.MatlabMethod='handleCheckEvent';
                checkbox.MatlabArgs={this,'%tag','%dialog'};
                checkbox.DialogRefresh=true;

                childcheckboxArray={checkbox};
                childmasterSelectAll=checkbox.Value;
                childtotalRows=1;
            end
            checkboxArray=[checkboxArray,childcheckboxArray];%#ok<AGROW>
            masterSelectAll=masterSelectAll&&childmasterSelectAll;
            currentRow=currentRow+childtotalRows;
            totalRows=totalRows+childtotalRows;
        elseif strcmp(curChildren.Type,'Task')
            checkbox.Type='checkbox';
            checkbox.Name=curChildren.DisplayName;
            checkbox.ToolTip=curChildren.Description;
            checkbox.RowSpan=[currentRow,currentRow];
            checkbox.ColSpan=[2,10];
            checkbox.Enabled=curChildren.Enable;
            checkbox.Value=curChildren.Selected;
            if~curChildren.Selected
                masterSelectAll=false;
            end
            checkbox.Tag=['CheckBox_',num2str(curChildren.Index)];



            checkbox.MatlabMethod='handleCheckEvent';
            checkbox.MatlabArgs={this,'%tag','%dialog'};
            checkbox.DialogRefresh=true;
            checkboxArray{end+1}=checkbox;%#ok<AGROW>
            currentRow=currentRow+1;
            totalRows=totalRows+1;
        end
    end