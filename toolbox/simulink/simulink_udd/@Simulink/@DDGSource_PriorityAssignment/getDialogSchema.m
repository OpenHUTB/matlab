function dlgStruct=getDialogSchema(this,~)
































    this.paramsMap=this.getDialogParams;


    h=this.getBlock;


    try

        [dlgStruct,unknownBlockType]=this.priorityAssignmentSubsystemDDG(h);
        if(unknownBlockType)
            dlgStruct=errorDlg(h,['Unknown block type: ',h.BlockType]);
            warning('DDG:SLDialogSource',...
            'Unknown block type in DDGSource %s',mfilename);
        end
    catch e
        dlgStruct=errorDlg(h,e.message);
    end

end




function dlgStruct=errorDlg(h,errMsg)

    txt.Name=['Error occurred when trying to create dialog:',newline...
    ,errMsg];
    txt.Type='text';
    txt.WordWrap=true;

    blockType=h.BlockType;
    if strcmp(h.Mask,'on')
        maskType=h.MaskType;
        if~isempty(maskType)
            blockType=maskType;
        end
        blockType=[blockType,' (mask)'];
    end

    dlgStruct.DialogTitle=DAStudio.message(...
    'Simulink:dialog:BlockParameters',blockType);
    dlgStruct.Items={txt};
    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

end

