function annotation=findBySID(annotationInfo)
















    annotationPath=char(annotationInfo.Path);
    modelName=strtok(annotationPath,'/');
    annotation=find_system(modelName,...
    'IncludeCommented','on',...
    'LookInsideSubsystemReference','off',...
    'MatchFilter',@Simulink.match.allVariants,...
    'FindAll','on',...
    'LookUnderMasks','all',...
    'type','Annotation',...
    'SID',annotationInfo.SID);
end
