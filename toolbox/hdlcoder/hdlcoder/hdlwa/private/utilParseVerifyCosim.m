function isReset = utilParseVerifyCosim( mdladvObj, hDI )



taskObj = mdladvObj.getTaskObj( 'com.mathworks.HDL.VerifyCosim' );

isReset = false;


inputParams = mdladvObj.getInputParameters( taskObj.MAC );
SkipVerifyCosim = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAInputSkipThisTask' ) );


if ~isequal( SkipVerifyCosim.Value, hDI.SkipVerifyCosim )
hDI.SkipVerifyCosim = SkipVerifyCosim.Value;
end 


end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpk65wFH.p.
% Please follow local copyright laws when handling this file.

