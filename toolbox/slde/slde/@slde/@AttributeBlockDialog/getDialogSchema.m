function schema=getDialogSchema(this,varargin)




    if isempty(this.Impl)
        schema=errorDlg(this);
    else
        schema=this.Impl.getDialogSchema();
    end



    function dlgStruct=errorDlg(this)


        blockType=this.getBlock.BlockType;

        txt.Type='text';
        txt.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:ErrorCreatingDialog',blockType);
        txt.WordWrap=true;

        dlgStruct.DialogTitle=des.message('Simulink:dialog:BlockParameters',blockType);
        dlgStruct.Items={txt};
        dlgStruct.CloseMethod='closeCallback';
        dlgStruct.CloseMethodArgs={'%dialog'};
        dlgStruct.CloseMethodArgsDT={'handle'};


