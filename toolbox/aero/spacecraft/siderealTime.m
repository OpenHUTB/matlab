function varargout = siderealTime( utcJD, dUT1, dAT )




R36
utcJD( :, 1 ){ mustBeNumeric, mustBeReal, mustBeFinite, mustBeNonNan, mustBeGreaterThan( utcJD, 1721425.5 ) }
dUT1( :, 1 ){ mustBeNumeric, mustBeReal } = 0
dAT( :, 1 ){ mustBeNumeric, mustBeReal } = 0
end 


if ~builtin( 'license', 'checkout', 'Aerospace_Toolbox' )
error( message( 'spacecraft:cubesat:licenseFailAeroTlbx' ) );
end 


nargoutchk( 0, 2 );

jd_length = size( utcJD, 1 );
dUT1 = Aero.spacecraft.internal.validation.resizeEOP( dUT1, jd_length, 'dUT1', 'utcJD' );
dAT = Aero.spacecraft.internal.validation.resizeEOP( dAT, jd_length, 'dAT', 'utcJD' );

utcDT = datetime( utcJD, 'convertfrom', 'juliandate' );
utc = Aero.internal.math.createDateVec( utcDT );


ssUT1 = utc( :, 6 ) + dUT1;
[ mjdUT1, tUT1, tUT12, ~ ] = Aero.spacecraft.transform.internal.getJulianCenturies( [ utc( :, 1:5 ), ssUT1 ] );

z = zeros( size( utc, 1 ), 1 );
[ ~, tUT10, tUT120, tUT130 ] = Aero.spacecraft.transform.internal.getJulianCenturies( [ utc( :, 1:3 ), z, z, z ] );


thGMST0h = 100.4606184 + 36000.77005361 .* tUT10 + 0.00038793 .* tUT120 - 2.6e-8 .* tUT130;


omegaPrec = 1.002737909350795 + 5.9006e-11 .* tUT1 - 5.9e-15 .* tUT12;



UT1 = utc( :, 4 ) .* ( 3600 ) + utc( :, 5 ) .* 60 + ssUT1;



thGMST = mod( thGMST0h + ( 1 / 240 ) .* omegaPrec .* UT1, 360 );
varargout{ 1 } = thGMST;

if nargout > 1


ssTT = utc( :, 6 ) + dAT + 32.184;
[ mjdTT, tTT, tTT2, tTT3 ] = Aero.spacecraft.transform.internal.getJulianCenturies( [ utc( :, 1:5 ), ssTT ] );


epsilonBar = 23.439291 - 0.0130042 .* tTT - 1.64e-7 .* tTT2 + 5.04e-7 .* tTT3;
nutationAngles = earthNutation( 2400000.5 + mjdTT );
dpsi = rad2deg( nutationAngles( :, 1 ) );



omegaMoon = 125.04455501 - ( 5 * 360 + 134.1361851 ) .* tTT ...
 + 0.0020756 .* tTT2 + 2.139e-6 .* tTT3;
omegaMoon( mjdUT1 < 50449 ) = 0;
equinoxEq = dpsi .* cosd( epsilonBar ) + ( 0.00264 / 3600 ) .*  ...
sind( omegaMoon ) + ( 0.000063 / 3600 ) .* sind( 2 .* omegaMoon );


thGAST = thGMST + equinoxEq;
varargout{ 2 } = thGAST;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpfcQVzi.p.
% Please follow local copyright laws when handling this file.

