function[dlgStruct,unknownBlockFound]=...
    priorityAssignmentSubsystemDDG(source,h)






    block=source.getBlock;
    unknownBlockFound=false;

    if((strcmp(get_param(block.Handle,'BlockType'),'SubSystem'))&&...
        strcmp(get_param(block.Handle,'SystemType'),...
        'PriorityConfiguration'))


        priorityConfigurator=find_system(block.Handle,'LookUnderMasks',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'all','BlockType','PriorityAssignment');
    else
        priorityConfigurator={};
        unknownBlockFound=true;
    end

    if(unknownBlockFound==true)
        dlgStruct={};
        return;
    end

    priorityMode=get_param(priorityConfigurator,'PrioritizerMode');


    [descGrp,unknownBlockFound]=source.getBlockDescription(priorityMode);


    switch priorityMode
    case 'First'
        dlgStruct.DialogTag='First';
    case 'Last'
        dlgStruct.DialogTag='Last';
    otherwise
        unknownBlockFound=true;
    end

    dlgStruct.Items={descGrp};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];


    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};


    dlgStruct.PreApplyMethod='preApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

end
