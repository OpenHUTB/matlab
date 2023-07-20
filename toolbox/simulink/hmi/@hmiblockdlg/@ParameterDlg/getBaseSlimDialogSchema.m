

function dlg=getBaseSlimDialogSchema(obj)



    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');
    utils.rebindWidgetForDlg(obj);
    boundElem=utils.getBoundElement(model,obj.widgetId,obj.isLibWidget,getfullname(blockHandle));

    connectedStr=DAStudio.message('SimulinkHMI:dialogs:BindingConnectedString');
    unconnectedStr=DAStudio.message('SimulinkHMI:dialogs:BindingUnconnectedString');
    connectionBrokenStr=DAStudio.message('SimulinkHMI:errors:ConnectionNotFound');
    changeLinkStr=['(',DAStudio.message('SimulinkHMI:dialogs:BindingChangeLinkString'),')'];
    connectLinkStr=['(',DAStudio.message('SimulinkHMI:dialogs:BindingConnectLinkString'),')'];


    bindingTableCol1.Type='text';
    bindingTableCol1.Tag='bindingTableCol1';
    bindingTableCol1.RowSpan=[1,1];
    bindingTableCol1.ColSpan=[1,3];
    bindingTableCol1.Name=connectedStr;

    bindingTableCol2.Type='hyperlink';
    bindingTableCol2.Tag='bindingTableCol2';
    bindingTableCol2.RowSpan=[1,1];
    bindingTableCol2.ColSpan=[4,4];

    bindingTableCol3.Type='hyperlink';
    bindingTableCol3.Tag='bindingTableCol3';
    bindingTableCol3.RowSpan=[1,1];
    bindingTableCol3.ColSpan=[5,5];
    bindingTableCol3.MatlabMethod='utils.showBindingUI';
    bindingTableCol3.MatlabArgs={blockHandle};

    if~isempty(boundElem)
        if utils.isValidBinding(boundElem)
            sourceBlk=boundElem.BlockPath.getBlock(1);
            [blockName,tunableParam]=locGetParamName(boundElem);
            bindingTableCol2.MatlabMethod='utils.highlightParameterInModel';
            bindingTableCol2.MatlabArgs={model,sourceBlk};
            bindingTableCol2.Name=[blockName,':',tunableParam];
            bindingTableCol3.Name=changeLinkStr;
        else
            bindingTableCol2.Type='text';
            bindingTableCol2.Name=connectionBrokenStr;
            bindingTableCol3.Name=connectLinkStr;
        end
    else
        bindingTableCol2.Type='text';
        bindingTableCol2.Name=unconnectedStr;
        bindingTableCol3.Name=connectLinkStr;
    end


    dlg.Items={bindingTableCol1,bindingTableCol2,bindingTableCol3};
    dlg.DialogTitle='';
    dlg.DialogMode='Slim';
    dlg.DialogRefresh=false;
    dlg.StandaloneButtonSet={''};
    dlg.EmbeddedButtonSet={''};

    dlg.CloseMethod='closeDialogCB';
    dlg.CloseMethodArgs={'%dialog','%closeaction'};
    dlg.CloseMethodArgsDT={'handle','string'};
end

function[blockName,paramName]=locGetParamName(bindable)
    max_label_width=27;
    blk=bindable.BlockPath.getBlock(1);
    blockName=get_param(blk,'Name');
    if isempty(bindable.WksType)
        paramName=bindable.ParamName;
    else
        paramName=bindable.VarName;
    end
    paramName=strcat(paramName,bindable.Element_);
    if(length(blockName)+length(paramName))>max_label_width
        tempStr=extractBefore(blockName,10);
        if length(tempStr)+length(paramName)<max_label_width
            blockName=[tempStr,'...'];
        else
            blockName=[tempStr,'...'];
            tempStr=extractBefore(paramName,10);
            paramName=[tempStr,'...'];
        end
    end
end


