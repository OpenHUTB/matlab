function setSFunctionName( blockHandle, name )




R36
blockHandle
name( 1, : )char
end 

blockHandle = Simulink.SFunctionBuilder.internal.verifyBlockHandle( blockHandle );
sfcnmodel = sfunctionbuilder.internal.sfunctionbuilderModel.getInstance(  );

cliView = struct( 'publishChannel', 'cli' );
sfcnmodel.registerView( blockHandle, cliView );

controller = sfunctionbuilder.internal.sfunctionbuilderController.getInstance;
try 




ad = sfcnbuilder.sfunbuilderLangExt( 'ComputeLangExtFromWizardData', Simulink.SFunctionBuilder.internal.getApplicationData( blockHandle ) );

if ( exist( [ ad.SfunWizardData.SfunName, '.', ad.LangExt ], 'file' ) == 2 || exist( [ name, '_wrapper.', ad.LangExt ], 'file' ) == 2 )
ad.SfunWizardData.SfunName = name;
ad = sfcnbuilder.read_sfunction_code( ad );
ad = sfcnbuilder.read_wrapper_code( ad );
set_param( blockHandle, 'WizardData', ad.SfunWizardData );
paramNum = str2num( ad.SfunWizardData.NumberOfParameters );
if paramNum > 0


if length( ad.SfunWizardData.Parameters.Value ) < paramNum
paramsValue = cell( 1, paramNum );
paramsValue( : ) = { '0' };
ad.SfunWizardData.Parameters.Value = paramsValue;
end 
paramValueString = sfcnbuilder.getDelimitedParameterStr( ad.SfunWizardData.Parameters );
set_param( blockHandle, 'Parameters', paramValueString );
end 

controller.setApplicationData( blockHandle, ad );
end 
controller.updateSFunctionName( blockHandle, name );
catch ME
error( ME.identifier, ME.message );
end 

sfcnmodel.unregisterView( blockHandle, cliView );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpltHdfj.p.
% Please follow local copyright laws when handling this file.

