function[dlgStruct,unknownBlockFound]=...
    runOrderSpecifiedSubsystemDDG(source,h)






    block=source.getBlock;
    unknownBlockFound=false;

    if((strcmp(get_param(block.Handle,'BlockType'),'SubSystem'))&&...
        strcmp(get_param(block.Handle,'SystemType'),...
        'RunOrder'))


        runOrderSpecifierConfigurator=find_system(block.Handle,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all','BlockType','RunOrderSpecifier');
    else
        runOrderSpecifierConfigurator={};
        unknownBlockFound=true;
    end

    if(unknownBlockFound==true)
        dlgStruct={};
        return;
    end

    runOrderMode=get_param(runOrderSpecifierConfigurator,'RunOrder');


    [descGrp,unknownBlockFound]=source.getBlockDescription(runOrderMode);


    switch runOrderMode
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
