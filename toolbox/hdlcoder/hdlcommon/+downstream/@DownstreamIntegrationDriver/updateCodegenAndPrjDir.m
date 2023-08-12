function updateCodegenAndPrjDir( obj )




if ( ~obj.isMLHDLC && ~obj.keepCodegenDir )


hModel = obj.hCodeGen.ModelName;
sobj = get_param( hModel, 'Object' );
configSet = sobj.getActiveConfigSet;
hObj = gethdlcconfigset( configSet );


curRtlDir = hdlget_param( hModel, 'TargetDirectory' );
fullHdlsrcDir = obj.getFullHdlsrcDir;
curRtlDir_temp = strrep( curRtlDir, '\', '/' );
fullHdlsrcDir_temp = strrep( fullHdlsrcDir, '\', '/' );
if ~strcmp( curRtlDir_temp, fullHdlsrcDir_temp )
hObj.getCLI.TargetDirectory = fullHdlsrcDir;
hdlset_param( hModel, 'TargetDirectory', fullHdlsrcDir );
end 


if ~obj.isToolEmpty && ~obj.isFILWorkflow
obj.setProjectPath( obj.getFullFPGADir );
end 

end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpxf6EIm.p.
% Please follow local copyright laws when handling this file.

