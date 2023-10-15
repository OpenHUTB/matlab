function retVal = isActivityDiagram( modelHOrCBInfo )

arguments
    modelHOrCBInfo
end



if isa( modelHOrCBInfo, 'SLM3I.CallbackInfo' )
    activeEditor = modelHOrCBInfo.studio.App.getActiveEditor(  );
    modelH = activeEditor.blockDiagramHandle;
else
    modelH = modelHOrCBInfo;
    modelH = get_param( modelH, 'handle' );
end

if modelH <= 0
    retVal = false;
else
    modelDomain = get_param( modelH, 'SimulinkSubDomain' );
    retVal = strcmp( modelDomain, "ActivityDiagram" );
end

end
