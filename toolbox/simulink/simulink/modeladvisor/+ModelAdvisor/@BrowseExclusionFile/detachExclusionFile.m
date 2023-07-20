function detachExclusionFile(this)
    exclusionEditor=this.getExclusionEditor;
    exclusionEditor.exclusionState=containers.Map('KeyType','char','ValueType','any');
    exclusionEditor.fileName='';
    set_param(bdroot(exclusionEditor.fModelName),'MAModelExclusionFile','');
    exclusionEditor.fDialogHandle.restoreFromSchema;
    exclusionEditor.fDialogHandle.enableApplyButton(false);
    this.delete;