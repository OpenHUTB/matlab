function old = halfsupport( new )

























persistent defaultslhalfstatus;

isfirstrun = isempty( defaultslhalfstatus );
needchangefeature = true;



if isstruct( new )
slhalfstatus = new.slhalfstatus;
else 
switch lower( new )
case { 'on', 't1' }

slhalfstatus = 1;
case 't2'

slhalfstatus = 2;
case 'complex'

slhalfstatus = 9;
case 'raccel'

slhalfstatus = 65;
case 'all'

slhalfstatus = 75;
case 'off'

slhalfstatus = 0;
case 'default'

slhalfstatus = defaultslhalfstatus;
case 'current'
printFeature( 'SLHalfPrecisionSupport' );
needchangefeature = false;

otherwise 
error( 'Invalid option' );

end 

end 

if needchangefeature

old.slhalfstatus = changeFeature( 'SLHalfPrecisionSupport', slhalfstatus );
else 
old.slhalfstatus = slfeature( 'SLHalfPrecisionSupport' );
end 

if isfirstrun




defaultslhalfstatus = old.slhalfstatus;
end 

end 

function old = changeFeature( feature, value )

old = slfeature( feature, value );
fprintf( 'Changing %s from value %d to %d\n', feature, old, value );
end 

function printFeature( feature )
fprintf( 'slfeature %s = %d\n', feature, slfeature( feature ) );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpai1z13.p.
% Please follow local copyright laws when handling this file.

