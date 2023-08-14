function dlgstruct=slimblockinfoddg(h,name)



    txtDescription.Type='text';
    txtDescription.Tag='DescriptionTextTag';
    if(h.isMasked)
        if strcmp(h.MaskType,'MWDashboardBlock')
            txtDescription.Name=utils.getLegacyPropertyInspectorTabInfo(h);
        else
            txtDescription.Name=h.MaskDescription;
        end

        maskObj=Simulink.Mask.get(h.Handle);
        descObj=maskObj.getDialogControl('DescTextVar');





        if(~isempty(descObj))
            if isempty(txtDescription.Name)
                txtDescription.Name=descObj.Prompt;
            end
            if strcmp(descObj.Enabled,'off')
                txtDescription.Enabled=false;
            end

            if strcmp(descObj.Visible,'off')
                txtDescription.Visible=false;
            end
        end

    else
        txtDescription.Name=h.BlockDescription;
    end

    try
        msg=message(txtDescription.Name);
        txtDescription.Name=msg.getString;
    catch ME
    end

    txtDescription.WordWrap=true;
    txtDescription.PreferredSize=[200,-1];
    txtDescription.RowSpan=[1,1];


    hasSrcCodeLink=false;
    if blockisa(h,'MATLABSystem')&&h.isMasked


        maskObj=get_param(h.Handle,'MaskObject');
        srcCodeCtrl=maskObj.getDialogControl('SourceCodeLink');



        if~isempty(srcCodeCtrl)&&isempty(maskObj.BaseMask)
            hasSrcCodeLink=true;

            srcLink.Type='hyperlink';
            srcLink.Tag=srcCodeCtrl.Name;
            srcLink.Name=srcCodeCtrl.Prompt;
            srcLink.MatlabMethod='eval';
            srcLink.MatlabArgs={srcCodeCtrl.Callback};
            srcLink.RowSpan=[2,2];
        end
    end



    descriptionName=h.BlockType;
    if(h.isMasked)
        descriptionName=strcat(h.MaskType,' (mask)');
        if(h.isLinked)
            descriptionName=strcat(descriptionName,' (link)');
        end
    end



    if(strcmp(h.BlockType,'PanelWebBlock'))
        descriptionName='';
    end

    grpDescription.Type='group';
    grpDescription.Name=descriptionName;
    if hasSrcCodeLink
        txtDescription.ColSpan=[1,2];
        srcLink.ColSpan=[1,1];
        grpDescription.Items={txtDescription,srcLink};
        grpDescription.LayoutGrid=[2,2];
        grpDescription.ColStretch=[0,1];
    else
        grpDescription.Items={txtDescription};
        grpDescription.LayoutGrid=[1,1];
    end
    grpDescription.RowSpan=[1,1];
    grpDescription.ColSpan=[1,1];


    descriptionEditArea.Type='editarea';
    descriptionEditArea.Tag='Description';
    descriptionEditArea.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
    descriptionEditArea.ToolTip=DAStudio.message('Simulink:dialog:EnterTextHere');
    descriptionEditArea.ObjectProperty='Description';
    descriptionEditArea.MatlabMethod='defaultBlockPropCB_ddg';
    descriptionEditArea.MatlabArgs={'%dialog','%source','%tag','%value'};
    descriptionEditArea.PreferredSize=[200,150];
    descriptionEditArea.RowSpan=[2,2];
    descriptionEditArea.ColSpan=[1,1];


    spacer.Type='panel';
    spacer.RowSpan=[3,4];
    spacer.ColSpan=[1,1];




    if slreq.utils.isInPerspective(h.Handle)

        linkInfoPanel=slreq.gui.slimInfoDDG(h.Handle);
        linkInfoPanel.RowSpan=[3,3];
        linkInfoPanel.ColSpan=[1,1];
        spacer.RowSpan=[4,4];
    else
        linkInfoPanel=struct('Type','panel');
    end




    dlgstruct.DialogTitle='';
    dlgstruct.DialogTag=name;
    dlgstruct.DialogMode='Slim';
    dlgstruct.Items={grpDescription,descriptionEditArea,linkInfoPanel,spacer};
    dlgstruct.LayoutGrid=[4,1];
    dlgstruct.RowStretch=[0,0,0,1];
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.EmbeddedButtonSet={''};
    if disableDialog(h.Handle)
        dlgstruct.DisableDialog=true;
    end
end

function val=disableDialog(blkHdl)
    val=false;
    readOnly=strcmp(get_param(bdroot(blkHdl),'Lock'),'on')||...
    strcmp(get_param(blkHdl,'StaticLinkStatus'),'implicit')||...
    Simulink.harness.internal.isActiveHarnessLockedCUT(blkHdl);
    if(readOnly)
        val=true;
    end
end
