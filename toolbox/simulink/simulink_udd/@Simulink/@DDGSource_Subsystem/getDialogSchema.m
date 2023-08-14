function dlgStruct=getDialogSchema(this,~)
































    this.paramsMap=this.getDialogParams;
    this.isSlimDialog=false;


    h=this.getBlock;


    try

        [dlgStruct,unknownBlockType]=createNormalDialog(this);
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


function[dlgStruct,unknownBlockFound]=createNormalDialog(source)




    thisBlock=source.getBlock;

    disableWholeDialog=source.isHierarchyReadonly;

    if~disableWholeDialog
        [~,isLocked]=source.isLibraryBlock(thisBlock);
        disableWholeDialog=isLocked;
    end




    [descGrp,unknownBlockFound]=source.buildBlockDescription();





    paramGrp=source.buildParameterGroup();







    dlgStruct.DialogTag='SubSystem';
    dlgStruct.Items={descGrp,paramGrp};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];


    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={thisBlock.Handle,'parameter'};


    dlgStruct.PreApplyMethod='preApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};

    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};
    dlgStruct.CloseArgs={'%dialog'};

    dlgStruct.OpenCallback=@openCallback;

    dlgStruct.DisableDialog=disableWholeDialog;
end

function openCallback(dlg)


    source=dlg.getSource;
    block=source.getBlock;
    if getIsReferenceSubsystem(source,block)
        referencedSubsystem=block.ReferencedSubsystem;
        setSRTabActive=false;
        if strcmp(referencedSubsystem,'<file name>')
            setSRTabActive=true;
        else
            isBlockDiagramLoaded=bdIsLoaded(referencedSubsystem);
            if~isBlockDiagramLoaded
                setSRTabActive=true;
            end
        end
        if setSRTabActive

            dlg.setActiveTab('ParameterTabContainerVar',2);
        end
    end
end
