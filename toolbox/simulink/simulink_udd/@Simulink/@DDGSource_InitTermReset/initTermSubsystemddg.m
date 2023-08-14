function[dlgStruct,unknownBlockFound]=initTermSubsystemddg(source,h)






    block=source.getBlock;
    unknownBlockFound=false;

    if((strcmp(get_param(block.Handle,'BlockType'),'SubSystem'))&&...
        (strcmp(get_param(block.Handle,'SystemType'),'EventFunction')||...
        strcmp(get_param(block.Handle,'SystemType'),'MessageFunction')))


        eventListener=find_system(block.Handle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','BlockType','EventListener');
    else
        eventListener={};
        unknownBlockFound=true;
    end
    if(unknownBlockFound==true)
        dlgStruct={};
        return;
    end

    eventType=get_param(eventListener,'EventType');




    [descGrp,unknownBlockFound]=source.getBlockDescription(eventType);




    switch eventType
    case 'Initialize'
        dlgStruct.DialogTag='Initialize function';
    case 'Terminate'
        dlgStruct.DialogTag='Terminate function';
    case 'Reinitialize'
        dlgStruct.DialogTag='Reinitialize function';
    case 'Reset'
        dlgStruct.DialogTag='Reset function';
    case 'Broadcast'
        dlgStruct.DialogTag='Message function';
    case 'Message Arrival'
        dlgStruct.DialogTag='Message function';
    otherwise
        unknownBlockFound=true;
    end
    dlgStruct.Items={descGrp};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];


    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};


    dlgStruct.PreApplyCallback='resetSubsystemddg_cb';
    dlgStruct.PreApplyArgs={source,'doPreApply','%dialog'};


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};
end
