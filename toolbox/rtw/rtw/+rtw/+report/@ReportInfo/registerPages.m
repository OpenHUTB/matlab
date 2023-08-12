






function registerPages( obj )


if ~isempty( obj.Pages ) && isa( obj.Pages{ 1 }, 'rtw.report.Summary' )
return 
end 

model = obj.ModelName;
isERTTarget = strcmp( get_param( model, 'IsERTTarget' ), 'on' );

pages = obj.Pages;
obj.Pages = {  };


obj.Summary.updateSummary( model );
obj.addPage( obj.Summary );


obj.addPage( rtw.report.Subsystem( model, obj.SourceSubsystem ) );


bMdlRef = ~strcmp( obj.ModelReferenceTargetType, 'NONE' );
if coder.internal.codeinfo( 'existCodeInfo', obj.BuildDirectory ) && ~bMdlRef
obj.addPage( rtw.report.CodeInterface( model, obj.BuildDirectory ) );
end 


if isERTTarget
obj.addPage( rtw.report.Traceability( model ) );
end 


if isERTTarget
obj.addPage( rtw.report.CodeMetrics( model, obj.BuildDirectory, obj.SourceSubsystem, true ) );
end 


if ~isempty( obj.ReducedBlocks ) &&  ...
strcmp( obj.Config.GenerateTraceInfo, 'off' ) &&  ...
strcmp( obj.Config.GenerateTraceReport, 'off' ) &&  ...
strcmp( get_param( model, 'ShowEliminatedStatement' ), 'on' )
obj.addPage( obj.ReducedBlocks );
end 


if ~isempty( obj.InsertedBlocks )
obj.addPage( obj.InsertedBlocks );
end 


if isERTTarget
hTfl = get_param( model, 'TargetFcnLibHandle' );
obj.addPage( rtw.report.CodeReplacements( model, obj.SourceSubsystem, hTfl ) );
end 


if isERTTarget
hSharedCode = get_param( model, 'SharedCodeRepository' );
if ~isempty( hSharedCode )
obj.addPage( rtw.report.CrossRelease( model, hSharedCode ) );
end 
end 


if isERTTarget
obj.addPage( rtw.report.CoderAssumptions( model, obj.BuildDirectory ) );
end 

obj.Pages = [ obj.Pages( : );pages( : ) ];

model = obj.ModelName;
suffix = obj.getModelNameSuffix;
baseName = [ model, suffix ];
for k = 1:length( obj.Pages )
p = obj.Pages{ k };
if isempty( p.ReportFileName )
p.ReportFileName = [ baseName, '_', p.getDefaultReportFileName ];
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp2hKl2o.p.
% Please follow local copyright laws when handling this file.

