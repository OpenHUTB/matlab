function items=createSubsystemRefTabItems(source)




    items={};
    if showConvertPanel(source,source.getBlock)
        items{1}=createConversionPanel(source);
    else
        items{1}=createOpenPanel(source);
    end
end



function panel=createConversionPanel(source)
    isEnabled=isConvertionButtonEnabled(source.getBlock);

    prompt.Name=DAStudio.message('Simulink:SubsystemReference:ConvertToSRHelpText');
    prompt.Type='text';
    prompt.WordWrap=true;
    prompt.Enabled=isEnabled;
    prompt.Tag='convert_to_srblock_help_text_tag';
    prompt.RowSpan=[1,1];
    prompt.ColSpan=[1,2];

    button.Name=DAStudio.message('Simulink:SubsystemReference:ConvertToSRButtonText');
    if~source.isSlimDialog

        button.Alignment=2;
    end
    button.Type='pushbutton';
    button.RowSpan=[2,2];
    button.ColSpan=[1,1];
    button.Enabled=isEnabled;
    button.Tag='convert_to_srblock_button_tag';
    button.MatlabMethod='SRDialogHelper.ConvertToSRButtonCallback';
    button.MatlabArgs={source.getBlock.handle,'%dialog'};

    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[3,3];
    spacer.ColSpan=[1,2];

    panel.Name='';
    panel.Type='panel';
    panel.LayoutGrid=[3,2];
    panel.RowSpan=[1,3];
    panel.ColSpan=[1,2];
    panel.ColStretch=[1,1];
    panel.RowStretch=[0,0,1];
    panel.Tag='convert_to_srblock_panel_tag';
    panel.Items={prompt,button,spacer};

end

function panel=createOpenPanel(source)


    isChildOfVAS=slInternal('IsChildOfVAS',source.getBlock.handle);
    isEnabled=~isLinked(source.getBlock)&&~isChildOfVAS;
    rowIdx=1;
    prompt.Name=DAStudio.message('Simulink:SubsystemReference:SRTabHelpText');
    prompt.Type='text';
    prompt.Tag='browse_open_help_text_tag';
    prompt.Enabled=isEnabled;
    prompt.RowSpan=[rowIdx,rowIdx];
    prompt.ColSpan=[1,2];


    rowIdx=rowIdx+1;
    [rsPrompt,rsValue]=create_widget(source,source.getBlock,'ReferencedSubsystem',rowIdx,1,1);
    rsPrompt.Enabled=isEnabled;
    rsValue.Enabled=isEnabled;

    colIdx=3;
    if source.isSlimDialog
        rowIdx=rowIdx+1;
        colIdx=2;
        rsValue.Source=source.getBlock;
    end

    browse.Name=DAStudio.message('Simulink:protectedModel:btnBrowse');

    if~source.isSlimDialog
        browse.Alignment=6;
    end

    browse.Type='pushbutton';
    browse.RowSpan=[rowIdx,rowIdx];
    browse.ColSpan=[colIdx,colIdx];
    browse.Tag='browse_file_tag';
    browse.Enabled=isEnabled;
    browse.MatlabMethod='SRDialogHelper.BrowseButtonCallback';
    browse.MatlabArgs={'%dialog',rsValue.Tag};

    colIdx=colIdx+1;
    if source.isSlimDialog
        rowIdx=rowIdx+1;
        colIdx=2;
    end

    open.Name=DAStudio.message('Simulink:SubsystemReference:OpenSubsysButtonText');

    if~source.isSlimDialog
        open.Alignment=6;
    end

    open.Type='pushbutton';
    open.RowSpan=[rowIdx,rowIdx];
    open.ColSpan=[colIdx,colIdx];
    open.Tag='open_subsystem_button_tag';
    open.Enabled=~isLinked(source.getBlock);
    open.MatlabMethod='SRDialogHelper.OpenSRButtonCallback';
    open.MatlabArgs={source.getBlock.handle,'%dialog'};

    rowIdx=rowIdx+1;
    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[rowIdx,rowIdx];
    spacer.ColSpan=[1,colIdx];

    panel.Name='';
    panel.Type='panel';
    panel.LayoutGrid=[rowIdx,colIdx];
    panel.RowSpan=[1,rowIdx];
    panel.ColSpan=[1,colIdx];
    panel.ColStretch=ones(1,colIdx);
    panel.RowStretch=[zeros(1,rowIdx-1),1];
    panel.Tag='browse_open_panel_tag';
    panel.Items={prompt,rsPrompt,rsValue,browse,open,spacer};


end


function ret=isConvertionButtonEnabled(block)
    ret=false;

    if isLinked(block)
        return;
    end

    if~slInternal('isStateOwnerAndAccessorInsideSameSubsystem',block.Handle)
        return;
    end

    if strcmp(block.Mask,'on')&&strcmp(block.MaskType,'Sigbuilder block')
        return;
    end

    ssType=Simulink.SubsystemType(block.handle);

    if(ssType.isStateflowSubsystem||ssType.isForEachSubsystem()...
        ||ssType.isResettableSubsystem()...
        ||ssType.isActionSubsystem()||ssType.isIteratorSubsystem()...
        ||ssType.isSimulinkFunction())
        return;
    end

    ret=true;
end


function ret=isLinked(block)
    blkHandle=block.Handle;
    linkStatusForBlock=get_param(blkHandle,'StaticLinkStatus');
    switch linkStatusForBlock
    case{'resolved','implicit'}
        ret=true;
    case{'inactive','none'}
        ret=false;
    end
end


function ret=showConvertPanel(source,block)




    ret=true;
    if~getIsReferenceSubsystem(source,block)
        return;
    end

    if strcmp(get_param(block.Handle,'ReferencedSubsystem'),'<file name>')
        child=Simulink.findBlocks(block.Handle);
        if~isempty(child)
            return;
        end
    end


    ret=false;

end



