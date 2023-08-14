function widget=CreateTableOperationsWidget(this,buttonSize)






    widget.Type='panel';
    widget.Tag=[this.TableName,'.TableOperations'];
    widget.LayoutGrid=[5,1];
    widget.RowStretch=[0,0,0,0,1];










    button='AddRow';
    addButton=l_CreateButtonWidget(this.AddRowTag,button,l_GetUIString(button),buttonSize);
    button='DeleteRow';
    deleteButton=l_CreateButtonWidget(this.DeleteRowTag,button,l_GetUIString(button),buttonSize);
    button='MoveRowUp';
    moveUpButton=l_CreateButtonWidget(this.MoveRowUpTag,button,l_GetUIString(button),buttonSize);
    button='MoveRowDown';
    moveDownButton=l_CreateButtonWidget(this.MoveRowDownTag,button,l_GetUIString(button),buttonSize);

    addButton.RowSpan=[1,1];
    deleteButton.RowSpan=[2,2];
    moveUpButton.RowSpan=[3,3];
    moveDownButton.RowSpan=[4,4];



    opsEns=this.GetTableOperationsEnables;

    addButton.Enabled=opsEns.AddRow;
    deleteButton.Enabled=opsEns.DeleteRow;
    moveUpButton.Enabled=opsEns.MoveRowUp;
    moveDownButton.Enabled=opsEns.MoveRowDown;



    tOpSpacer2.Type='panel';
    tOpSpacer2.RowSpan=[5,5];


    widget.Items={addButton,deleteButton,moveUpButton,moveDownButton,tOpSpacer2};
    widget.Source=this;

end


function widget=l_CreateButtonWidget(tag,methodName,buttonLabel,buttonSize)
    widget.Type='pushbutton';
    widget.Tag=tag;
    widget.Name=buttonLabel;
    widget.MinimumSize=buttonSize;
    widget.Alignment=1;
    widget.ObjectMethod=methodName;
    widget.MethodArgs={'%dialog'};
    widget.ArgDataTypes={'handle'};
    widget.DialogRefresh=1;
end

function str=l_GetUIString(key)
    postfix='Button_Name';
    str=DAStudio.message(['EDALink:FPGAUI:',key,postfix]);
end
