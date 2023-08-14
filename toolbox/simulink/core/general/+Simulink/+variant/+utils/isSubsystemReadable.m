function isSubsystemReadable=isSubsystemReadable(ssPath)











    isSubsystemReadable=~strcmp('NoReadOrWrite',get_param(ssPath,'Permissions'))...
    &&strcmp('off',get_param(ssPath,'MaskHideContents'));


end
