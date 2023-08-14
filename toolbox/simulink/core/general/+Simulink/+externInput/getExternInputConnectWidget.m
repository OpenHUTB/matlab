function externalInputPanel=getExternInputConnectWidget(widgetStruct)




    widgetStruct.ColSpan=[2,2];
    widgetStruct.RowSpan=[1,1];
    if isfield(widgetStruct,'NameLocation')
        widgetStruct=rmfield(widgetStruct,'NameLocation');
    end

    inputConnector.Type='pushbutton';
    inputConnector.Tag='externalInput:';
    inputConnector.ColSpan=[1,1];
    inputConnector.RowSpan=[1,1];
    inputConnector.Alignment=1;
    inputConnector.MatlabMethod='Simulink.externInput.cb_launchConnector';
    inputConnector.MatlabArgs={'%dialog'};
    inputConnector.Name=message('Simulink:blkprm_prompts:InpFrmWksConnect').getString;
    inputConnector.ToolTip=message('Simulink:blkprm_prompts:InpFrmWksConnectTip').getString;
    inputConnector.DialogRefresh=true;

    externalInputPanel.Type='panel';
    externalInputPanel.Name='';
    externalInputPanel.LayoutGrid=[1,2];
    externalInputPanel.Tag=[widgetStruct.Tag,'|Panel'];
    externalInputPanel.Items={inputConnector};
    externalInputPanel.RowSpan=[1,1];
    externalInputPanel.ColSpan=[1,1];

