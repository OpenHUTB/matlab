function widget=localGetSampleTimeWidgetWithHiding(tag,prmIndex,prmValue,source,methods)


















    blockType=get_param(source.getBlock.getFullName,'BlockType');
    if strcmp(blockType,'Constant')
        showWidgets=~strcmpi(prmValue,'inf');
    else
        showWidgets=~strcmp(prmValue,'-1');
    end

    if showWidgets






        prompt.Name=DAStudio.message('Simulink:blkprm_prompts:AllSrcBlksSampleTime');
        prompt.Type='text';
        prompt.Tag='SampleTime_Prompt_Tag';
        prompt.RowSpan=[1,1];
        prompt.ColSpan=[1,1];
        prompt.Buddy=tag;


        warningPanel=localGetHiddenSampleTimeWarningPanel('SampleTime',blockType);
        warningPanel.RowSpan=[1,1];
        warningPanel.ColSpan=[2,2];


        value.Type='edit';
        value.Tag=tag;
        value=localHandleEditEvent(value,prmIndex,prmValue,source,methods);


        blockHandle=source.getBlock.Handle;
        if prmIndex>=0

            prmName=source.getDialogParams{prmIndex+1};
        else

            prmName=tag;
        end
        value.Enabled=Simulink.isParameterEnabled(blockHandle,prmName);
        value.HideName=true;
        value.RowSpan=[2,2];
        value.ColSpan=[1,2];


        items={prompt,warningPanel,value};
        widget.Type='panel';
        widget.Tag='SampleTime_Panel_Tag';
        widget.Items=items;
        widget.LayoutGrid=[2,2];
        widget.RowStretch=[1,1];
        widget.ColStretch=[1,0];
    else

        widget=localCreateBasicSampleTimeWidget(tag,prmIndex,prmValue,source,methods);
        widget.Visible=false;
        widget.Enabled=false;
    end


