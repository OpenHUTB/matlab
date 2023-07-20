function g=setTitle(h)

    g.Type='group';
    g.Name=DAStudio.message('configset:util:Description');
    g.LayoutGrid=[2,5];
    g.ColStretch=[0,0,0,0,1];







    item1.Type='text';
    item1.Name=DAStudio.message('configset:util:Description1');
    item1.RowSpan=[1,1];
    item1.ColSpan=[1,1];

    item2.Type='hyperlink';
    item2.Tag='Reference';
    if length(h.CS.Name)>15
        item2.Name=strcat(h.CS.Name(1:12),'...');
    else
        item2.Name=h.CS.Name;
    end
    item2.ObjectMethod='showCS';
    item2.RowSpan=[1,1];
    item2.ColSpan=[2,2];

    item3.Type='text';
    item3.Name=DAStudio.message('configset:util:Description2');
    item3.RowSpan=[1,1];
    item3.ColSpan=[3,3];

    item4.Type='hyperlink';
    item4.Tag='TopModel';
    item4.ToolTip=which(h.TopModel);
    if length(h.TopModel)>15
        item4.Name=strcat(h.TopModel(1:12),'...');
    else
        item4.Name=h.TopModel;
    end
    item4.ObjectMethod='showTopModel';
    item4.RowSpan=[1,1];
    item4.ColSpan=[4,4];

    item5.Type='text';
    item5.Name=DAStudio.message('configset:util:Description3');
    item5.RowSpan=[1,1];
    item5.ColSpan=[5,5];

    item6.Type='text';
    item6.Name=DAStudio.message('configset:util:Description4');
    item6.RowSpan=[2,2];
    item6.ColSpan=[1,5];

    g.Items={item1,item2,item3,item4,item5,item6};

