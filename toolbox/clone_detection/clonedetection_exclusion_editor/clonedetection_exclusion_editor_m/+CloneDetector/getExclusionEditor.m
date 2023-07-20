function exclusionEditorWindow=getExclusionEditor(model)






    instance=CloneDetector.ExclusionEditorUIService.getInstance;
    exclusionEditorWindow=instance.getExclusionEditor(model);
end
