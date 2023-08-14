function refs=findSubsystemReferences(model)






    blks=Simulink.findBlocksOfType(model,'SubSystem',...
    'ReferencedSubsystem','.',...
    Simulink.FindOptions('RegExp',1));
    if isempty(blks)
        refs=[];
        return
    end

    refs=get_param(blks,'ReferencedSubsystem');
    if ischar(refs)
        refs={refs};
        return
    else
        refs=unique(refs(~cellfun('isempty',refs)));
    end

end
