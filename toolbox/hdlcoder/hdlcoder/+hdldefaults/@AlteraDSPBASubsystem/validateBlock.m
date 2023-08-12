function v = validateBlock( ~, hC )


v = hdlvalidatestruct;
bfp = hC.SimulinkHandle;
v = validateDSPBASubsystem( hC, bfp, v );
end 


function validateStruct = validateDSPBASubsystem( hC, dspbaSubsys, validateStruct )


targetLang = hdlgetparameter( 'target_language' );
if ( strcmpi( targetLang, 'Verilog' ) )
validateStruct( end  + 1 ) = hdlvalidatestruct( 1,  ...
message( 'hdlcoder:validate:dspbaverilog' ) );
return ;
end 


dspbaBlks = targetcodegen.alteradspbadriver.findDSPBABlks( dspbaSubsys );
dspbaSubsysPath = [ get_param( dspbaSubsys, 'Parent' ), '/', get_param( dspbaSubsys, 'Name' ) ];
if ( length( find( strcmp( dspbaBlks, dspbaSubsysPath ) ) ) ~= 1 )
assert( ~isempty( dspbaBlks ), sprintf( '''%s'' contains no Device block.', dspbaSubsysPath ) );
validateStruct( end  + 1 ) = hdlvalidatestruct( 1,  ...
message( 'hdlcoder:validate:dspbablkcount', dspbaSubsysPath ) );
return ;
end 
deviceBlkPath = find_system( dspbaSubsysPath, 'searchdepth', 1, 'ReferenceBlock', 'DSPBABase/Device' );
deviceBlkPath = deviceBlkPath{ : };


familyDevicePackageSpeed = hdlgetdeviceinfo;
if ( ~isempty( familyDevicePackageSpeed{ 1 } ) ||  ...
~isempty( familyDevicePackageSpeed{ 2 } ) ||  ...
~isempty( familyDevicePackageSpeed{ 3 } ) ||  ...
~isempty( familyDevicePackageSpeed{ 4 } ) )
dspbaFamilyDevicePackageSpeed = { get_param( deviceBlkPath, 'family' ),  ...
get_param( deviceBlkPath, 'device' ),  ...
'',  ...
get_param( deviceBlkPath, 'speed' ) };
if ( ~isequal( lower( regexprep( familyDevicePackageSpeed{ 1 }, '-|\s', '' ) ), lower( regexprep( dspbaFamilyDevicePackageSpeed{ 1 }, '-|\s', '' ) ) ) )
validateStruct( end  + 1 ) = hdlvalidatestruct( 1,  ...
message( 'hdlcoder:validate:dspbablkconflictdevice', dspbaSubsysPath,  ...
familyDevicePackageSpeed{ 1 }, familyDevicePackageSpeed{ 2 }, familyDevicePackageSpeed{ 4 }, familyDevicePackageSpeed{ 3 } ) );
end 
end 


ioSignals = [ hC.PirInputSignals;hC.PirOutputSignals ];
for i = 1:length( ioSignals )
if ( ioSignals( i ).Type.BaseType.isFloatType(  ) )
validateStruct( end  + 1 ) = hdlvalidatestruct( 1,  ...
message( 'hdlcoder:validate:dspbanonfixedpoint', dspbaSubsysPath ) );
end 
end 

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpw8lZUI.p.
% Please follow local copyright laws when handling this file.

