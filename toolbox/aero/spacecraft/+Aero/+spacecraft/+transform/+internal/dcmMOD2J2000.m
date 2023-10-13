function dcm = dcmMOD2J2000( epoch, dAT )

arguments
    epoch{ Aero.internal.validation.validateColumnDatetimeOrDateVector( epoch, '', '' ) }
    dAT( :, 1 ){ mustBeNumeric, mustBeReal, mustBeFinite } = 0
end

if ~builtin( 'license', 'checkout', 'Aerospace_Toolbox' )
    error( message( 'spacecraft:cubesat:licenseFailAeroTlbx' ) );
end

epochDT = datetime( epoch );
epoch_len = size( epochDT, 1 );
epochDV = Aero.internal.math.createDateVec( epochDT );

dAT = Aero.spacecraft.internal.validation.resizeEOP( dAT, epoch_len, 'dAT', 'epoch' );

ssTT = epochDV( :, 6 ) + dAT + 32.184;
[ ~, tTT, tTT2, tTT3 ] = Aero.spacecraft.transform.internal.getJulianCenturies( [ epochDV( :, 1:5 ), ssTT ] );

zeta = convang( ( 2306.2181 .* tTT + 0.30188 .* tTT2 + 0.017998 .* tTT3 ) ./ 3600, 'deg', 'rad' );
theta = convang( ( 2004.3109 .* tTT - 0.42665 .* tTT2 - 0.041833 .* tTT3 ) ./ 3600, 'deg', 'rad' );
z = convang( ( 2306.2181 .* tTT + 1.09468 .* tTT2 + 0.018203 .* tTT3 ) ./ 3600, 'deg', 'rad' );

dcm = angle2dcm(  - zeta, theta,  - z, 'ZYZ' )';

end


