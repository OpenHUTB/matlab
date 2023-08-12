function sa = getSelectedAnnotations( system )
















try 
if ( length( system ) == 1 && ishandle( system ) && ~isnumeric( system ) )
obj = system;
else 
obj = get_param( system, 'Object' );
end 

pkgname = metaclass( obj ).ContainingPackage.Name;

if ( isequal( pkgname, 'Simulink' ) )
sa = find( obj, '-depth', 1, '-isa', 'Simulink.Annotation', 'Selected', 'on' );
elseif ( isequal( pkgname, 'Stateflow' ) )
allSelected = obj.Editor.selectedObjects;
sa = find( allSelected, '-depth', 0, '-isa', 'Stateflow.Note' );
else 
error( message( 'Simulink:studio:badAnnotationParent' ) );
end 
catch 
error( message( 'Simulink:studio:badAnnotationParent' ) );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp6SPPhR.p.
% Please follow local copyright laws when handling this file.

