function graderr( finite_diff_deriv, analytic_deriv, evalstr2 )




err = max( max( abs( analytic_deriv - finite_diff_deriv ) ) );
disp( sprintf( getString( message( 'Simulink:util:MaxDiscrepancyBetweenDerivatives', sprintf( '%g', err ) ) ) ) );
if ( err > 1e-6 * norm( analytic_deriv ) + 1e-5 )
disp( getString( message( 'Simulink:util:DerivativesNotWithinTol' ) ) )
disp( getString( message( 'Simulink:util:DerivativeFromFiniteDiff' ) ) )
finite_diff_deriv
disp( sprintf( getString( message( 'Simulink:util:UserSuppliedDerivative', evalstr2 ) ) ) )
analytic_deriv
disp( getString( message( 'Simulink:util:GraderrDifference' ) ) )
analytic_deriv - finite_diff_deriv
disp( getString( message( 'Simulink:util:StrikeAnyKeyToContinue' ) ) )
pause
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3ujjQt.p.
% Please follow local copyright laws when handling this file.

