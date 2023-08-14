function[dlgStruct,unknownBlockFound]=EventListener_ddg(source,h)







    [descGrp,unknownBlockFound]=source.getBlockDescription();

    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,2];

    mainParamGroup=get_main_param_group(source,h);

    dlgStruct.Items={descGrp,mainParamGroup};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];


    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};


    dlgStruct.PreApplyMethod='preApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};

    dlgStruct.OpenCallback=@openCallback;


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    [~,isLockedLibrary]=source.isLibraryBlock(h);
    linkStatus=h.LinkStatus;
    isLinked=~strcmp(linkStatus,'none');
    if isLockedLibrary||source.isHierarchySimulating||isLinked
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end
end




function paramGrp=get_main_param_group(source,h)
    isReset=strcmp(h.EventType,'Reset');
    isReinitialize=strcmp(h.EventType,'Reinitialize');

    isBroadcastFunction=(strcmp(h.EventType,'Broadcast'));

    showEventName=isReset||isBroadcastFunction||isReinitialize;



    rowIdx=1;
    maxCol=2;

    [eventTypePrompt,eventType]=create_widget(source,h,'EventType',rowIdx,1,1);
    eventType.DialogRefresh=true;

    if showEventName
        rowIdx=rowIdx+1;
        if isReset
            eventIds=source.EventListener_ddg_cb('getResetNames',h.Handle);
        elseif isReinitialize
            eventIds=source.EventListener_ddg_cb('getReinitNames',h.Handle);
        end

        [eventNamePrompt,eventName]=create_widget(source,h,'EventName',rowIdx,1,1);
        eventName.DialogRefresh=true;
        eventName.AutoCompleteType='Custom';
        eventName.AutoCompleteViewColumn={'Recently used'};
        eventName.AutoCompleteMatchOption='contains';
        eventName.AutoCompleteViewData=eventIds;
        eventName.MatlabMethod='EventListener_ddg_cb';
        eventName.MatlabArgs={source,'eventNameCallback',h.Handle,'%dialog'};
    end

    showWarnIcon=false;

    if((slfeature('SupportResetWithInit')>0)&&(isReset||isReinitialize))


        showWarnIcon=source.EventListener_ddg_cb('checkEventName',h.Handle);

        if showWarnIcon

            eventNameRow=eventNamePrompt.RowSpan(1);

            imagepath=fullfile(matlabroot,'toolbox','shared','dastudio','resources');
            warningIcon.Type='image';
            warningIcon.FilePath=fullfile(imagepath,'red_warningIcon12.png');
            warningIcon.Tag='warning_icon';
            warningIcon.DialogRefresh=true;
            warningIcon.ToolTip=DAStudio.message('Simulink:blocks:WarnEventNameCollision');
            warningIcon.Alignment=7;

            warningIcon.RowSpan=[eventNameRow,eventNameRow];

            warningIcon.ColSpan=[1,1];
            eventName.ColSpan=[2,2];
        end
    end

    rowIdx=rowIdx+1;

    enableVariantWidget=create_widget(source,h,'Variant',rowIdx,1,1);
    enableVariantWidget.DialogRefresh=true;

    variantOn=strcmp(h.Variant,'on');

    if variantOn
        rowIdx=rowIdx+1;
        [variantControlPrompt,variantControl]=create_widget(source,h,'VariantControl',rowIdx,1,1);
        variantControl.DialogRefresh=true;

        rowIdx=rowIdx+1;
        gpcWidget=create_widget(source,h,'GeneratePreprocessorConditionals',rowIdx,1,1);
        gpcWidget.DialogRefresh=true;
    end

    if(isBroadcastFunction)
        rowIdx=rowIdx+1;
        broadcastEventPriorityWidget=create_widget(source,h,'BroadcastEventPriority',rowIdx,1,1);
        gpcWidget.DialogRefresh=true;
    end

    rowIdx=rowIdx+1;
    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[rowIdx,rowIdx];
    spacer.ColSpan=[1,maxCol];

    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='panel';
    paramGrp.LayoutGrid=[rowIdx,maxCol];

    paramGrp.Items={eventTypePrompt,eventType};

    if showEventName
        paramGrp.Items={paramGrp.Items{1:end},eventNamePrompt,eventName};
    end

    if showWarnIcon
        paramGrp.Items={paramGrp.Items{1:end},warningIcon};
    end


    paramGrp.Items={paramGrp.Items{1:end},enableVariantWidget};

    if variantOn
        paramGrp.Items={paramGrp.Items{1:end},variantControlPrompt,variantControl,gpcWidget};
    end

    if(isBroadcastFunction)
        paramGrp.Items={paramGrp.Items{1:end},broadcastEventPriorityWidget};
    end

    paramGrp.Items={paramGrp.Items{1:end},spacer};

    paramGrp.LayoutGrid=[rowIdx,maxCol];
    paramGrp.ColStretch=ones(1,maxCol);
    paramGrp.RowStretch=[zeros(1,(rowIdx-1)),1];
    paramGrp.Source=h;

end

function openCallback(dlg)
    source=dlg.getSource;
    h=source.getBlock;
    EventListener_ddg_cb(source,'eventNameCallback',h.Handle,dlg);
end
