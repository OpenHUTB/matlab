function dlgStruct=cosimportddg(source,h)


    switch h.BlockType
    case 'ObserverPort'
        blkTypeMsgStr=DAStudio.message('Simulink:SltBlkMap:ObserverPort');
        dialogTag='_Observer_Port_Block_Tag_';
        helpPath='observer_port_block_ref';
    case 'InjectorInport'
        blkTypeMsgStr=DAStudio.message('Simulink:SltBlkMap:InjectorInport');
        dialogTag='_Injector_Inport_Block_Tag_';
        helpPath='injector_inport_block_ref';
    case 'InjectorOutport'
        blkTypeMsgStr=DAStudio.message('Simulink:SltBlkMap:InjectorOutport');
        dialogTag='_Injector_Outport_Block_Tag_';
        helpPath='injector_outport_block_ref';
    end


    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];


    cosimPrtTag.Type='text';
    cosimPrtTag.Name=DAStudio.message('Simulink:SltBlkMap:ConfigureCoSimPortBlock',blkTypeMsgStr,h.getFullName);
    cosimPrtTag.Tag='configureObsPortTag';
    cosimPrtTag.RowSpan=[0,1];
    cosimPrtTag.ColSpan=[1,1];

    paramGrp.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
    paramGrp.Type='group';
    paramGrp.Items={cosimPrtTag};
    paramGrp.RowSpan=[2,1];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;






    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',strrep(h.Name,newline,' ')));
    dlgStruct.StandaloneButtonSet={'Cancel','Help'};
    dlgStruct.DialogTag=dialogTag;
    dlgStruct.Items={descGrp,paramGrp};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];


    dlgStruct.HelpMethod='helpview';
    dlgStruct.HelpArgs={[docroot,'/sltest/helptargets.map'],helpPath};


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

end
