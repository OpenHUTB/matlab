function dlg=getSlimDialogSchema(source,~)





    source.paramsMap=source.getDialogParams;
    source.isSlimDialog=true;


    items=source.buildParameterGroup();
    numRow=numel(items{1}.Items);



    dlg.DialogTitle='';
    dlg.DialogTag='SubSystem';
    dlg.DialogMode='Slim';
    dlg.DialogRefresh=false;





    dlg.Items=items;
    dlg.LayoutGrid=[numRow,1];
    dlg.RowStretch=[zeros(1,numRow-1),1];

    dlg.CloseMethod='closeCallback';
    dlg.CloseMethodArgs={'%dialog'};
    dlg.CloseMethodArgsDT={'handle'};

    dlg.StandaloneButtonSet={''};
    dlg.EmbeddedButtonSet={''};
    dlg.DialogCSHTag='';







end
