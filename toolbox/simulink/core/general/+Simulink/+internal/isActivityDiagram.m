function retVal = isActivityDiagram( modelHOrCBInfo )



R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmp5zeKvB.p.
% Please follow local copyright laws when handling this file.

