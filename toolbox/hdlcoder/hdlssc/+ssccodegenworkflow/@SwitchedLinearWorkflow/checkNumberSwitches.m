function numSwitches=checkNumberSwitches(obj)




    simscapeModel=obj.SimscapeModel;



    commonArgs={'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all','FollowLinks','on'};

    switches=find_system(simscapeModel,commonArgs{:},'ReferenceBlock','fl_lib/Electrical/Electrical Elements/Switch');
    diodes=find_system(simscapeModel,commonArgs{:},'ReferenceBlock','fl_lib/Electrical/Electrical Elements/Diode');
    diodes=[diodes;find_system(simscapeModel,commonArgs{:},'ReferenceBlock','ee_lib/Semiconductors & Converters/Diode')];
    IGBTs=find_system(simscapeModel,commonArgs{:},'ReferenceBlock',sprintf('ee_lib/Semiconductors & Converters/IGBT\n(Ideal,\nSwitching)'));
    numSwitches=numel([switches;diodes;IGBTs]);
end


