function status=convertSubsystemToSubsystemReference(subsystemBlock,subsystemBDName)










    blockHandle=get_param(subsystemBlock,'handle');
    referencedSS=get_param(blockHandle,'ReferencedSubsystem');
    if~isempty(referencedSS)
        msg=message(...
        'Simulink:SubsystemReference:SSRefBlockCannotBeConverted',getfullname(blockHandle));
        error(msg);
    end

    [~,~,ext]=fileparts(subsystemBDName);
    if isempty(ext)
        ext=get_param(0,'ModelFileFormat');
        subsystemBDName=[subsystemBDName,'.',ext];
    end

    if isfile(subsystemBDName)
        error(message('Simulink:SubsystemReference:CannotCreateFile',subsystemBDName));
    end

    obj=SubsystemReferenceConverter(blockHandle,subsystemBDName,true);
    [status,msg]=obj.convertSubsystem();
    if~status&&~isempty(msg)
        msg=slprivate('removeHyperLinksFromMessage',msg);
        error(msg)
    end
end
