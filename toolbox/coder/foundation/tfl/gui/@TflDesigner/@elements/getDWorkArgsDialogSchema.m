function dworkgroup=getDWorkArgsDialogSchema(this)




    dworkallocator=this.getDialogWidget('Tfldesigner_DWorkAllocatorCheck');
    dworkallocator.RowSpan=[1,1];
    dworkallocator.ColSpan=[1,2];


    dworktag=this.getDialogWidget('Tfldesigner_DWorkEntryTag');
    dworktag.RowSpan=[1,1];
    dworktag.ColSpan=[1,2];

    dworkarglist=this.getDialogWidget('Tfldesigner_ActiveDWorkArg');
    dworkarglist.RowSpan=[2,2];
    dworkarglist.ColSpan=[1,1];


    dworkdatatype=this.getDialogWidget('Tfldesigner_DWorkDataType');
    dworkdatatype.RowSpan=[1,1];
    dworkdatatype.ColSpan=[1,1];

    dworkPointerdesc=this.getDialogWidget('Tfldesigner_DWorkPointerDesc');
    dworkPointerdesc.RowSpan=[1,1];
    dworkPointerdesc.ColSpan=[2,2];


    dworkargpropgroup.Name=DAStudio.message('RTW:tfldesigner:DWorkArgPropGroup');
    dworkargpropgroup.Type='group';
    dworkargpropgroup.LayoutGrid=[1,2];
    dworkargpropgroup.RowSpan=[2,2];
    dworkargpropgroup.ColSpan=[2,3];
    dworkargpropgroup.RowStretch=0;
    dworkargpropgroup.ColStretch=[1,1];
    dworkargpropgroup.Items={dworkdatatype,dworkPointerdesc};

    dworkarglistgroup.Name=DAStudio.message('RTW:tfldesigner:DWorkArgListGroup');
    dworkarglistgroup.Type='group';
    dworkarglistgroup.Visible=this.allocatesdwork;
    dworkarglistgroup.LayoutGrid=[1,3];
    dworkarglistgroup.RowSpan=[2,2];
    dworkarglistgroup.ColSpan=[1,2];
    dworkarglistgroup.RowStretch=zeros(1,2);
    dworkarglistgroup.ColStretch=[0,1,1];
    dworkarglistgroup.Items={dworkarglist,dworkargpropgroup,dworktag};


    dworkallocatorentry=this.getDialogWidget('Tfldesigner_DWorkAllocatorEntry');
    dworkallocatorentry.RowSpan=[2,2];
    dworkallocatorentry.ColSpan=[1,2];


    dworkgroup.Name=DAStudio.message('RTW:tfldesigner:DWorkAttributes');
    dworkgroup.Type='group';
    dworkgroup.LayoutGrid=[2,2];
    dworkgroup.Items={dworkallocator,dworkarglistgroup,dworkallocatorentry};


