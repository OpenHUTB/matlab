function bottomPan=getBottomPanSchema(h,sums,csum)

    pButton.Type='pushbutton';

    pButton.Name=['&',DAStudio.message('configset:util:PropagateButton')];
    pButton.Tag='PB';
    pButton.ObjectMethod='propagateCallback';
    pButton.RowSpan=[1,1];
    pButton.ColSpan=[1,1];
    pButton.Enabled=(sums>0);

    pauseB.Type='pushbutton';
    pauseB.Name=[DAStudio.message('configset:util:Pause'),'(&s)'];
    pauseB.Tag='pauseButton';
    pauseB.Enabled=false;

    pauseB.ObjectMethod='pause';
    pauseB.RowSpan=[1,1];
    pauseB.ColSpan=[2,2];

    stopB.Type='pushbutton';
    stopB.Name=DAStudio.message('configset:util:Stop');
    stopB.Tag='stopButton';
    stopB.Enabled=false;

    stopB.ObjectMethod='stop';
    stopB.RowSpan=[1,1];
    stopB.ColSpan=[3,3];
    stopB.Italic=true;

    rButton.Type='pushbutton';

    rButton.Name=['&',DAStudio.message('configset:util:RestoreButton')];
    rButton.Tag='RB';
    rButton.ObjectMethod='restoreCallback';
    rButton.RowSpan=[1,1];
    rButton.ColSpan=[3,3];
    rButton.Enabled=h.IsPropagated&&(csum>0);

    controlPan.Type='panel';
    controlPan.Tag='controlPan';
    controlPan.Visible=true;
    controlPan.LayoutGrid=[1,3];
    controlPan.RowSpan=[1,1];
    controlPan.ColSpan=[1,1];
    controlPan.Items={pButton,pauseB,rButton};



    space1.Type='text';
    space1.Name='             ';
    space1.RowSpan=[1,1];
    space1.ColSpan=[4,4];

    hButton.Type='pushbutton';

    hButton.Name=['&',DAStudio.message('configset:util:HelpButton')];
    hButton.Tag='HB';
    hButton.ObjectMethod='helpCallback';
    hButton.RowSpan=[1,1];
    hButton.ColSpan=[5,5];

    cButton.Type='pushbutton';

    cButton.Name=['&',DAStudio.message('configset:util:OK')];
    cButton.Tag='CB';
    cButton.ObjectMethod='saveAndClose';
    cButton.RowSpan=[1,1];
    cButton.ColSpan=[6,6];














    bottomPan.Type='panel';
    bottomPan.Tag='Buttons';
    bottomPan.LayoutGrid=[1,6];

    bottomPan.Items={pButton,pauseB,rButton,space1,hButton,cButton};
