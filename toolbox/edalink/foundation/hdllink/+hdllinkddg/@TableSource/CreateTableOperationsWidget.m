function widget=CreateTableOperationsWidget(this)




    widget.Type='panel';
    widget.Tag=[this.TableName,'.TableOperations'];
    widget.LayoutGrid=[6,1];
    widget.RowStretch=[0,0,0,0,0,1];


    tOpSpacer1.Type='text';
    tOpSpacer1.RowSpan=[1,1];

    tOpSpacer1.MinimumSize=[0,50];


    addButton=l_CreateButtonWidget(this.AddRowTag,'AddRow','New');
    deleteButton=l_CreateButtonWidget(this.DeleteRowTag,'DeleteRow','Delete');
    moveUpButton=l_CreateButtonWidget(this.MoveRowUpTag,'MoveRowUp','Up');
    moveDownButton=l_CreateButtonWidget(this.MoveRowDownTag,'MoveRowDown','Down');

    addButton.RowSpan=[2,2];
    deleteButton.RowSpan=[3,3];
    moveUpButton.RowSpan=[4,4];
    moveDownButton.RowSpan=[5,5];



    opsEns=this.GetTableOperationsEnables;

    addButton.Enabled=opsEns.AddRow;
    deleteButton.Enabled=opsEns.DeleteRow;
    moveUpButton.Enabled=opsEns.MoveRowUp;
    moveDownButton.Enabled=opsEns.MoveRowDown;


    tOpSpacer2.Type='panel';
    tOpSpacer2.RowSpan=[6,6];


    widget.Items={tOpSpacer1,addButton,deleteButton,moveUpButton,moveDownButton,tOpSpacer2};
    widget.Source=this;

end

function widget=l_CreateButtonWidget(tag,methodName,buttonLabel)
    widget.Type='pushbutton';
    widget.Tag=tag;
    widget.Name=buttonLabel;
    widget.ObjectMethod=methodName;
    widget.MethodArgs={'%dialog'};
    widget.ArgDataTypes={'handle'};
    widget.DialogRefresh=1;
end
