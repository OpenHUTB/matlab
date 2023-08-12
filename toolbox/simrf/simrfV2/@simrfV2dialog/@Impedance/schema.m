function schema





rfPackage = findpackage( 'simrfV2dialog' );
parent = findclass( rfPackage, 'simrfV2dialog' );
this = schema.class( rfPackage, 'Impedance', parent );


m = schema.method( this, 'getDialogSchema' );
s = m.Signature;
s.varargin = 'off';
s.InputTypes = { 'handle', 'string' };
s.OutputTypes = { 'mxArray' };





if isempty( findtype( 'SimRFV2ImpedanceModelTypeEnum' ) )
schema.EnumType( 'SimRFV2ImpedanceModelTypeEnum', {  ...
'Frequency independent', 'Frequency dependent' } );
end 

schema.prop( this, 'Impedance_type', 'SimRFV2ImpedanceModelTypeEnum' );
schema.prop( this, 'Impedance', 'string' );
schema.prop( this, 'Freq', 'string' );
schema.prop( this, 'Freq_unit', 'SimRFV2FreqUnitType' );


% Decoded using De-pcode utility v1.2 from file /tmp/tmp5wIhMY.p.
% Please follow local copyright laws when handling this file.

