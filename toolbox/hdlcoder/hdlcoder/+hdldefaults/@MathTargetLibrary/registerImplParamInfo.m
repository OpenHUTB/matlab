function registerImplParamInfo( this )





baseRegisterImplParamInfo( this );


panelLayout = registerNFPImplParamInfo( this, true, true, true );

this.addImplParamInfo( 'CheckResetToZero', 'ENUM', 'on', { 'on', 'off' }, panelLayout );
this.addImplParamInfo( 'MaxIterations', 'ENUM', '32', { '32', '64', '128' }, panelLayout );

this.addImplParamInfo( 'DivisionAlgorithm', 'ENUM', 'Radix-2', { 'Radix-2', 'Radix-4' }, panelLayout );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqfImBY.p.
% Please follow local copyright laws when handling this file.

