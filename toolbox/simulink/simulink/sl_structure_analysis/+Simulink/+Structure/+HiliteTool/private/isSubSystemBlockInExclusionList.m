

function bool=isSubSystemBlockInExclusionList(block)

    blockType=get_param(block,'BlockType');
    assert(strcmpi(blockType,'Subsystem'));
    sfType=get_param(block,'SFBlockType');
    exclusionList={'MATLAB Function','Chart'};
    isNotReadable=strcmpi(get_param(block,'Permissions'),'NoReadOrWrite');
    isHiddenMaskedSubsystem=strcmpi(get_param(block,'MaskHideContents'),'on');

    bool=any(ismember(sfType,exclusionList))||isNotReadable||isHiddenMaskedSubsystem;

end
